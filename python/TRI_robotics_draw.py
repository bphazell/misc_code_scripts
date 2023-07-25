import csv
import urllib
import json
import cv2
try:
    from urllib.parse import urlparse
except ImportError:
     from urlparse import urlparse

# ********************** INPUT AREA ***********************
output = '/Users/jessicawong/Desktop/images/'
input = '/Users/jessicawong/Downloads/a1243403_original.csv'
# specify column numbers for annotation and image url
fork_index = 4
spoon_index = 6
knife_index = 5
unknown_index = 7
utensil_type = 8
link_index = 12
unit_id = 0
# set to TRUE if test_questions are in report
test_questions = False
# ********************** END INPUT AREA ***********************


def add_box(shape):
    x = int(shape["x"])
    y = int(shape["y"])
    height = int(shape["height"])
    width = int(shape["width"])
    if "tag" in shape:
        tag = str(shape["tag"])
    else:
        tag = ""
    box = [x, y, width, height, tag]
    return box


def draw_output(output_filename, boxes, lines, dots):
    img = cv2.imread(output_filename, cv2.IMREAD_COLOR)
    for box in boxes:
        cv2.rectangle(img, (box[0], box[1]),
                      (box[0]+box[2], box[1]+box[3]),
                      (0, 153, 255), 2)
        if box[4] != "":
            font = cv2.FONT_HERSHEY_SIMPLEX
            cv2.putText(img, box[4],
                        (box[0], box[1]), font,
                        0.7, (255, 255, 255), 2)
    for dot in dots:
        cv2.circle(img, (dot[0], dot[1]), 2, (57, 255, 20), 2)
        if dot[2] != "":
            font = cv2.FONT_HERSHEY_SIMPLEX
            cv2.putText(img, dot[2],
                        (dot[0], dot[1]), font,
                        0.5, (0, 0, 255), 1)
    for point in lines:
        start = False
        initial = True
        prex = 0
        prey = 0
        for x, y in zip(point[0], point[1]):
            if start:
                cv2.line(img, (prex, prey), (x, y), (255, 0, 0), 2)
                if initial and point[2] != "":
                    font = cv2.FONT_HERSHEY_SIMPLEX
                    cv2.putText(img, point[2], (x, y), font,
                                0.7, (0, 0, 255), 2)
                    initial = False
                prex = x
                prey = y
            else:
                start = True
                prex = x
                prey = y

    cv2.imwrite(output_filename, img)
    print("img being created")


with open(input,
          'r') as csvfile:
    source = csv.reader(csvfile)

    next(source)

    for row in source:
        if row[utensil_type] == "fork":
            anno = row[fork_index]
        elif row[utensil_type] == "spoon":
            anno = row[spoon_index]
        elif row[utensil_type] == "knife":
            anno = row[knife_index]
        else:
            anno = row[unknown_index]
        link = row[link_index]
        name = row[unit_id] + ".png"
        # name = link.split("/")
        # name = name[-1]
        name = urllib.unquote(name)

        if test_questions:
            if row[1] == "true":
                print("skipping test question row")
                continue

        if anno != '' and anno != "[]":
            output_filename = output + name
            print(output_filename)

            data = urllib.urlretrieve(link, output_filename)
            shapes = json.loads(anno)
            if "shapes" in anno:
                shapes = shapes['shapes']
            boxes = []
            dots_arr = []
            points_arr = []

            for shape in shapes:
                if "type" in shape:
                    if shape['type'] == "poly":
                        x = []
                        y = []
                        if "tag" in shape:
                            tag = shape["tag"]
                        else:
                            tag = ""
                        points = shape["points"]
                        j = 1
                        for point in points:
                            if j % 2 == 0:
                                y.append(point)
                            else:
                                x.append(point)
                            j += 1
                        line = [x, y, str(tag)]
                        points_arr.append(line)

                    if shape['type'] == "dots":
                        dots = shape['dots'][0]
                        x = int(dots["x"])
                        y = int(dots["y"])
                        if "tag" in shape:
                            tag = str(shape["tag"])
                        else:
                            tag = ""
                        dot = [x, y, tag]
                        dots_arr.append(dot)

                    elif shape['type'] == "box":
                        boxes.append(add_box(shape))
                else:
                    boxes.append(add_box(shape))
            draw_output(output_filename, boxes, points_arr, dots_arr)
