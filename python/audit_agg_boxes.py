import csv
import urllib
import json
import matplotlib
from PIL import Image
import numpy
import cv2
import os


# Some things to note
# The script is slow because it downloads an image, draws the box, then moves on. For every 100 rows budget 3 to 5 minutes.
# Aaron Z has another copy of it and should be able to help debug
# You should hardcode the input filename and Index of the columns in the iterator below

# function to draw boxes onto an image, used later
def draw_output(input_filename, output_filename,boxes):
  img = cv2.imread(input_filename,cv2.IMREAD_COLOR)
  for box in boxes: 
    cv2.rectangle(img, (box[0],box[1]), (box[0]+box[2],box[1]+box[3]), (0, 153, 255),1)
    # on the above line you can change the RGB value of the box, and the width of the line. BTW its not RGB i think its GBR go figure
  cv2.imwrite(output_filename,img)
  print "Another one bites the dust %s" % output_filename

# in the open function below pass the file name that contains the boxes you want to draw
with open('a1028806.csv', 'rU') as csvfile:
  source = csv.reader(csvfile)

  next(source) 
  # this next does error handling in case the script is paused and resumed
  for row in source:
    # THIS IS IMPORTANT. PUT THE INDEX OF THE COLUMN FOR THE ANNOTATON AND URL
    unit = row[0]
    anno = row[5]
    link = row[9]
    agg = row[5]
    # sample output json [{u'active': True, u'height': 38, u'width': 13, u'y': 613, u'x': 1058, u'type': u'box', u'id': 1488265469}] 
    if anno != '' :
      # ignore empty annotations
      filename = "%s" % unit
      filename_raw = "%s.jpg" % unit
      # the name of the file you dl
      output_filename_indiv = filename+'_boxes_individual.jpg'
      output_filename_agg = filename+'_boxes_averaged.jpg'
      if os.path.exists(output_filename_indiv):
        continue
      urllib.urlretrieve(link, filename_raw)
      data = json.loads(anno)
      boxes = []
      shapes = data#["shapes"]
      for shape in shapes:
        x=int(shape["x"])
        y = int(shape["y"])
        height = int(shape["height"])
        width = int(shape["width"])
        box = [x,y,width,height] 
        boxes.append(box)
        # the int function below truncates the coordinates to an integer because Chris's tool sometimes creates floats lol
      # draw_output(filename_raw, output_filename_indiv, boxes)
      agg = json.loads(anno)
      # agg_list = [int(agg["x"]), int(agg["y"]), int(agg["width"]), int(agg["height"])]
      # draw_output(filename_raw, output_filename_agg, [agg_list])
      for shape in agg:
        x=int(shape["x"])
        y = int(shape["y"])
        height = int(shape["height"])
        width = int(shape["width"])
        box = [x,y,width,height] 
        boxes.append(box)
      draw_output(filename_raw, output_filename_agg, boxes)






