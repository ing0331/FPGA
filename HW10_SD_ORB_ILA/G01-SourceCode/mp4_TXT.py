import cv2

# Define parameters
sec = 0
count = 0
frameRate = 0.05
video_start = 150
video_end = 450
input_video_path = 'MLIO.mp4'

# Open the video file
vidcap = cv2.VideoCapture(input_video_path)


# Function to rotate an image
def rotate_image(image, angle):
    rows, cols, _ = image.shape
    rotation_matrix = cv2.getRotationMatrix2D((cols / 2, rows / 2), angle, 1)
    rotated_image = cv2.warpAffine(image, rotation_matrix, (cols, rows))
    return rotated_image


# Function to resize an image
def resize_image(image, width, height):
    resized_image = cv2.resize(image, (width, height))
    return resized_image


# Function to process and save a frame
def process_and_save_frame(image, count):
    # Rotate the image
    rotated_image = rotate_image(image, 55)
    # Resize the image to 240x240
    resized_image = resize_image(rotated_image, 240, 240)
    # Save the processed frame as an image
    cv2.imwrite("rot_frame" + str(count) + ".jpg", resized_image)
    # Convert to grayscale
    rot_gray = cv2.cvtColor(resized_image, cv2.COLOR_BGR2GRAY)
    # Save pixel data to a text file
    with open('mp4_240x240_rotate.txt', 'a') as file:
        for row in rot_gray:
            file.write(', '.join(map(str, row))+ ', ')  # Write the pixel values in one row


# Main loop to process frames
while True:
    vidcap.set(cv2.CAP_PROP_POS_MSEC, sec * 1000)
    success, image = vidcap.read()
    image = resize_image(image, 240, 240)
    if not success:
        break

    if video_end > count > video_start:
        # Save the original frame as an image
        cv2.imwrite("imageSlice" + str(count) + ".jpg", image)
        # Convert to grayscale
        gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
        # Save pixel data to a text file
        with open('mp4_240x240.txt', 'a') as file:
            for row in gray:
                file.write(', '.join(map(str, row)) + ', ')  # Write the pixel values in one row

        # Process and save the rotate frame
        process_and_save_frame(image, count)

        cv2.imshow('G_slice', image)

    count += 1
    sec += frameRate

    if cv2.waitKey(1) & 0xFF == ord('q'):
        break

# Release video capture and close all OpenCV windows
vidcap.release()
cv2.destroyAllWindows()
