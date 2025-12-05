#!/usr/bin/env python3
#
# Extract boot_package (A133/V90s) 
# * u-boot  00000080  00 08 00 00 00 40 08 00 -> offset 0x00800, length 0x84000
# * monitor 000001f0  00 48 08 00 0c 13 01 00 -> offset 0x84800, length 0x1130c
# * scp     00000360  00 5c 09 00 08 40 01 00 -> offset 0x95c00, length 0x14008
# * dtb     000004d0  00 a0 0a 00 00 56 02 00 -> offset 0xaa000, length 0x25600
#
import struct
import os

def extract_boot_package(file_path, output_dir="output_blocks"):
    markers = [
        {"name_offset": 0x40, "info_offset": 0x80},
        {"name_offset": 0x1B0, "info_offset": 0x1F0},
        {"name_offset": 0x320, "info_offset": 0x360},
        {"name_offset": 0x490, "info_offset": 0x4D0}
    ]

    os.makedirs(output_dir, exist_ok=True)

    with open(file_path, "rb") as f:
        data = f.read()

    for entry in markers:
        # Read block name (up to null terminator)
        name_bytes = data[entry["name_offset"]:entry["name_offset"] + 16]
        name = name_bytes.split(b'\x00')[0].decode('ascii')

        # Read offset and length (little-endian)
        offset = struct.unpack('<I', data[entry["info_offset"]:entry["info_offset"] + 4])[0]
        length = struct.unpack('<I', data[entry["info_offset"] + 4:entry["info_offset"] + 8])[0]

        print(f"Extracting {name} at offset 0x{offset:X} with length {length} bytes")

        # Extract block
        block_data = data[offset:offset + length]

        # Save to file
        output_path = os.path.join(output_dir, f"{name}.bin")
        with open(output_path, "wb") as out_file:
            out_file.write(block_data)

        print(f"Saved to {output_path}")

if __name__ == "__main__":
    import sys
    if len(sys.argv) != 2:
        print("Usage: python extract_boot_package.py boot_package.fex")
        sys.exit(1)

    extract_boot_package(sys.argv[1])

