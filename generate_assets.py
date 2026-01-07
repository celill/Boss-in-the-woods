import os
import wave
import math
import struct
import random

def create_grid_texture(filename, width=256, height=256):
    # Create a simple PGM (Portable Gray Map) file because it's text-based and easy to write,
    # but Godot might prefer PNG. Since I don't have PIL, I will create a simple BMP.
    # BMP Header
    file_size = 54 + width * height * 3
    header = bytearray(b'BM') + file_size.to_bytes(4, 'little') + b'\x00\x00\x00\x00' + b'\x36\x00\x00\x00'
    info_header = b'\x28\x00\x00\x00' + width.to_bytes(4, 'little') + height.to_bytes(4, 'little') + \
                  b'\x01\x00\x18\x00\x00\x00\x00\x00' + (width * height * 3).to_bytes(4, 'little') + \
                  b'\x00\x00\x00\x00' * 4

    with open(filename, 'wb') as f:
        f.write(header)
        f.write(info_header)
        # Data
        for y in range(height):
            for x in range(width):
                # Dark gray background, lighter gray lines
                if x % 32 == 0 or y % 32 == 0:
                    b, g, r = 60, 60, 60
                else:
                    b, g, r = 30, 20, 20 # Dark reddish brown
                f.write(bytes([b, g, r]))
    print(f"Created {filename}")

def create_noise_wav(filename, duration=0.5, type='noise'):
    sample_rate = 44100
    n_frames = int(sample_rate * duration)

    with wave.open(filename, 'w') as obj:
        obj.setnchannels(1) # mono
        obj.setsampwidth(2) # 16 bit
        obj.setframerate(sample_rate)

        data = bytearray()
        for i in range(n_frames):
            if type == 'noise':
                value = random.randint(-10000, 10000)
            elif type == 'saw':
                # Sawtooth wave
                freq = 100
                period = sample_rate / freq
                value = int(((i % period) / period * 2 - 1) * 10000)
            elif type == 'square':
                freq = 440
                period = sample_rate / freq
                if (i % period) < (period / 2):
                    value = 8000
                else:
                    value = -8000
            else:
                value = 0

            # Simple envelope to prevent clicking
            if i < 500: value = int(value * (i/500))
            if i > n_frames - 2000: value = int(value * ((n_frames-i)/2000))

            data.extend(struct.pack('<h', int(value)))

        obj.writeframes(data)
    print(f"Created {filename}")

def create_svg_icon(filename):
    svg = """<svg xmlns="http://www.w3.org/2000/svg" width="64" height="64"><rect width="64" height="64" fill="#d35400"/><rect x="10" y="20" width="44" height="24" fill="#2c3e50"/><circle cx="18" cy="44" r="6" fill="#000"/><circle cx="46" cy="44" r="6" fill="#000"/></svg>"""
    with open(filename, 'w') as f:
        f.write(svg)
    print(f"Created {filename}")

if __name__ == "__main__":
    create_grid_texture("assets/materials/grid.bmp")
    create_svg_icon("icon.svg")
    create_noise_wav("assets/sounds/shoot.wav", 0.15, 'square')
    create_noise_wav("assets/sounds/explosion.wav", 0.4, 'noise')
    create_noise_wav("assets/sounds/levelup.wav", 0.6, 'saw')
