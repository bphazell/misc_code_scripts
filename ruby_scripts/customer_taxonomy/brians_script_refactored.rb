require 'restforce'
require 'awesome_print'
require 'csv'
require 'pg'
require 'date'


# changed this into a constant since we dont ever want this to change
# all constants and variables should be declared up top
# Try not to go past 70 characters into a line, but 80  is absolute max
ACTIVE_JOB_START_DATE = "2014-10-31"
TODAY = Date.today.to_s #This will come out like: "2015-01-16"
FULL_REPORT_NAME = "customer_taxonomy_full_report_#{TODAY}.csv"
PN_MISMATCH_REPORT_NAME = "customer_taxonomy_mismatched_pns_report_#{TODAY}.csv"
SUMMARY_REPORT_NAME = "customer_taxonomy_summary_#{TODAY}.csv"
CSV_HEADERS = 
  [
    "salesforce_pn", "salesforce_account", "sf_last_work_order", 
    "sf_fee_type", "contract_exp_date", "builder_organizations_pn",
    "builder_jobs_pn", "organization_id", "team_name", "team_id", 
    "akon_user_id", "builder_user_id", "email", "job_id", "launch_date", 
    "job_cost_with_markup", "finalized_units", "last_conversion"
  ]
SUMMARY_HEADERS = 
  [
    "PN", "organization_name", "users", "number_of_launched_jobs",
    "total_crowdspend_with_markup", "total_finalized_units"
  ]
#fixed spacing here
INDICES = 
  {
    sf_name:           0,
    last_work_order:   1,
    fee_type:          2,
    contract_exp_date: 3
  }

# Grouped together connections
# Fixed spacing/alignment here
client = Restforce.new
  ( 
    username:       'andy@crowdflower.com',
    password:       '1awesomepassword',
    security_token: 'fI3It3FCdoFuEYOixIin9gck9',
    client_id:      '3MVG9yZ.WNe6byQADrJ.3pNJkp1YwOg43Fdw4JQr5dfRbJqpZGto6arY5uSxst8zS2dvewgiil7eiS5eF86ds',
    client_secret:  '7380858972881717415'
  )
# Connect to Redshift
redshift = PG.connect
  ( 
    dbname:      'matt_crowdflower', 
    host:        'cf-redshift.etleap.com',
    user:        'matt_crowdflower',
    password:    'wznvhKJVAC135299756',
    port:        5439
  )



####################################################
### DONE WITH VARIABLE DECLARATION...GO TIME!!!! ###
####################################################

# This is a query class template. The idea is, it provides a template to
# query a source (like SalesForce or RedShift), and provides a result structure.
# There are actual classes which take the RedShift and SalesForce specific formats
# and fill them in.

