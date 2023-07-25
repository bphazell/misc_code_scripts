import argparse
import requests
import csv

ap = argparse.ArgumentParser()
ap.add_argument('--csv', required=True)
ap.add_argument('--outfolder', required=True)
args = vars(ap.parse_args())

f = open(args['csv'], 'r')
reader = csv.reader(f)
next(reader, None)
i = 0
for row in reader:
  try:
    print('downloading #' + str(i) + ': ' + row[1])
    img = requests.get(row[1], allow_redirects=True)
    uuid = row[0]
    path = args['outfolder'] + uuid + '.jpg'
    open(path, 'wb').write(img.content)
    i += 1
  except Exception as e:
    print(e)
    print(row)
    continue


