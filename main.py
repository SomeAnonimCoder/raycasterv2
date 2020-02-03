from math import cos, sin
from tkinter import *

import keyboard
from PIL import ImageTk
from keyboard import *

# Initiation of screen and gamestate
from field import Field
from player import Player
from render import get_heights, create_image, render_map


HEIGHT = 480
WIDTH = 640


root = Tk()
root.geometry('{}x{}'.format(WIDTH, HEIGHT))
canvas = Canvas(root, width=WIDTH, height=HEIGHT)
canvas.pack(fill=BOTH)

player = Player(1.5, 1.5, 3.14159 / 4, 3.14159 / 3)
myMap = Field()

k=0

while 1:
    # #moving or exiting if some keys pressed
    # if is_pressed(keyboard.is_pressed("ESC")):
    #     print(k)
    #     sys.exit(-1)
    # if is_pressed('w'):
    #     player.x -= 0.05 * cos(player.v_dir)
    #     player.y -= 0.05 * sin(player.v_dir)
    # if is_pressed("s"):
    #     player.x += 0.05 * cos(player.v_dir)
    #     player.y += 0.05 * sin(player.v_dir)
    # if is_pressed("d"):
    #     player.v_dir += 0.1
    # if is_pressed("a"):
    #     player.v_dir -= 0.1

    player.v_dir -= 0.1

    k+=1
    if k>100: sys.exit(0)
    # remove old images from canvas
    for k in canvas.children:
        try:
            k.destroy()
        except:
            pass
    heights = get_heights(myMap, player)
    # add images
    map_img = ImageTk.PhotoImage(render_map(myMap, player))
    image = ImageTk.PhotoImage(create_image(heights))
    imagesprite = canvas.create_image(WIDTH/2, HEIGHT/2, image=image)
    mapsprite = canvas.create_image(map_img.width()/ 2, map_img.height() / 2, image=map_img)
    canvas.update()
