import csv
import json


input = '/Users/donblaine/Desktop/test.csv'
output = '/Users/donblaine/Desktop/test2.csv'
image_url_row_index = 0
anno_row_index = 1
# label_index = 5
test_questions = False
data_array = []
final_array = []
test_dict = {}
test_dict2 = {}

with open(input, 'r', newline='', encoding='utf-8') as (csvin):
    csvin = csv.reader(csvin, delimiter=',')
    next(csvin)
    sortedlist = sorted(csvin, key=lambda row: row[image_url_row_index],
                        reverse=True)
    link = ""

    for row in sortedlist:
        if test_questions and row[1] != "false":
            continue

        if link != row[image_url_row_index] and link != "":
            output_array = [link]
            output_array.append(json.dumps({"shapes": data_array}))
            final_array.append(output_array)
            data_array = []

    # only get annontations from correct boxes
        link = row[image_url_row_index]
        # if row[label_index] == "":
        #     continue
        print(row[anno_row_index])
        shape = json.loads(row[anno_row_index])["shapes"][0]
        # full_sku = row[11]
        # shape["label"] = full_sku
        data_array.append(shape)

    # write last valid line in csv to doc
    output_array = [link]
    output_array.append(json.dumps({"shapes": data_array}))
    final_array.append(output_array)

with open(output, 'w') as outcsv:
    writer = csv.writer(outcsv, delimiter=',')
    headers = ["image_url", "annotation"]
    writer.writerow(headers)

    i = 1
    for n in final_array:
        writer.writerow(n)
        print("Adding Row %s to CSV: " + str(i))
        i += 1
