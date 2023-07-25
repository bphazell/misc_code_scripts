require 'restforce'
require 'awesome_print'
require 'csv'
require 'pg'
require 'date'


# The jobs you want to view the had a conversion after a specified data. Ex: 2013-11-01
active_jobs_range = "2015-01-01"

time = Time.now.strftime("%Y-%m-%d")

#create index for SF results
INDICES = {
          sf_name: 0,
          last_work_order: 1,
          fee_type: 2,
          contract_exp_date: 3
        }


# Connect to SalesForce API
client = Restforce.new :username => 'andy@crowdflower.com',
:password => '1awesomepassword',
:security_token => 'fI3It3FCdoFuEYOixIin9gck9',
:client_id => '3MVG9yZ.WNe6byQADrJ.3pNJkp1YwOg43Fdw4JQr5dfRbJqpZGto6arY5uSxst8zS2dvewgiil7eiS5eF86ds',
:client_secret => '7380858972881717415'


results = client.query("
  SELECT Work_Order__c.Earned_Date__c, Work_Order__c.Work_Order_Fee_Type__c, Work_Order__c.Project__r.Name, 
    Work_Order__c.Project__r.Account__r.Name, Work_Order__c.Project__r.Target_Completion_Date__c
  FROM Work_Order__c
  WHERE Work_Order__c.Project__r.Target_Completion_Date__c >= #{time}
  ")

# Create a hash to store SF results
my_hash = {}

results.each do |item|
  e_date = item.attrs["Earned_Date__c"]
  fee_type = item.attrs["Work_Order_Fee_Type__c"]
  pn = item["Project__r"].attrs["Name"]
  name = item["Project__r"]["Account__r"].attrs["Name"]
  c_date = item["Project__r"].attrs["Target_Completion_Date__c"]
  my_hash[pn] = [name, e_date, fee_type, c_date]
end

# for testing
#my_hash["PN947"] = ["name", "edate", "fee_type", "c_date"]

# Connect to Redshift
redshift = PG.connect( 
dbname: 'matt_crowdflower', 
host: 'cf-redshift.etleap.com',
user: "matt_crowdflower",
password: 'wznvhKJVAC135299756',
port: 5439,
)

csv_headers =["salesforce_pn", "salesforce_account", "sf_last_work_order", "sf_fee_type", "contract_exp_date", "builder_organizations_pn",
  "builder_jobs_pn", "organization_id", "team_name", "team_id", "akon_user_id", 
  "builder_user_id", "email", "job_id", "launch_date", "job_cost_with_markup", "finalized_units", "last_conversion"]

  summary_headers = ["PN","organization_name","users", "number_of_launched_jobs", "total_crowdspend_with_markup", "total_finalized_units"]

#Create CSV for builder_organizations query results
  CSV.open("customer_taxonomy_full_report_#{time}.csv", "w", write_headers:true, headers:csv_headers) do |full_report|
    #Create CSV for builder_jobs query results
    CSV.open("customer_taxonomy_mismatched_pns_report_#{time}.csv", "w", write_headers:true, headers:csv_headers) do |pn_mismatch_report|
      # Create CSV for summary report
      CSV.open("customer_taxonomy_summary_#{time}.csv","w", write_headers:true, headers:summary_headers) do |summary_report|

      #Iterate through SF Hash to populate redshift query 
        my_hash.each do |pn, array|
          puts pn
          rs_query_build_org = redshift.query("
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
            FROM builder_organizations
            JOIN akon_teams on akon_teams.organization_id = builder_organizations.id
            JOIN (SELECT DISTINCT(akon_team_memberships.user_id), 
                   akon_team_memberships.team_id
                  FROM akon_team_memberships) AS team_member_info
                ON team_member_info.team_id = akon_teams.id
            JOIN builder_users on builder_users.akon_id = team_member_info.user_id
            JOIN builder_jobs on builder_jobs.user_id = builder_users.id
            JOIN (Select MAX(builder_conversions.started_at) as last_conversion, 
                  builder_conversions.job_id, 
                  ROUND(SUM(builder_conversions.amount),3) as conversion_sum
                          FROM builder_conversions
                          WHERE external_type != 'cf_internal'
                            GROUP BY builder_conversions.job_id) AS conversion_info
                        ON builder_jobs.id = conversion_info.job_id
            JOIN (SELECT max(builder_orders.markup) as markup, 
                  builder_orders.job_id,  
                  MIN(builder_orders.created_at) as launch_date
                  FROM builder_orders
                  WHERE builder_orders.type = 'Debit'
                  GROUP BY job_id) AS markup_info
                  ON markup_info.job_id = builder_jobs.id
            JOIN (SELECT COUNT(builder_units.id) as unit_count, 
                  builder_units.job_id
                    FROM builder_units
                   Where builder_units.state = 9
                   GROUP BY builder_units.job_id) AS unit_total
                  ON unit_total.job_id = builder_jobs.id
            WHERE builder_organizations.project_number = '#{pn}'
                AND conversion_info.last_conversion >= '#{active_jobs_range}'
            ORDER BY builder_users.id ASC 
          ")

          # salesforce values
          sf_name = array[INDICES[:sf_name]]
          last_work_order = array[INDICES[:last_work_order]]
          fee_type = array[INDICES[:fee_type]]
          contract_exp_date = array[INDICES[:contract_exp_date]]


          # if rs_query results are not empty for PN, fill csv with resutls
          if rs_query_build_org.ntuples > 0

              
              # for summary report
            for_agg = {}
            for_agg["emails"] = []
            for_agg["job_counts"] = 0
            for_agg["crowd_cost"] = []
            for_agg["unit_count"] = []
            for_agg["builder_organizations_pn"] = []
            for_agg["builder_jobs_pn"] = []

            rs_query_build_org.each do |tuple|  
            
              #redshift values
              builder_organizations_pn = tuple["builder_organizations_pn"]
              builder_jobs_pn = tuple["builder_jobs_pn"]
              organization_id= tuple["organization_id"]
              team_name = tuple["team_name"]
              team_id = tuple["team_id"]
              akon_user_id = tuple["akon_user_id"]
              builder_user_id = tuple["builder_user_id"]
              email = tuple["email"]
              job_id = tuple["job_id"]
              launch_date = tuple["launch_date"]
              job_cost = tuple["job_cost"].to_f
              markup = tuple["markup"].to_f
              finalized_units = tuple["unit_count"]
              last_conversion = tuple["last_conversion"]

              #calculate pricing with markup
              markup = 1 + (markup/100)
              job_cost_with_markup = job_cost * markup

               if builder_organizations_pn == builder_jobs_pn

                #write variables to full_report
                full_report << [pn, sf_name, last_work_order, fee_type, contract_exp_date, builder_organizations_pn, builder_jobs_pn, organization_id, team_name,team_id, akon_user_id, builder_user_id, email, job_id, launch_date, job_cost_with_markup, finalized_units, last_conversion]

              else 
                full_report << [pn, sf_name, last_work_order, fee_type, contract_exp_date, "PN Mismatch"]

                pn_mismatch_report << 
                  [pn, sf_name, last_work_order, fee_type, contract_exp_date, builder_organizations_pn, builder_jobs_pn, organization_id, team_name,team_id, akon_user_id, builder_user_id, email, job_id, launch_date, job_cost_with_markup, finalized_units, last_conversion]
              end 

              #compile info for sumamry_report
              for_agg["team_name"] = team_name
              for_agg["emails"] << email
              for_agg["job_counts"] += 1
              for_agg["unit_count"] << finalized_units.to_f
              for_agg["crowd_cost"] << job_cost_with_markup
              for_agg["builder_organizations_pn"] << builder_organizations_pn
              for_agg["builder_jobs_pn"] << builder_jobs_pn
            
            end
            # assingn variable names
            team_name = for_agg["team_name"]
            number_of_users = for_agg["emails"].uniq.length
            job_count = for_agg["job_counts"]
            job_cost = for_agg["crowd_cost"]
            unit_count = for_agg["unit_count"]
            builder_organizations_pn = for_agg["builder_organizations_pn"]
            builder_jobs_pn = for_agg["builder_jobs_pn"]
            #aggregate cost
            total_cost = job_cost.inject{|total_cost, x| total_cost + x}          
            #aggregate units
            total_unit_count = unit_count.inject{|unit_count, a| unit_count + a}

              if builder_organizations_pn == builder_jobs_pn

                #write variables to summary_report
                summary_report << [pn, team_name, number_of_users, job_count,total_cost, total_unit_count]

              else

                summary_report << [pn, team_name, "PN Mismatch"]

              end

          else
            # Take note where PNS are not present in builder_organizations

              

              # Run Query on missing PNs in builder_jobs 
              rs_query_build_jobs = redshift.query("
              SELECT builder_jobs.project_number as builder_jobs_pn, 
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
              FROM builder_jobs
                JOIN builder_users ON builder_users.id = builder_jobs.user_id
                JOIN akon_users ON akon_users.id = builder_users.akon_id
                JOIN akon_team_memberships ON akon_team_memberships.user_id = akon_users.id
                JOIN akon_teams ON akon_teams.id = akon_team_memberships.team_id
                JOIN (Select MAX(builder_conversions.started_at) as last_conversion, 
                    builder_conversions.job_id, 
                    ROUND(SUM(builder_conversions.amount),3) as conversion_sum
                                FROM builder_conversions
                                WHERE external_type != 'cf_internal'
                                GROUP BY builder_conversions.job_id) AS conversion_info
                              ON builder_jobs.id = conversion_info.job_id
                JOIN (SELECT max(builder_orders.markup) as markup, 
                      builder_orders.job_id, 
                      MIN(builder_orders.created_at) as launch_date
                      FROM builder_orders
                      WHERE builder_orders.type = 'Debit'
                      GROUP BY job_id) AS markup_info
                      ON markup_info.job_id = builder_jobs.id
                JOIN (SELECT COUNT(builder_units.id) as unit_count, 
                      builder_units.job_id
                        FROM builder_units
                        Where builder_units.state = 9
                        GROUP BY builder_units.job_id)AS unit_total
                      ON unit_total.job_id = builder_jobs.id
                WHERE builder_jobs.project_number = '#{pn}'
                  AND conversion_info.last_conversion >= '#{active_jobs_range}'
                ORDER BY builder_users.id ASC 
              ")
          # if build_jobs query is not empty, fill csv
            if rs_query_build_jobs.ntuples > 0

              full_report << [pn, sf_name, last_work_order, fee_type, contract_exp_date, "PN Mismatch"]

              rs_query_build_jobs.each do |tuple|

                #redshift values
                builder_organizations_pn = "Not Found"
                builder_jobs_pn = tuple["builder_jobs_pn"]
                organization_id= tuple["organization_id"]
                team_name = tuple["team_name"]
                team_id = tuple["team_id"]
                akon_user_id = tuple["akon_user_id"]
                builder_user_id = tuple["builder_user_id"]
                email = tuple["email"]
                job_id = tuple["job_id"]
                launch_date = tuple["launch_date"]
                job_cost = tuple["job_cost"].to_f
                markup = tuple["markup"].to_f
                finalized_units = tuple["unit_count"]
                last_conversion = tuple["last_conversion"]

                #calculate pricing with markup
                markup = 1 + (markup/100)
                job_cost_with_markup = job_cost * markup
    
                pn_mismatch_report << [pn, sf_name, last_work_order, fee_type, contract_exp_date, builder_organizations_pn, builder_jobs_pn, organization_id, team_name,team_id, akon_user_id, builder_user_id, email, job_id, launch_date, job_cost_with_markup, finalized_units, last_conversion]
              end

              summary_report << [pn, sf_name, "PN Mismatch"]
            else

                # Take note when PNs are not present in builder_jobs
                full_report << [pn, sf_name, last_work_order, fee_type, contract_exp_date, "Not Found"]
                summary_report << [pn, sf_name, "PN Missing"]
                pn_mismatch_report << [pn, sf_name, last_work_order, fee_type, contract_exp_date, "Not Found", "Not Found"] 

            end
          end
        end   
      end 
    end
  end

