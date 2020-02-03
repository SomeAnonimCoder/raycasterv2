import numpy as np


class Field:
    __field = np.array(
        [
            [1,   1,   1,   1,   1,   1,   1,   1,   1,   1],
            [1,   0,   0,   0,   0,   0,   0,   0,   0,   1],
            [1,   0,   30,  0,   0,   0,   100, 0,   0,   1],
            [1,   0,   0,   50,  0,   0,   0,   75,  0,   1],
            [1,   0,   0,   0,   90,  0,   0,   0,   20,  1],
            [1,   0,   0,   0,   0,   0,   0,   0,   0,   1],
            [1,   0,   0,   0,   120, 0,   0,   0,   50,  1],
            [1,   1,   1,   1,   1,   1,   1,   1,   1,   1],
        ]
    ).transpose()



    def is_empty(self, cell):
        return not self.__field[cell[0], cell[1]]

    def get_color(self, i, j):
        return self.__field[i, j] if self.__field[i, j] != 0 else 255

    def size(self):
        return self.__field.shape
