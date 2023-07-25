import csv
import json

input = 'Tesla_bb_full3.csv'
output = 'Tesla_bb_full3.json'

with open(input, 'r') as csvfile:
    source1 = csv.reader(csvfile)
    next(source1)
    final_dict = {}
    i = 0

    for row in source1:
        ind_dict = {}
        link = row[14]
        anno = row[12]
        name = link.split("/")
        name = name[-1]
        ind_dict["original_im_path"] = link
        ind_dict["output_im_path"] = name

        if anno != "" and anno != "[]":
            shapes = json.loads(anno)
            if "shapes" in anno:
                shapes = shapes['shapes']
            boxes = []
            for shape in shapes:
                shape_dict = {}
                width = shape['width']
                height = shape['height']
                x = shape['x']
                y = shape['y']
                shape_dict['x_2'] = x + width
                shape_dict['y_2'] = y + height
                shape_dict['y_1'] = y
                shape_dict['x_1'] = x
                boxes.append(shape_dict)

        ind_dict['rect'] = boxes
        final_dict[i] = ind_dict
        i += 1

with open(output, 'w') as outfile:

    json.dump(final_dict, outfile)
    print("Job completed")