# IDEALLY each class is it's own file, and you port that file in by using
# require_relative 'path/to/file/relative/to/here' to include the class file
class Query
  attr_accessor :results_hash

  def initialize(connection)
    @connection = connection
    @query = query
    @query_results = run_query
    @results_hash = get_results_hash
  end

  # Queries should be held as their own .sql file.  I'll
  # show you how to do this later. 
  def self.sf_query
    "
      SELECT   Work_Order__c.Earned_Date__c, 
               Work_Order__c.Work_Order_Fee_Type__c, 
               Work_Order__c.Project__r.Name, 
               Work_Order__c.Project__r.Account__r.Name, 
               Work_Order__c.Project__r.Target_Completion_Date__c
  
      FROM     Work_Order__c
  
      WHERE    Work_Order__c.Project__r.Target_Completion_Date__c > #{time}
    "
  end

  def self.rs_query(pn)
    "
      SELECT builder_organizations.project_number as builder_organizations_pn, 
             builder_jobs.project_number as builder_jobs_pn, 
             builder_organizations.id as organization_id,
             akon_teams.name as team_name, 
             akon_teams.id as team_id, 
               team_member_info.user_id as akon_user_id, 
             builder_users.id as builder_user_id, 
             builder_users.email as email, 
             builder_jobs.id as job_id, 
             markup_info.launch_date, 
             conversion_info.conversion_sum as job_cost, 
             markup_info.markup, unit_total.unit_count,
             conversion_info.last_conversion as last_conversion
  
      FROM   builder_organizations
      JOIN   akon_teams on akon_teams.organization_id = builder_organizations.id
      JOIN   (
                SELECT  DISTINCT(akon_team_memberships.user_id), 
                        akon_team_memberships.team_id
                FROM    akon_team_memberships
             )  AS team_member_info
      ON     team_member_info.team_id = akon_teams.id
      JOIN   builder_users on builder_users.akon_id = team_member_info.user_id
      JOIN   builder_jobs on builder_jobs.user_id = builder_users.id
      JOIN   (
                SELECT   MAX(builder_conversions.started_at) as last_conversion, 
                         builder_conversions.job_id, 
                         ROUND(SUM(builder_conversions.amount),3) as conversion_sum
                FROM     builder_conversions
                WHERE    external_type != 'cf_internal'
                GROUP BY builder_conversions.job_id
              ) AS conversion_info
      ON      builder_jobs.id = conversion_info.job_id
      JOIN    (
                SELECT   max(builder_orders.markup) as markup, 
                         builder_orders.job_id,  
                         MIN(builder_orders.created_at) as launch_date
                FROM     builder_orders
                WHERE    builder_orders.type = 'Debit'
                GROUP BY job_id
              ) AS markup_info
      ON      markup_info.job_id = builder_jobs.id
      JOIN    (
                SELECT   COUNT(builder_units.id) as unit_count, 
                         builder_units.job_id
                FROM     builder_units
                WHERE    builder_units.state = 9
                GROUP BY builder_units.job_id
              ) AS unit_total
      ON      unit_total.job_id = builder_jobs.id
      
      WHERE   builder_organizations.project_number = '#{pn}'
      AND     conversion_info.last_conversion >= '#{ACTIVE_JOB_START_DATE}'
      
      ORDER BY builder_users.id ASC 
    "
  end

  def self.missing_pn_query
    "
    SELECT    builder_jobs.project_number as builder_jobs_pn, 
              akon_teams.organization_id as organization_id, 
              akon_teams.name as team_name, 
              akon_teams.id as team_id, 
              akon_users.id as akon_user_id, 
              builder_users.id as builder_user_id, 
              builder_users.email as email, 
              builder_jobs.id as job_id, 
              markup_info.launch_date, 
              conversion_info.conversion_sum as job_cost, 
              markup_info.markup, 
              unit_total.unit_count,
              conversion_info.last_conversion as last_conversion
  
    FROM      builder_jobs
    JOIN      builder_users ON builder_users.id = builder_jobs.user_id
    JOIN      akon_users ON akon_users.id = builder_users.akon_id
    JOIN      akon_team_memberships ON akon_team_memberships.user_id = akon_users.id
    JOIN      akon_teams ON akon_teams.id = akon_team_memberships.team_id
    JOIN      (
                SELECT    MAX(builder_conversions.started_at) as last_conversion, 
                          builder_conversions.job_id, 
                          ROUND(SUM(builder_conversions.amount),3) as conversion_sum
                FROM      builder_conversions
                WHERE     external_type != 'cf_internal'
                GROUP BY  builder_conversions.job_id
              ) AS conversion_info
    ON        builder_jobs.id = conversion_info.job_id
    JOIN      (
                SELECT    max(builder_orders.markup) as markup, 
                          builder_orders.job_id, 
                          MIN(builder_orders.created_at) as launch_date
                FROM      builder_orders
                WHERE     builder_orders.type = 'Debit'
                GROUP BY  job_id
              ) AS markup_info
    ON        markup_info.job_id = builder_jobs.id
    JOIN      (
                SELECT    COUNT(builder_units.id) as unit_count, 
                          builder_units.job_id
                FROM      builder_units
                WHERE     builder_units.state = 9
                GROUP BY  builder_units.job_id
              )AS unit_total
    ON        unit_total.job_id = builder_jobs.id
  
    WHERE     builder_jobs.project_number = '#{pn}'
    AND       conversion_info.last_conversion >= '#{active_jobs_range}'
    ORDER BY  builder_users.id ASC 
    "
  end
end

class SalesForce < Query
  def get_results_hash
    @query_results.each_with_object({}) do |result, hash|
      hash[result["Project__r"].attrs["Name"]] =
      {
        # I would think of clearer symbol names here (the symbols are e_date, etc.)
        e_date: result.attrs["Earned_Date__c"],
        fee_type: result.attrs["Work_Order_Fee_Type__c"],
        name: result["Project__r"]["Account__r"].attrs["Name"],
        c_date: result["Project__r"].attrs["Target_Completion_Date__c"]
      }
    end
  end

  def run_query
    @connection.query( Query.sf_query )
  end
end

