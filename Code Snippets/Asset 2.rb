# save name of csv file
input_csv = ARGV[0]

job_number = input_csv.gsub(/\D/,"") # takes the numbers out of input_file
