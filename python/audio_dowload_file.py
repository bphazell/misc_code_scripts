import wget
import csv
import os.path

#INPUTS
input_path = '/Users/aaronzukoff/Downloads/File Test/a1256066.csv'
output_path = '/Users/aaronzukoff/Downloads/Download Test/'
file_url_location = 38

#READ CSV
with open(input_path, 'r', newline='', encoding='utf-8') as (
        csvfile):

    source = csv.reader(csvfile)
    header = next(source)

#LOOP ROWS IN CSV
    for indx, row in enumerate(source):
        file_url = row[file_url_location]
        #DOWNLOAD URL
        wget.download(file_url, output_path)
        print(" File " + str(indx) + " Complete!")
