require 'pg'
require 'csv'
require 'ap'

REDSHIFT = PG.connect( 
dbname: 'matt_crowdflower', 
host: 'cf-redshift.etleap.com',
user: "matt_crowdflower",
password: 'wznvhKJVAC135299756',
port: 5439,
)

TIME = Time.now.strftime("%m_%d_%I:%M_%p")

CSV_HEADERS = ["pn_list_pn",
            "build_org_pn",
            "org_name",
            "org_id",
            "updated?"]

class UpdateBuilderPns
  def initialize(csv)
    @csv = csv
    @query_results = query_redshift
  end

  def parse_results
    @query_results.each do |tuple|
      pn_list_pn = tuple["pn_list_pn"]
      build_org_pn = tuple["build_org_pn"]
      org_name = tuple["org_name"]
      org_id = tuple["org_id"]
      markup = tuple["markup"]
      plan_name = tuple["plan_name"]
      organization_role = tuple["plan_name"]
      if pn_list_pn[2..-1].to_i < build_org_pn[2..-1].to_i
        puts "check pn_list: #{pn_list_pn} build_org_pn: #{build_org_pn}"
        @csv << [ pn_list_pn, build_org_pn, org_name, org_id, "check_pn"]
      else
        puts "PN Updated: #{pn_list_pn} build_org_pn: #{build_org_pn}"
        begin
          response = update_users_curl(pn_list_pn, org_name, org_id, markup, plan_name, organization_role)
         @csv << [ pn_list_pn, build_org_pn, org_name, org_id, "true"]
       rescue
        @csv << [ pn_list_pn, build_org_pn, org_name, org_id, "false"]
        end
      end
    end
  end


  def query_redshift
    REDSHIFT.query(
    "SELECT      pn_list.pn as pn_list_pn,
            builder_organizations.project_number as build_org_pn,
            pn_list.org_name,
            pn_list.org_id,
            MAX(builder_users.id),
            builder_organizations.markup,
            builder_plans.name as plan_name,
            (CASE 
              WHEN pn_list.org_id IN 
                (SELECT organization_id
                FROM akon_roles_organizations
                JOIN akon_roles ON akon_roles.id = akon_roles_organizations.role_id
                WHERE akon_roles.role_type_id = 47) THEN TRUE
              ELSE NULL
            END) as taxonomy_client
      FROM pn_list
       JOIN akon_team_memberships
         ON pn_list.team_id = akon_team_memberships.team_id
       JOIN builder_users
         ON builder_users.akon_id = akon_team_memberships.user_id
       JOIN builder_organizations 
         ON builder_organizations.id = pn_list.org_id
       JOIN builder_plans
         ON builder_users.plan_id = builder_plans.id
      WHERE CAST(REGEXP_SUBSTR(pn,'[^PN].+') AS numeric) IN
           (SELECT MAX(CAST(REGEXP_SUBSTR(pn,'[^PN].+') AS numeric)) AS pn_number
           FROM pn_list
           GROUP BY org_id) 
      AND pn_list.pn !=  builder_organizations.project_number
      AND plan_name != 'trial'
      AND plan_name != 'basic'
      GROUP BY
          pn_list.pn,
          builder_organizations.project_number,
          pn_list.org_name,
          pn_list.org_id,
          builder_organizations.markup,
          builder_plans.name,
          taxonomy_client
      ORDER BY org_name"
  )
  end

  def update_users_curl(pn_list_pn, org_name, org_id, markup, plan_name, organization_role)
     `curl 'https://make.crowdflower.com/admin/organizations/#{org_id}' -H 'Cookie: optimizelyEndUserId=oeu1374108277234r0.9156798699405044; __mauuid=7f8e3f8d-c9c1-4ca3-aae3-6797f5801d9e; hsfirstvisit=https%3A%2F%2Fcrowdflower.com%2Fblog%2F%3Fp%3D8945||1389216287356; _mkto_trk=id:890-IJH-613&token:_mch-crowdflower.com-1375891859232-44393; mp_64ad2f3568e7a95ebcbd535a4f424a18_mixpanel=%7B%22distinct_id%22%3A%20%2252c037b0-d0a5-0130-e6ed-22000a8c025d%22%2C%22%24initial_referrer%22%3A%20%22%24direct%22%2C%22%24initial_referring_domain%22%3A%20%22%24direct%22%2C%22mp_name_tag%22%3A%20%22bhazell%40crowdflower.com%22%2C%22%24search_engine%22%3A%20%22google%22%2C%22mp_keyword%22%3A%20%22https%3A%2F%2Ftasks.crowdflower.com%2Fchannels%2Fcf_internal%2Fjobs%2F209625%2Feditor_preview%22%7D; mp_34db428377e01b5101a5659c6ebdfa7e_mixpanel=%7B%22distinct_id%22%3A%20%22141c8b7d7f582-098e6a992-68132675-13c680-141c8b7d7f65bb%22%2C%22%24initial_referrer%22%3A%20%22%24direct%22%2C%22%24initial_referring_domain%22%3A%20%22%24direct%22%7D; olfsk=olfsk4495328636839986; hblid=ESUqDf9dm6c4aIIK6N49s3EeEWKppa8E; _sio=d1e7c14e-c5aa-4899-be89-09f325f019f0----23183; ajs_anonymous_id=%2223183%22; __zlcprivacy=1; user_segment=Prospect; mp_82b9518491269bbd6342e0a6fb9f259e_mixpanel=%7B%22distinct_id%22%3A%20140457%2C%22user_id%22%3A%2021599315%2C%22groups%22%3A%20%5B%0A%20%20%20%20%22All%22%2C%0A%20%20%20%20%22Odd%22%0A%5D%2C%22%24initial_referrer%22%3A%20%22%24direct%22%2C%22%24initial_referring_domain%22%3A%20%22%24direct%22%2C%22site_id%22%3A%20140457%2C%22tour_version%22%3A%205%2C%22junkAccount%22%3A%20false%2C%22site_host%22%3A%20%22communitysupport.crowdflower.com%22%7D; mp_00f02d597c642b7efab39759dac628ea_mixpanel=%7B%22distinct_id%22%3A%20%2252c037b0-d0a5-0130-e6ed-22000a8c025d%22%2C%22%24initial_referrer%22%3A%20%22http%3A%2F%2Fcoolstuff.crowdflower.com%2F%22%2C%22%24initial_referring_domain%22%3A%20%22coolstuff.crowdflower.com%22%2C%22__mps%22%3A%20%7B%7D%2C%22__mpso%22%3A%20%7B%7D%2C%22__mpa%22%3A%20%7B%7D%2C%22__mpap%22%3A%20%5B%5D%7D; optimizelySegments=%7B%22172094809%22%3A%22gc%22%2C%22172190267%22%3A%22false%22%2C%22172225027%22%3A%22direct%22%2C%22298794671%22%3A%22referral%22%2C%22298874097%22%3A%22false%22%2C%22298896012%22%3A%22gc%22%2C%22338723638%22%3A%22referral%22%2C%22338796251%22%3A%22false%22%2C%22339416244%22%3A%22gc%22%7D; optimizelyBuckets=%7B%22172111659%22%3A%22172095664%22%7D; _ok=7808-547-10-4236; _sid=cPpyBB1eX8bApADP9ZscbCtsJKsFpqcT; _builder_user_id=BAhpAo9a--c989c892adad250ea2e98555fe9f79b204dfed4e; _worker_ui_session=BAh7B0kiD3Nlc3Npb25faWQGOgZFVEkiJWYwNmIyODBlNmEyZWZlYWE1MzJiYzFmNmYxZGRhZjI4BjsAVEkiEF9jc3JmX3Rva2VuBjsARkkiMTl4WC9FR1ZTNGIxZ0lsZTN3RnBpbHJBbkljckREalFSWUhoNGh6Z1Q1Rkk9BjsARg%3D%3D--6a13e30ffac28a1fd8ea6bb3b942c38fbb5cc4ae; __utma=105072849.1211284818.1374012347.1424386827.1424407604.1782; __utmc=105072849; __utmz=105072849.1424407604.1782.969.utmcsr=make.crowdflower.com|utmccn=(referral)|utmcmd=referral|utmcct=/jobs/204975/preview; __utmv=105072849.worker_ui; _okac=885c15e23c4a290a52ffea8bc4902c80; _okla=1; _okbk=cd4%3Dtrue%2Cvi5%3D0%2Cvi4%3D1424714324863%2Cvi3%3Dactive%2Cvi2%3Dfalse%2Cvi1%3Dfalse%2Ccd8%3Dchat%2Ccd6%3D0%2Ccd5%3Daway%2Ccd3%3Dfalse%2Ccd2%3D0%2Ccd1%3D0%2C; _gat=1; _make_session=BAh7B0kiD3Nlc3Npb25faWQGOgZFVEkiJWU4NTdhZDdjNzEyNmYyZWYzZDRmMjdiNTUwMTAxNzBiBjsAVEkiEF9jc3JmX3Rva2VuBjsARkkiMS8rcncrV3pCaWhzOXF5aCs3dkkxc3J1N1pXSFpqODh1QXQ0ZHZpTTl0QnM9BjsARg%3D%3D--15f93a14329a3492140d5bc7268326c85f4c4c6d; ajs_group_id=null; ajs_user_id=23183; _ga=GA1.2.1211284818.1374012347; mp_e0fd08bd7e74d0bf03862bb8de3a5168_mixpanel=%7B%22distinct_id%22%3A%2023183%2C%22%24initial_referrer%22%3A%20%22%24direct%22%2C%22%24initial_referring_domain%22%3A%20%22%24direct%22%2C%22mp_name_tag%22%3A%20%22bhazell%40crowdflower.com%22%2C%22plan%22%3A%20%22admin%22%2C%22company%22%3A%20%22crowdflower%22%2C%22balance%22%3A%2015%2C%22first_name%22%3A%20%22Brian%22%2C%22last_name%22%3A%20null%2C%22lastName%22%3A%20null%2C%22team_admin%22%3A%20true%2C%22subscription_unit_limit%22%3A%20%22%22%2C%22subscription_units_used%22%3A%20172871%2C%22subscription_expires_at%22%3A%20%22%22%2C%22subscription_type%22%3A%20%22trial%22%2C%22title%22%3A%20null%2C%22phone_number%22%3A%20null%2C%22phone%22%3A%20null%2C%22id%22%3A%2023183%2C%22%24created%22%3A%20%222013-07-16T22%3A05%3A00.000Z%22%2C%22%24email%22%3A%20%22bhazell%40crowdflower.com%22%2C%22%24first_name%22%3A%20%22Brian%22%2C%22%24name%22%3A%20%22Brian%22%2C%22%24search_engine%22%3A%20%22google%22%2C%22mp_keyword%22%3A%20%22https%3A%2F%2Fcrowdflower.com%2Fjobs%2F685158%2Fcontributors%3Forder%3Djudgments%22%2C%22%24ignore%22%3A%20%22true%22%7D; _oklv=1424716241045%2C40aWD2x8jaiH5SbV6N49s5O0GXK525sE; __zlcmid=S5eFXu3FyFdOgw; __hstc=14529640.bb743abbae725dd601645001094acd40.1389216287361.1424477490742.1424714324310.1242; __hssrc=1; __hssc=14529640.19.1424714324310; hubspotutk=bb743abbae725dd601645001094acd40; olfsk=olfsk4495328636839986; wcsid=40aWD2x8jaiH5SbV6N49s5O0GXK525sE; hblid=ESUqDf9dm6c4aIIK6N49s3EeEWKppa8E; _ga=GA1.3.1211284818.1374012347' -H 'Origin: https://make.crowdflower.com' -H 'Accept-Encoding: gzip, deflate' -H 'Accept-Language: en-US,en;q=0.8' -H 'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_8_4) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/40.0.2214.115 Safari/537.36' -H 'Content-Type: application/x-www-form-urlencoded' -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8' -H 'Cache-Control: max-age=0' -H 'Referer: https://make.crowdflower.com/admin/organizations/4e9c4f02-6de3-4f7c-a70e-cb028928731e/edit' -H 'Connection: keep-alive' --data 'utf8=%E2%9C%93&_method=put&authenticity_token=%2F%2Brw%2BWzBihs9qyh%2B7vI1sru7ZWHZj88uAt4dviM9tBs%3D&akon_organization%5Bname%5D=#{org_name}&akon_organization%5Bmarkup%5D=#{markup}&akon_organization%5Bproject_number%5D=#{pn_list_pn}&akon_organization%5Bplan_name%5D=#{plan_name}&akon_organization%5Bauxiliary_role_names%5D%5B%5D=#{organization_role}&akon_organization%5Bauxiliary_role_names%5D%5B%5D=&commit=Save+Changes' --compressed`
  end
end

CSV.open("builder_users_updated_results_#{TIME}.csv", "w", headers: CSV_HEADERS, write_headers: true) do |csv|
  mismatch_pns = UpdateBuilderPns.new(csv)
  mismatch_pns.parse_results
end














