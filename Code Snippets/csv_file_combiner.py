# import libraries

import csv
import os
import string

master_row_list = [] # list of row dictionaries
master_key_list = []
rows_processed = 0

file_count = 1
while True:
	print "Enter file number", file_count, "(.txt or .tsv for TAB separated (defaults to .csv), 'stop' to stop adding files, NO SPACES IN DIRECTORY PATH!):"
	source_path = string.strip(raw_input('--> '))
	
	if source_path == 'stop' or source_path == '':
		break
		
	try:
		source_file = open(source_path, "rU")
	except IOError:
		print "Sorry, that file doesn't exist. Check the pathname for accuracy."
		continue
		
	# os.path.split returns a tuple of (a,b) where b is file name and a is directory where b lives
	# os.path.splitext returns a tuple of (a,b) where b is extension (INCLUDING PERIOD) and a is no extension
	# e.g. split_path[1] is file name and os.path.splitext(split_path[1])[0] is file name without extension
	split_path = os.path.split(source_path)
	source_file_name = os.path.splitext(split_path[1])[0]
	source_file_ext = os.path.splitext(split_path[1])[1]
	cwd = split_path[0] # current working directory where source file lives
	
	if source_file_ext.lower() == '.txt' or source_file_ext.lower() == '.tsv':
		delimiter_char = '\t'
	elif source_file_ext.lower() == '.csv':
		delimiter_char = ','
	else: # default to CSV
		delimiter_char = ','

	source_reader = csv.reader(source_file, dialect='excel', delimiter=delimiter_char)

	# get headers, and make our reader a DictReader to use those headers
	source_headers = source_reader.next()
	# this actually changes the list in memory, or so testing shows...
	for i in range(0, len(source_headers)):
		source_headers[i] = source_headers[i].lower()
	
	source_reader = csv.DictReader(source_file, source_headers, dialect='excel', delimiter=delimiter_char)
	
	for row in source_reader:
		master_row_list.append(row)
		rows_processed += 1
				
	# add unique keys to the master_key_list
	for key in source_headers:
		if key not in master_key_list:
			master_key_list.append(key)
	
	print "Processed file " + str(file_count) + ": " + source_file_name
	
	print "Source headers in " + source_file_name + ": "
	for item in sorted(source_headers): print item
	print "Master header list after file " + str(file_count) + ", " + source_file_name + ": "
	for item in sorted(master_key_list): print item
	file_count += 1
	continue
	
print "Enter the name of the new file to create, including extension ( use '.txt' or '.tsv' for TAB separated, '.csv' for COMMA separated. Will default to CSV. NO SPACES!): "
print "The file will be created in this directory: " + os.getcwd()

new_file_name_ext = string.strip(raw_input('--> '))
file_name_tup = new_file_name_ext.rpartition('.') # rpartition creates a tuple (a,b,c) splitting at last occurence of separator '.' - in this case c is extension and a is name
new_file_name = file_name_tup[0]
extension = file_name_tup[2]

cwd = os.getcwd()
file_path = os.path.join(cwd, new_file_name_ext)

print "new file path: " + file_path

if extension.lower() == 'txt' or extension.lower() == 'tsv':
	delimiter_char = '\t'
elif extension.lower() == 'csv':
	delimiter_char = ','
else: # default to CSV
	delimiter_char = ','
	
writer = csv.DictWriter(open(file_path, 'w'), master_key_list, delimiter=delimiter_char, extrasaction='ignore')

# in Python v2.7 there is a new writeheaders() method. This is the old way.
#headers = {}
#for key in writer.fieldnames:
#    headers[key] = key
#writer.writerow(headers)

# new way to write headers in v2.7
writer.writeheader()

print "Headers in combined file: "
for h in writer.fieldnames: print h

rows_written = 0
error_rows = 0

for row in master_row_list:
	try:
		writer.writerow(row)
		rows_written += 1
	except TypeError:
		print "Error processing this row: "
		print row
		error_rows += 1

print "Created " + new_file_name_ext + " in " + cwd
print str(rows_processed) + " rows read across all files"
print str(rows_written) + " out of " + str(len(master_row_list)) + " rows written to new file"
print str(error_rows) + " rows with errors"
