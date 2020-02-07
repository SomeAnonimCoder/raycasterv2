from field import Field
from player import Player
from render import create_image, render_map

player = Player(6, 6, 3.14159 / 4, 3.14159 / 3)
field = Field()


# show image
img = create_image(field, player)
img.show()

map = render_map(field, player)
map.show()
