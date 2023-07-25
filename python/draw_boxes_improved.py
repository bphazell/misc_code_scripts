import csv
import urllib.request
import json
import cv2


# def draw_boxes(image_file_name, output, boxes ):
def draw_output(output_filename, boxes):

    img = cv2.imread(output_filename, cv2.IMREAD_COLOR)
    for box in boxes:
        cv2.rectangle(img, (box[0], box[1]),
                      (box[0]+box[2], box[1]+box[3]),
                      (0, 153, 255), 2)
        # font = cv2.FONT_HERSHEY_SIMPLEX
        # cv2.putText(img, box[4],
        #             (box[0], box[1]), font,
        #             0.7, (255, 255, 255), 2)
    cv2.imwrite(output_filename, img)
    print("img being created")


output = '/Users/donblaine/Desktop/test4/'
input = '/Users/donblaine/Desktop/inbev_job1_partial.csv'
with open(input,
          'r') as csvfile:
    source = csv.reader(csvfile)

    next(source)
    i = 0

    for row in source:
        anno = row[12]
        link = row[17]
        # test = row[1]
        # state = row[2]
        # test = row[1]
        # valid = row[2]
        # name = row[3]
        name = link.split("/")
        name = name[-1]
        # print(test)

        if anno != '' and anno != "[]":
            i += 1
            output_filename = output + str(i) + name
            print(output_filename)

            data = urllib.request.urlretrieve(link, output_filename)
            shapes = json.loads(anno)
            if "shapes" in anno:
                shapes = shapes['shapes']
            boxes = []

            for shape in shapes:
                x = int(shape["x"])
                y = int(shape["y"])
                height = int(shape["height"])
                width = int(shape["width"])
                # tag = str(shape["sku"])
                # if "tag" in shape:
                #     tag = str(shape["tag"])
                # else:
                #     tag = "No Tag"
                box = [x, y, width, height]
                boxes.append(box)
            draw_output(output_filename, boxes)