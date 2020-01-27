from math import cos, tan, sqrt, sin, pi

import PIL.Image, PIL.ImageDraw
import numpy as np

from filed import Field
from player import Player

H = 1
HEIGHT = 480
WIDTH = 640


def render_map(map: Field, player):
    h = 20
    frame = PIL.Image.new(size=[map.size()[0] * h, map.size()[1] * h], mode="P", color="White")
    img = PIL.ImageDraw.Draw(frame)
    for i in range(0, map.size()[0]):
        for j in range(0, map.size()[1]):
            if not map.is_empty([i, j]):
                img.rectangle([i * h, j * h, (i + 1) * h, (j + 1) * h], fill="#cccccc")
    img.rectangle([player.x * h, player.y * h, player.x * h + 5, player.y * h + 5], fill="RED")
    img.line(
        [player.x * h, player.y * h, (player.x - 1 * cos(player.v_dir)) * h, (player.y - 1 * sin(player.v_dir)) * h],
        fill="RED")
    return frame


# get array of heights for each pixel column
def get_heights(field, player):
    heights = []
    # for ray in field of view
    for i in range(0, WIDTH):
        alpha = player.v_dir - player.v_field / 2 + player.v_field * i / WIDTH
        k = tan(alpha)
        y_0 = player.y - k * player.x

        collisions = []
        # for each cell in map
        for i in range(0, field.size()[0]):
            for j in range(0, field.size()[1]):

                if field.is_empty([i, j]): continue
                x, y, dist = block_cross(i, j, k, y_0, alpha, player)
                collisions.append([x, y])

        # select the closest collision of all
        dist = 1000 * H
        for collision in collisions:
            if None in collision: continue
            tmp = sqrt((collision[0] - player.x) ** 2 + (collision[1] - player.y) ** 2)
            if tmp < dist:
                dist = tmp
        heights.append(1 / dist / cos(-alpha + player.v_dir)*field.get_height(i,j) if 0 != dist else 1000)
    return heights


# count coordinates of collision with block(i,j) for ray y = y_0 + kx
def block_cross(i, j, k, y_0, alpha, player):
    # cell coordinates
    x_cell = i * H
    y_cell = j * H

    # find collision points
    collisions = []

    if k != 0:
        x = (y_cell - y_0) / k
        y = y_cell
        if x_cell <= x <= x_cell + H and (x - player.x) / cos(alpha) < 0:
            collisions.append((x, y))

    if k != 0:
        x = (y_cell + H - y_0) / k
        y = y_cell + H
        if x_cell <= x <= x_cell + H and (x - player.x) / cos(alpha) < 0:
            collisions.append((x, y))

    x = x_cell
    y = y_0 + x * k
    if y_cell <= y <= y_cell + H and (x - player.x) / cos(alpha) < 0:
        collisions.append((x, y))

    x = x_cell + H
    y = y_0 + (x) * k
    if y_cell <= y <= y_cell + H and (x - player.x) / cos(alpha) < 0:
        collisions.append((x, y))

    # print(collisions)
    # select the closest collision for the block
    dist = 1000 * H
    x = None
    y = None
    for collision in collisions:
        tmp = sqrt((collision[0] - player.x) ** 2 + (collision[1] - player.y) ** 2)
        if tmp < dist:
            dist = tmp;
            x = collision[0]
            y = collision[1]

    return x, y, dist


def create_image(heights):
    frame = []
    for i in heights:
        col = [255 for _ in range(0, max(int(HEIGHT / 2 - int(i * 100)), 0))] + \
              [0 for _ in range(0, min(int(i * 100), int(HEIGHT / 2)))] + \
              [127 for _ in range(0, int(HEIGHT / 2))]
        frame += [col]
    frame = np.array(frame).transpose()
    return PIL.Image.fromarray(np.uint8(frame))

# player = Player(x=4 * H, y=2 * H, v_dir=pi/4, v_field=pi/2)
# field = Field()
# heights = get_heights(field, player)
# plot heights - debug
# plt.plot(heights)
# plt.show()
#
# # test fps(75, omg!)
# # for i in range(0,1000):
# #     heights = render(field, player)
#
# # show image
# img = create_image(heights)
# img.show()
# map = render_map(field, player)
# map.show()
