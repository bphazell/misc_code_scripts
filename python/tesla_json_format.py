import csv
import json

input = 'tesla_bb_output_full.csv'
input2 = 'tesla_plss_output.csv'
output = 'bb_pxseg_processed.json'
final_dict = {}
pixel_dict = {}

with open(input2, 'r') as csvfile:
    source1 = csv.reader(csvfile)
    next(source1)

    for row in source1:
        anno = row[12]
        link = row[15]
        shape_url = json.loads(anno)['url']
        pixel_dict[link] = shape_url


with open(input, 'r') as csvfile:
    source1 = csv.reader(csvfile)
    next(source1)
    i = 0

    for row in source1:
        print("hello")
        ind_dict = {}
        link = row[14]
        anno = row[12]
        name = link.split("/")
        name = name[-1]
        ind_dict["original_im_path"] = link
        ind_dict["im_name"] = name

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
        if link in pixel_dict:
            ind_dict['inst_seg_mask'] = pixel_dict[link]
        else:
            ind_dict['inst_seg_mask'] = "no_url_found"
        final_dict[i] = ind_dict
        i += 1

with open(output, 'w') as outfile:

    json.dump(final_dict, outfile)
    print("Job completed")
