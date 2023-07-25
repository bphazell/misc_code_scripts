
require 'json'
require 'crowdflower'
require 'nokogiri'

job_id = ARGV[0].to_s # job that wiil be made into a golddigging job

auth_key = ENV['CF_GOLD_ACCOUNT_API_KEY']
domain_base = "https://api.crowdflower.com/"

CrowdFlower::Job.connect! auth_key, domain_base

def download_json(job_id, auth_key)
  filename = "/tmp/job_#{job_id}.json"
  json = `curl https://api.crowdflower.com/v1/jobs/#{job_id}.json?key=#{auth_key}`
  parsed_json = JSON.parse(json)
  return parsed_json
end

original_json = download_json(job_id, auth_key)
original_cml = original_json["problem"] || ""
original_instructions = original_json["instructions"] || ""
original_css = original_json["css"] || ""
original_title = original_json["title"] || ""

# add the "gold section" to instructions
new_css = ".background-yellow { background-color: #ffcb02; }" + "\n" + original_css
new_instructions = "<div class='background-yellow'>\n<p>Dear Contributor,<br>This is a special Gold Digging task! We appreciate your careful work on this one. <br>Thanks a lot for your help and Good Luck!</p>\n</div>\n" + original_instructions
new_title = 'GOLD: ' + original_title

def add_reasons_to_cml(cml_string)
  # find cml questions in problem, remeber their starting and ending indices
  # cml_html = Nokogiri::XML(cml_string)
  # p cml_html
  in_element = false # in opening tag
  in_multiline = false
  num_elements = 0
  this_tag = ""
  all_tags = Array.new
  opening = ""
  whole_element = ""
  all_openings = Array.new
  all_whole_elements = Array.new
  closing_tag = "cml:nil"

  cml_string.each_line do |line|
    #p "found " + line.match(/<cml\:/).to_s
    #p "" + line.match(/<cml\:html/).to_s
    if ((in_multiline==false) && (in_element==false) && line =~ /<cml\:/ && !(line =~ /^<!--/) && !(line =~ /<cml\:html/) && !(line =~ /<cml\:group/) && !(line =~ /<cml\:hidden/))  # read in the <cml:*> row, excluding cml:html & !line.grep(/<cml\:html/)
      # p "this tag is open"
      this_tag = line.strip.split(/\s+/,5)
      # p this_tag
      this_tag = this_tag.select {|word| word[/cml/]}[0]
      this_tag = this_tag.gsub('<', '').gsub('>', '')
      closing_tag = '<\/' + this_tag + '>'
      # puts this_tag
      all_tags = all_tags + [this_tag]
      # activate booleans
      in_element = true
      in_multiline = true
      # add to elements
    end
    if ((in_element == true) && (line.match(/\/>/) || line.match(/#{closing_tag}/)))  # finih reading the cml row #is this the last row of this element?
      #puts "closing tag " + this_tag
      opening = opening + line
      whole_element = whole_element + line
      all_openings = all_openings + [opening]
      all_whole_elements = all_whole_elements + [whole_element]
      num_elements += 1
      #reset everything
      in_element = false
      in_multiline = false
      opening = ""
      whole_element = ""
      closing_tag = "cml_nil"
    elsif ((in_element == true) && line.match(/>/))
      opening = opening + line
      whole_element = whole_element + line

      all_openings = all_openings + [opening]
      # set element to false
      in_element = false
    elsif ((in_multiline == true) && line.match(/#{closing_tag}/))
      whole_element = whole_element + line
      all_whole_elements = all_whole_elements + [whole_element]
      num_elements += 1
      in_multiline = false
      in_element = false
      opening = ""
      whole_element = ""
    elsif (in_multiline == true)
      whole_element = whole_element + line
      if (in_element == true)
        opening = opening + line
      end
    end
    #p num_elements
  end
  # if your cml ended with element closed with >, the job doesn't break: checl for negative in_multiline
  if (in_multiline == true)
    all_whole_elements = all_whole_elements + [whole_element]
  end


  # each reason is constructed from scratch: <cml>; name; label; logic; validates; aggregateion=all
  for i in 0..(all_whole_elements.length-1)
    first_line = all_openings[i]
    my_tag = all_tags[i]
    reason_line = "<cml:textarea"
    ########################################################
    initial_name = first_line.scan(/name="([^"]*)"|name='([^"]*)'/)
    puts initial_name
    if initial_name.compact.empty?
      initial_name = ""
      #maybe insert label as the name
    else
      initial_name = initial_name.compact[0][0].to_s
      puts initial_name
      this_name = initial_name + "_crowdreason"
      reason_line = reason_line + " name=\"" + this_name + "\" "
    end
    ########################################################
    initial_label = first_line.scan(/label="([^"]*)"|label='([^"]*)'/)
    if initial_label.compact.empty?
      initial_label = ""
      #p " no label for tag" + my_tag
    else
      initial_label = initial_label.compact[0].to_s
      #p "initial label is " + initial_label
      this_label = "Explain Why Your Answer Above is Correct (Test Question Explanation):"
      default_value = "A good explanation will tell users why the answer(s) selected is correct AND why other answers are incorrect. Please type in complete sentences and use your best English. Remember, the goal is to be educational. Do not just repeat the correct answer."
      reason_line = reason_line + " label=\"" + this_label + "\" " + "default=\"" + default_value + "\" "
    end
    ########################################################
    initial_logic = first_line.scan(/only\-if="([^"]*)"|only\-if='([^"]*)'/)
    # initial logic is the text between the quotes of only-if
    if initial_logic.compact.empty?
      initial_logic = ""
      # there is no "only-if"
      if !(first_line =~ /only-if/)
        this_logic = " only-if=\"" + initial_name + "\""
        logic_plus_cml = "<cml:textarea" + this_logic
        reason_line = reason_line.gsub("<cml:textarea", logic_plus_cml)
        #p logic_plus_cml
        # the line contains only-if=""
      else
        initial_logic = initial_logic.compact[0][0].to_s
        this_logic = "only\-if=\"" + initial_name + "\""
        reason_line = reason_line + " " + this_logic + " "
        #p this_logic
      end
      # initial logic is not empty - hence there's a working only-if statement there
    else
      initial_logic = initial_logic.compact[0][0].to_s
      #p "i'm where you think now"
      this_logic = "only-if=\"" + initial_logic + "\+\+" + initial_name + "\""
      if (my_tag =~ /taxonomy/)
        this_logic = "only-if=\"" + initial_logic + "\""
      end
      old_logic = "only-if=\"" + initial_logic + "\""
      reason_line = reason_line + " " + this_logic + " "

      #p this_logic
    end
    if ((my_tag =~ /taxonomy/) || (my_tag =~ /text/))
      multiples = " multiple=\"true\""
    else
      multiples = ""
    end
    reason_line = reason_line + " validates=\"required\"></cml:textarea>"
    ########################################################
    augmented_question = all_whole_elements[i] + "\n<br>\n" + reason_line + "\n"
    cml_string = cml_string.gsub(all_whole_elements[i], augmented_question)

    #cml_string = cml_string.gsub("validates=\".*\"", "validates=\"required\"")

  end

  cml_string = "<cml:checkbox label=\"This is not a good Gold unit, I'd like to skip it.\" name='skip'></cml:checkbox>" + "\n" +
    "<cml:textarea only-if=\"!skip:unchecked\" name=\"skip_reason\"  label=\"Why is this not a good test question?\"  validates=\"required\"></cml:textarea>" + "\n" +
    "<cml:group name='gold_group' label='' only-if='skip:unchecked'>" + "\n" + cml_string + "\n" + "</cml:group>"

  cml_string = cml_string.gsub("cml:radios", "cml:checkboxes")
  cml_string = cml_string.gsub("cml:radio", "cml:checkbox")
  cml_string = cml_string.gsub("<cml:text ", "<cml:text multiple=\"true\" ")
  cml_string = cml_string.gsub("<cml:taxonomy ", "<cml:taxonomy multi-select=\"true\" ")

  #puts cml_string
  return cml_string # as text
