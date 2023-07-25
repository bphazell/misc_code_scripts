import random
import string
import pandas as pd
from PIL import Image
from claptcha import Claptcha
import csv

def randomString():
    rndLetters = (random.choice(string.ascii_uppercase) for _ in range(6))
    return "".join(rndLetters)

# Initialize Claptcha object with random text, FreeMono as font, of size
# 250x75px, using bicubic resampling filter and adding a bit of white noise
c = Claptcha(randomString, "captcha.ttf", (250,75),
             resample=Image.BICUBIC,noise=0.3)

aws_path = "http://cf-public-view.s3.amazonaws.com/captcha/"
no_images=int(input("How many images do you need? "))	

with open('captcha_output.csv', 'w') as csvfile:
	writer = csv.writer(csvfile, delimiter=',')
	writer.writerow(["captcha_value", "image_name", "image_path"])
	for i in range(1,no_images+1):
		image_name='captcha'+ str(i) +'.png'
		text, _ = c.write(image_name)
		writer.writerow([text,image_name, aws_path + image_name])
		print(text + "->" + image_name)  
