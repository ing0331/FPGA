import cv2
import numpy as np
import time
import math
import matplotlib.pyplot as plt
def conbine_img(img_name,img1,img2,img3,img4):

    fig, axs = plt.subplots(2, 2, figsize=(10, 10))
    axs[0,0].imshow(img1, cmap='gray')
    axs[0,0].set_title('Original')
    axs[0,1].imshow(img2, cmap='gray')
    axs[0,1].set_title('Diff')
    axs[1,0].imshow(img3, cmap='gray')
    axs[1,0].set_title('Simulation')
    axs[1,1].imshow(img4, cmap='gray')
    axs[1,1].set_title('OpenCV')
    for ax in axs.flat:
        ax.axis('off')
    plt.subplots_adjust(wspace=0.1, hspace=0.01)
    plt.tight_layout()
    plt.savefig(img_name, dpi=300)
    plt.show()
def rowdata2img(path,shift_x,shift_y):
    # 開啟文件
    with open(path) as f:
        # 讀取文件中的所有行
        lines = f.readlines()
    # 將每一行的文本轉換為整數
    data = [int(line.strip().split(',')[0]) for line in lines]
    # 打印數據
    img_width = 640
    img_height = 480
    img = np.reshape(data,((img_height,img_width)))
    img = img.astype('uint8')
    img = np.roll(img, shift_x)
    img = np.roll(img, shift_y, axis=0)
    return img
ori_img = cv2.imread("D:\\GSlab_git_NAS\\HW8_Canny_BRam\\N06-Tutorial\\road_gray.bmp")
simulation_img = rowdata2img("D:\\Project_lab\\Vivado\\BRAM_Canny_T1\\BRAM_Canny_T1.srcs\\Canny_out.txt",-26,-6)
Sobel_img = rowdata2img("D:\\Project_lab\\Vivado\\BRAM_Canny_T1\\BRAM_Canny_T1.srcs\\sobel.txt",-11,-2)
NMS_img = rowdata2img("D:\\Project_lab\\Vivado\\BRAM_Canny_T1\\BRAM_Canny_T1.srcs\\NMS_data.txt",-16,-4)
# opencv_img = cv2.Canny(ori_img, 20, 255)

# diff = simulation_img^opencv_img
cv2.imshow('simulation_img',simulation_img)
cv2.imwrite('simulation_img.jpg',simulation_img)
cv2.imshow('Sobel_img',Sobel_img)
cv2.imshow('NMS_img',NMS_img)
# cv2.imshow('OpenCV_img',opencv_img)
# cv2.imshow('diff_img',diff)
# conbine_img('combine_img.jpg',ori_img,Sobel_img,NMS_img,simulation_img)
# conbine_img('combine_img.jpg',ori_img,diff,simulation_img,opencv_img)

cv2.waitKey(0)

