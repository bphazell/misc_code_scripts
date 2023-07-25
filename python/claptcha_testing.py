import random
import string
from PIL import Image
from claptcha import Claptcha

### NEEDS TO BE PYTHON 3 ###


# os.chdir("python/")

def randomString():
    rndLetters = (random.choice(string.ascii_uppercase) for _ in range(6))
    return "".join(rndLetters)
    

# Initialize Claptcha object with random text, FreeMono as font, of size
# 250x75px, using bicubic resampling filter and adding a bit of white noise

c = Claptcha(randomString, "captcha.ttf", (250,75),
             resample=Image.BICUBIC,noise=0.3)

no_images=int(input("How many images do you need? "))
for i in range(1,no_images+1):
	image_name='captcha'+ str(i) +'.png'
	text, _ = c.write(image_name)
	print(text + "->" + image_name)  