end

new_cml = add_reasons_to_cml(original_cml)
puts new_cml
puts ""
puts "nnewlinenewlinethisisanewline"
puts ""

# copy job with all units and note id
# filename = "/tmp/_#{job_id}.json"
#p "copying job"
copy_json = `curl "https://api.crowdflower.com/v1/jobs/#{job_id}/copy.json?key=#{auth_key}&all_units=true&gold=false"`
# read in, get id, remove file
# copy_json = File.read(filename)
copy_parsed_json = JSON.parse(copy_json)
# `rm #{filename}`
new_id = copy_parsed_json["id"]
#p new_id # new_job_resource.copy instead of curl
puts new_id.to_s


# grab job
new_job_resource = CrowdFlower::Job.new(new_id)


#units per assignment = 1
new_job_resource.update({:units_per_assignment => 1})
new_job_resource.update({:pages_per_assignment => 1})
#judgments per unit is 1 sharp
new_job_resource.update({:variable_judgments_mode => "none" })
# judgments per unit -> 1
new_job_resource.update({:judgments_per_unit => "1" })
#no quiz mode
new_job_resource.update({:options => {:front_load => false } })
#after gold nothing
new_job_resource.update({:options => {:after_gold => "0" } })
# reject at 0
new_job_resource.update({:options => {:reject_at => "0" } })
# warn at 0
new_job_resource.update({:options => {:warn_at => "0" } })
# reset all country restrictions, and channels, and skill requirements
new_job_resource.update({:included_countries => nil })
new_job_resource.update({:excluded_countries => nil })
#save or print out new id and status
# IMPORTANT: set requirements to golddigging crowd
new_job_resource.update({:desired_requirements => {}.to_json })
new_job_resource.update({:minimum_requirements => {:priority => 1, :skill_scores => {:goldbusters => 1}, :min_score => 1}.to_json })
# don't flag on anything
new_job_resource.update({:flag_on_rate_limit => false })
# remove webhook
new_job_resource.update({:flag_on_rate_limit => nil })
new_job_resource.update({:auto_order => false })
# remove min account age
new_job_resource.update({:minimum_account_age_seconds => "0" })
# enable all channels
# p "channels" # new_job_resource.channels
channel_json = `curl -X GET "https://api.crowdflower.com/v1/jobs/#{new_id}/channels?key=#{auth_key}"`
#channel_json = File.read(filename)
channel_parsed_json = JSON.parse(channel_json)
available_channels = channel_parsed_json["available_channels"]
#set compensation to smth
new_job_resource.update({:payment_cents => 10 })

# order on all channels
#curl -d 'key={api_key}&channels[0]=amt&channels[0]=sama&debit[units_count]=20' https://api.crowdflower.com/v1/jobs/{job_id}/orders.json
`curl -H "Content-Type: application/json" -X PUT 'https://api.crowdflower.com/v1/jobs/#{new_id}/gold.json?key=#{auth_key}' -d '{"reset": true}'`
#golds per assignment = 0
new_job_resource.update({:gold_per_assignment => 0})

#update cml on that job
new_job_resource.update({:cml => new_cml})
new_job_resource.update({:instructions => new_instructions})
new_job_resource.update({:css => new_css})
new_job_resource.update({:title => new_title})

# << catch errors in this part
