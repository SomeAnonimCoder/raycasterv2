from math import cos, tan, sqrt, sin, pi

import PIL.Image, PIL.ImageDraw, PIL.ImageColor
import numpy as np

import matplotlib.pyplot as plt

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

cdef struct Column:
    int color
    float height
ctypedef Column column

cdef column heights[640]


# get array of heights for each pixel column
cdef column* get_heights(field, player):
    # for ray in field of view
    cdef float alpha
    cdef float k
    cdef float y_0
    cdef float x, y, dist, tmp
    cdef column col

    for ray_num in range(0, WIDTH):
        alpha = player.v_dir - player.v_field / 2 + player.v_field * ray_num / WIDTH
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
        col.height = 1 / dist / cos(-alpha + player.v_dir) if 0 != dist and cos(player.v_dir-alpha)!=0 else 1000
        col.color = color
        heights[ray_num] = col
        #print("creating",ray_num, col.height, col.color)
    return heights

# count coordinates of collision with block(i,j) for ray y = y_0 + kx
cdef block_cross(int i, int j, float k, float y_0, float alpha, player):
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

cpdef create_image(field, player):
    heights = get_heights(field, player)
    cdef int frame[480][640]
    cdef float height
    cdef int color
    cdef column col
    for i in range(0, WIDTH):

        height = heights[i].height
        color = heights[i].color

        #print(i, height, color)

        wall_top = int(HEIGHT/2+height*100)
        if wall_top > HEIGHT: wall_top=HEIGHT
        wall_bottom = int(HEIGHT/2 - height*40)
        if wall_bottom <0: wall_bottom=0

        for j in range(0, wall_bottom):
            frame[j][i] = 255

        for j in range(wall_bottom, wall_top):
            frame[j][i] = 0

        for j in range(wall_top, HEIGHT):
            frame[j][i] = 127


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
