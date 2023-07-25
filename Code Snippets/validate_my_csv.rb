require_relative 'filevalidator'
require_relative 'fieldvalidator'

KEY = "5a3cbcfc1080dac9842caf7bce17f490f27fbee8" #this is arvel's

def subset?(this,other)
  this.each  do |x|
    if !(other.include? x)
      return false
    end
  end
  true
end

def clean_input_list(list_string)
  list_string.split(",").map { |header| header.gsub(/\"/,"").strip }.uniq
end

fields = FieldValidator.new

puts "\nPlease provide a direct path to the CSV you would like to validate (simply provide the filename if you are in the same directory):"

fields.csv.file = gets.chomp.to_s.strip

raise "Your file has duplicate headers." if fields.csv.duplicate_headers

available_validations = fields.list_validations

puts "\nThe following are all of the available headers in your csv:\n" # List the headers
puts fields.csv.headers                                                # so users don't have to open the csv

begin 
  puts "\nPlease list the field names (headers) from #{fields.csv.file} that you would like to validate (separated by commas):"

  field_names = clean_input_list(gets.chomp)

  if !subset?(field_names,fields.csv.headers)
    puts "OOPS! Please try again... The following header(s) do not exist: #{(field_names-fields.csv.headers).join(", ")}" 
    raise
  end
     
  fields.field_names = field_names
rescue
  retry
end

puts "\nThe following are all of the available validations:\n"
available_validations.each { |validation| puts validation }

fields.field_names.each do |field|
 
  puts "\nWhat validation(s) would you like (separated by commas) for column: #{field}"

  validations = clean_input_list(gets.chomp).map { |v| v.to_sym }

  if !subset?(validations,available_validations)
     puts "\nOOPS! Please try again... The following validation(s) do not exist: #{(validations-available_validations).join(", ")}\nTry copying and pasting directly from the list above, and make sure you separate multiple validators by commas."
     redo 
  end

  fields.add_validations(field,validations)
end

puts "\nStandby while we run your validations..."
result = fields.run_validations

if !result[:valid]
  puts "\nUH OH! We found some issues with your CSV."
else
  puts "\nYour CSV looks good to me! Would you like to upload it to your job? (y/n)"
  upload = gets.chomp
  if !(upload =~ /n/i) && (upload =~ /y/i)
    puts "\nPlease enter the job ID you would like to upload this to:"
    job = gets.chomp
    puts "\nUploading #{fields.csv.file} to job #{job}..."
    `curl -T '#{fields.csv.file}' -H 'Content-Type: text/csv' http://api.crowdflower.com/v1/jobs/#{job}/upload.json?key=#{KEY}`
  end
end

puts "\nDone! Check the output file for your results: #{result[:output_file]}\n\n"