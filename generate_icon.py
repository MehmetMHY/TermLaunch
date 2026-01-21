#!/usr/bin/env python3

from PIL import Image
import subprocess
import os

# Icon sizes required for macOS .icns
ICON_SIZES = [
    (16, "icon_16x16.png"),
    (32, "icon_16x16@2x.png"),
    (32, "icon_32x32.png"),
    (64, "icon_32x32@2x.png"),
    (128, "icon_128x128.png"),
    (256, "icon_128x128@2x.png"),
    (256, "icon_256x256.png"),
    (512, "icon_256x256@2x.png"),
    (512, "icon_512x512.png"),
    (1024, "icon_512x512@2x.png"),
]

# Padding as percentage of icon size (10% on each side = icon is 80% of canvas)
PADDING_PERCENT = 0.10


def main():
    script_dir = os.path.dirname(os.path.abspath(__file__))
    logo_path = os.path.join(script_dir, "logo.png")
    iconset_path = os.path.join(script_dir, "AppIcon.iconset")
    icns_path = os.path.join(script_dir, "TermLaunch", "AppIcon.icns")

    # Create iconset directory
    os.makedirs(iconset_path, exist_ok=True)

    # Open the source image
    img = Image.open(logo_path)

    # Ensure RGBA mode for transparency support
    if img.mode != "RGBA":
        img = img.convert("RGBA")

    # Generate each size
    for size, filename in ICON_SIZES:
        # Calculate inner size with padding
        padding = int(size * PADDING_PERCENT)
        inner_size = size - (padding * 2)

        # Resize logo to fit within padded area
        resized = img.resize((inner_size, inner_size), Image.LANCZOS)

        # Create transparent canvas and paste logo centered
        canvas = Image.new("RGBA", (size, size), (0, 0, 0, 0))
        canvas.paste(resized, (padding, padding))

        output_path = os.path.join(iconset_path, filename)
        canvas.save(output_path, "PNG")
        print(f"Created {filename} ({size}x{size}, inner: {inner_size}x{inner_size})")

    # Use iconutil to create .icns file
    subprocess.run(
        ["iconutil", "-c", "icns", iconset_path, "-o", icns_path], check=True
    )
    print(f"Created {icns_path}")

    # Clean up iconset directory
    for filename in os.listdir(iconset_path):
        os.remove(os.path.join(iconset_path, filename))
    os.rmdir(iconset_path)
    print("Cleaned up temporary iconset directory")


if __name__ == "__main__":
    main()
