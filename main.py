from math import cos, sin, pi
from time import sleep
from tkinter import *

import keyboard
from PIL import ImageTk
from keyboard import *

# Initiation of screen and gamestate
from filed import Field
from player import Player
from render import get_heights, create_image

HEIGHT = 480
WIDTH = 640


root = Tk()
root.geometry('{}x{}'.format(WIDTH, HEIGHT))
canvas = Canvas(root, width=WIDTH, height=HEIGHT)
canvas.pack(fill=BOTH)

player = Player(4, 4, 3.14159 / 4, 3.14159 / 3)
myMap = Field()

while (1):
    #moving or exiting if some keys pressed
    if is_pressed(keyboard.is_pressed("ESC")):
        sys.exit(-1)
    if is_pressed('w'):
        player.x -= 0.02 * cos(player.v_dir)
        player.y -= 0.02 * sin(player.v_dir)
    elif is_pressed("s"):
        player.x += 0.02 * cos(player.v_dir)
        player.y += 0.02 * sin(player.v_dir)
    elif is_pressed("d"):
        player.v_dir += 0.1
    elif is_pressed("a"):
        player.v_dir -= 0.1

    #player.v_dir -= 0.1
    # remove old images from canvas
    for k in canvas.children:
        try:
            k.destroy()
        except:
            pass
    heights = get_heights(myMap, player)
    # add image
    image = ImageTk.PhotoImage(create_image(heights))
    imagesprite = canvas.create_image(WIDTH/2, HEIGHT/2, image=image)
    canvas.update()
