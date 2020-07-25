#! /usr/bin/env python3

import os.path
import sys

from PIL import Image


source = sys.argv[1]
destination = sys.argv[2]

if source == destination:
    raise ValueError("Source and destination are the same")

if os.path.exists(destination):
    raise ValueError(f"{destination} already exists")

image = Image.open(source)
old_width, old_height = image.size
new_width = 32 * 16
new_height = new_width
new_image = Image.new('RGBA', (new_width, new_height))

for i in range(32):
    for j in range(32):
        tile = image.crop((i * 17, j * 17, i * 17 + 16, j * 17 + 16))
        new_image.paste(tile, (i * 16, j * 16))

new_image.save(destination)
