from field import Field
from player import Player
from render import get_heights, create_image, render_map

player = Player(6, 6, 3.14159 / 4, 3.14159 / 3)
field = Field()
heights = get_heights(field, player)

# plot heights

import matplotlib.pyplot as plt

plt.plot(heights)
plt.show()


# show image
img = create_image(heights)
img.show()

map = render_map(field, player)
map.show()
