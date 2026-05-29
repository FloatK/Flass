"""Generate adaptive icons from adaptable.png"""
from PIL import Image
import os

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
SRC = os.path.join(BASE_DIR, 'adaptable.png')
ICON = os.path.join(BASE_DIR, 'icon.png')
FG = os.path.join(BASE_DIR, 'icon_foreground.png')
MONO = os.path.join(BASE_DIR, 'icon_monochrome.png')

# 1. icon.png — direct copy
img = Image.open(SRC).convert('RGBA')
img.save(ICON, 'PNG')
print(f'[OK] icon.png ({img.size[0]}x{img.size[1]})')

# 2. icon_foreground.png — 432x432, remove white background
size = 432
fg = img.copy()
# Scale to fit 432x432 preserving aspect ratio
fg.thumbnail((size, size), Image.LANCZOS)
# Create transparent canvas
canvas = Image.new('RGBA', (size, size), (0, 0, 0, 0))
# Center paste
x = (size - fg.width) // 2
y = (size - fg.height) // 2
canvas.paste(fg, (x, y), fg)

# Remove white/near-white pixels (R>240, G>240, B>240)
pixels = canvas.load()
for py in range(size):
    for px in range(size):
        r, g, b, a = pixels[px, py]
        if r > 240 and g > 240 and b > 240:
            pixels[px, py] = (r, g, b, 0)  # Make transparent

canvas.save(FG, 'PNG')
print(f'[OK] icon_foreground.png ({size}x{size}, white bg removed)')

# 3. icon_monochrome.png — white version of foreground
mono = canvas.copy()
pixels = mono.load()
for py in range(size):
    for px in range(size):
        r, g, b, a = pixels[px, py]
        if a > 0:
            pixels[px, py] = (255, 255, 255, a)  # White, keep alpha

mono.save(MONO, 'PNG')
print(f'[OK] icon_monochrome.png ({size}x{size}, white monochrome)')
print('\n图片处理完成')
