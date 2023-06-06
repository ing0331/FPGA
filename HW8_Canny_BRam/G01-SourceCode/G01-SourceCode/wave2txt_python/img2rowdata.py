import cv2
import numpy as np

img_path = "D:\\GSlab_git_NAS\\HW8_Canny_BRam\\N06-Tutorial\\road_org.jpg"
img = cv2.imread(img_path)
gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
with open('input_data.txt', 'w') as file:
    for row in gray:
        file.write(',\n'.join(map(str, row)) + '\n')
