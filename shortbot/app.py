import subprocess
from tkinter import Canvas, Tk, Toplevel

import cv2
import pytesseract
from pytesseract import Output


def take_screenshot():
    subprocess.run(["scrot", "screenshot.png"])


def perform_ocr():
    image = cv2.imread("screenshot.png")
    return pytesseract.image_to_data(image, output_type=Output.DICT)


def on_key_press(event, x, y):
    if event.char == "c":  # Example shortcut 'c' for click
        subprocess.run(["xdotool", "mousemove", str(x), str(y), "click", "1"])


def create_overlay(ocr_data):
    root = Tk()
    root.attributes("-fullscreen", True)
    root.attributes("-alpha", 0.3)
    canvas = Canvas(root, bg="black")
    canvas.pack(fill="both", expand=True)

    n_boxes = len(ocr_data["level"])
    for i in range(n_boxes):
        (x, y, w, h) = (
            ocr_data["left"][i],
            ocr_data["top"][i],
            ocr_data["width"][i],
            ocr_data["height"][i],
        )
        text = ocr_data["text"][i]
        if text.strip():
            canvas.create_rectangle(x, y, x + w, y + h, outline="red", tags=(x, y))
            canvas.tag_bind((x, y), "<Key>", lambda e, x=x, y=y: on_key_press(e, x, y))
            canvas.tag_bind(
                (x, y), "<Button-1>", lambda e, x=x, y=y: on_key_press(e, x, y)
            )

    root.mainloop()


def main():
    take_screenshot()
    ocr_data = perform_ocr()
    create_overlay(ocr_data)


if __name__ == "__main__":
    take_screenshot()
    ocr_data = perform_ocr()
    create_overlay(ocr_data)
