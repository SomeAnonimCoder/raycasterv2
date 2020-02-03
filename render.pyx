from math import cos, tan, sqrt, sin, pi

import PIL.Image, PIL.ImageDraw, PIL.ImageColor
import numpy as np

from field import Field
from player import Player

cdef int H = 1
cdef int HEIGHT = 480
cdef int WIDTH = 640

cpdef render_map(map, player):
    h = 20
    frame = PIL.Image.new(size=[map.size()[0] * h, map.size()[1] * h], mode="P", color="White")
    img = PIL.ImageDraw.Draw(frame)
    for i in range(0, map.size()[0]):
        for j in range(0, map.size()[1]):
            if not map.is_empty(i, j):
                img.rectangle([i * h, j * h, (i + 1) * h, (j + 1) * h], fill="GREY")
    img.rectangle([player.x * h, player.y * h, player.x * h + 5, player.y * h + 5], fill="RED")
    img.line(
        [player.x * h, player.y * h, (player.x - 1 * cos(player.v_dir)) * h, (player.y - 1 * sin(player.v_dir)) * h],
        fill="RED")
    return frame

# get array of heights for each pixel column
cpdef get_heights(field, player):
    heights = []
    # for ray in field of view
    cdef float alpha
    cdef float k
    cdef float y_0
    cdef float x, y, dist, tmp
    for i in range(0, WIDTH):
        alpha = player.v_dir - player.v_field / 2 + player.v_field * i / WIDTH
        k = tan(alpha)
        y_0 = player.y - k * player.x

        collisions = []
        # for each cell in map
        for i in range(0, field.size()[0]):
            for j in range(0, field.size()[1]):

                if field.is_empty(i, j): continue
                x, y, dist = block_cross(i, j, k, y_0, alpha, player)
                collisions.append([x, y, field.get_color(i, j)])

        # select the closest collision of all
        dist = 1000 * H
        for collision in collisions:
            if None in collision: continue
            tmp = sqrt((collision[0] - player.x) ** 2 + (collision[1] - player.y) ** 2)
            if tmp < dist:
                dist = tmp
                color = collision[2]
        heights.append((1 / dist / cos(-alpha + player.v_dir) if 0 != dist else 1000, color))
    return heights

# count coordinates of collision with block(i,j) for ray y = y_0 + kx
def block_cross(i, j, k, y_0, alpha, player):
    # cell coordinates
    cdef float x_cell = i * H
    cdef float y_cell = j * H
    # find collision points
    collisions = []

    cdef float x = 0
    cdef float y = 0
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
    x = -1
    y = -1
    for collision in collisions:
        tmp = sqrt((collision[0] - player.x) ** 2 + (collision[1] - player.y) ** 2)
        if tmp < dist:
            dist = tmp;
            x = collision[0]
            y = collision[1]

    return x, y, dist

cpdef create_image(heights):
    frame = []
    for height, color in heights:
        col = [255 for _ in range(0, max(int(HEIGHT / 2 - int(height * 100)), 0))] + \
              [color for _ in range(0, min(int(height * 100), int(HEIGHT / 2)))] + \
              [color for _ in range(0, min(int(height * 40), int(HEIGHT / 2)))] + \
              [127 for _ in range(0, max(int(HEIGHT / 2 - int(height * 40)), 0))]
        frame.append(col)
    frame = np.array(frame).transpose()
    return PIL.Image.fromarray(np.uint8(frame))

#
# player = Player(6, 6, 3.14159 / 4, 3.14159 / 3)
# field = Field()
# heights = get_heights(field, player)
#
# # plot heights - debug
# #
# import matplotlib.pyplot as plt
#
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
