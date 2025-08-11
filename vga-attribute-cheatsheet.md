# VGA Attribute Byte Cheatsheet

Each attribute byte is `0xBG`, where:
- `B` = Background color (high nibble)
- `G` = Foreground color (low nibble)

## VGA Color Codes

| Value | Color Name       |
|-------|------------------|
| 0     | Black            |
| 1     | Blue             |
| 2     | Green            |
| 3     | Cyan             |
| 4     | Red              |
| 5     | Magenta          |
| 6     | Brown            |
| 7     | Light Gray       |
| 8     | Dark Gray        |
| 9     | Light Blue       |
| A     | Light Green      |
| B     | Light Cyan       |
| C     | Light Red        |
| D     | Light Magenta    |
| E     | Yellow           |
| F     | White (Bright)   |

## Common Attribute Byte Examples

| Attribute Byte | Foreground / Background |
|----------------|--------------------------|
| 0x07           | Light Gray on Black      |
| 0x1F           | White on Blue            |
| 0x4F           | White on Red             |
| 0x2E           | Yellow on Green          |
| 0x0C           | Light Red on Black       |
| 0xF0           | Black on White           |