class RedShift < Query
  def initialize(pn, sf_result, full_report, pn_mismatch_report, query)
    super
    @pn = pn
    @full_report = full_report
    @pn_mismatch_report = pn_mismatch_report
    @sf_hash =
      {
        pn:                 pn,
        start_date:         ACTIVE_JOB_START_DATE,
        sf_name:            sf_result[:name],
        last_work_order:    sf_result[:e_date],
        fee_type:           sf_result[:fee_type],
        contract_exp_date:  sf_result[:c_date]
      }
  end

  def get_results_hash
    return if !has_ntuples?
    @query_results.each_with_object({}) do |result, summary_report|
      parsed = parse(result)
      consistent?(parsed) ? (summary_report = aggregate(parsed, summary_report)) : next
    end
  end

  def run_query
    @connection.query( query )
  end

  def aggregate(parsed, summary_report)
    summary_report = initialize_if_necessary(parsed, summary_report)
    {
      team_name: parsed[:team_name],
      emails: summary_report[:emails] + parsed[:email],
      job_counts: summary_report[:job_counts] + 1,
      unit_count: summary_report[:unit_count] + parsed[:finalized_units],
      crowd_cost: summary_report[:job_cost_with_markup] + parsed[:job_cost_with_markup],
      builder_organizations_pn: (summary_report[:builder_organizations_pn] + parsed[:builder_organizations_pn]).uniq,
      builder_jobs_pn: summary_report[:builder_jobs_pn] + parsed[:builder_jobs_pn]
    }
  end

  def initialize_if_necessary(parsed, summary_report)
    summary_report[:emails] ||= []
    summary_report[:job_counts] ||= 0
    summary_report[:unit_count] ||= 0
    summary_report[:crowd_cost] ||= 0
    summary_report[:builder_organizations_pn] ||= []
    summary_report[:builder_jobs_pn] ||= []
  end

  def consistent?(parsed)
    if parsed[:builder_organizations_pn] == parsed[:builder_jobs_pn]
      @full_report << (@sf_hash.values + parsed.values)
      true
    else
      @full_report << (@sf_hash.values + ["PN Mistmatch"])
      @pn_mismatch_report << (@sf_hash.values + parsed.values)
      false
    end
  end

  def has_ntuples?
    @query_results.ntuples > 0
  end

  def parse(result)
    {
      builder_organizations_pn: result["builder_organizations_pn"] ||= "Organization PN Not Found",
      builder_jobs_pn:          result["builder_jobs_pn"],
      organization_id:          result["organization_id"],
      team_name:                result["team_name"],
      team_id:                  result["team_id"],
      akon_user_id:             result["akon_user_id"],
      builder_user_id:          result["builder_user_id"],
      email:                    result["email"],
      job_id:                   result["job_id"],
      launch_date:              result["launch_date"],
      job_cost:                 result["job_cost"].to_f,
      markup:                   result["markup"].to_f,
      finalized_units:          result["unit_count"],
      last_conversion:          result["last_conversion"],
      job_cost_with_markup:     ( 1 + result["markup"].to_f / 100 ) * result["job_cost"].to_f
    }
  end

  def write_to_summary_report(summary_report_out)
    summary_report_out <<
    [
      @pn, 
      @results_hash[:team_name],
      @results_hash[:emails].length,
      @results_hash[:job_count],
      @results_hash[:total_cost],
      @results_hash[:total_unit_count]
    ]
  end

  def write_to_summary_report_no_pn_found(summary_report_out)
    summary_report_out << [@pn, @sf_hash[:sf_name], "PN Missing"]
  end
end

####################################
### ACTUAL PROCESSING TIME WOOOT ###
####################################

CSV.open(FULL_REPORT_NAME, "w", write_headers: true, headers: CSV_HEADERS) do |full_report|
  CSV.open(PN_MISMATCH_REPORT_NAME, "w", write_headers: true, headers: CSV_HEADERS) do |pn_mismatch_report|
    CSV.open(SUMMARY_REPORT_NAME, "w", write_headers: true, headers: SUMMARY_HEADERS) do |summary_report|
    
    sf_custom_object = SalesForce.new(client)
    sf_results = sf_custom_object.results_hash

    sf_results.each do |pn, sf_result|
      rs_result = RedShift.new(pn, sf_result, full_report, pn_mismatch_report, Query.rs_query(pn))
      
      if rs_result.has_ntuples?
        rs_result.write_to_summary_report(summary_report)
      else
        rescued_rs_result = RedShift.new(pn, sf_result, full_report, pn_mismatch_report, Query.missing_pn_query(pn))

        if rescued_rs_result.has_ntuples?
          rescued_rs_result.write_to_summary_report(summary_report)
        else
          rescued_rs_result.write_to_summary_report_no_pn_found(summary_report)
        end
        
      end
    end 
  end
end
