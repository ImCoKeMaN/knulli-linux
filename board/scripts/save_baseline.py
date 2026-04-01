#!/usr/bin/env python3
"""
Knulli OTA Baseline Saver

Saves build artifacts as a persistent baseline for future OTA delta generation.

For each architecture found in the build output:
  - Stores rootfs.squashfs as  BASELINE_DIR/releases/{arch}/rootfs_{md5}.squashfs
    (skipped if already present — identical by construction)
  - Stores firmware.sig alongside it as BASELINE_DIR/releases/{arch}/firmware_{md5}.sig
  - Generates xdelta3 patches from every previously stored rootfs baseline
    to the new one, written to BASELINE_DIR/updates/patches/

For Allwinner BSP boards (h700, a133), if --source-dir is provided:
  - Copies partition images (boot0.img, boot_package.fex, boot.img, env.img)
    from the board source tree to BASELINE_DIR/updates/partitions/{board}/
    only when the file differs from the already-stored copy.

For boot-FAT platforms (rk3326, rk3568, sm8250, etc.):
  - Copies tracked boot files (kernel, initrd, DTBs, boot config) from the
    assembled boot FAT directory to BASELINE_DIR/updates/boot_files/{arch}/
    only when the file differs from the already-stored copy.

Expected BASELINE_DIR layout (mirrors the server's updates/ structure):
  releases/
    {arch}/
      rootfs_{md5}.squashfs
      firmware_{md5}.sig
  updates/
    partitions/
      {board}/
        boot0.img
        boot_package.fex
        boot.img
        env.img
    boot_files/
      {arch}/
        {board}/
          linux  (or Image)
          initrd.lz4
          {board}.dtb
          extlinux.conf  (etc.)
    patches/
      {old_md5}_to_{new_md5}.patch

Usage:
  save_baseline.py --output-dir output/h700 \\
                   --baseline-dir /data/knulli/baseline \\
                   [--source-dir  /path/to/knulli/repo]
"""

import argparse
import hashlib
import shutil
import subprocess
import sys
from pathlib import Path


ALLWINNER_ARCHS = ("h700", "a133")
ALLWINNER_PARTITIONS = ("boot0.img", "boot_package.fex", "boot.img", "env.img")


# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

def md5_file(path):
    h = hashlib.md5()
    with open(path, "rb") as f:
        for chunk in iter(lambda: f.read(1 << 20), b""):
            h.update(chunk)
    return h.hexdigest()


def parse_firmware_sig(sig_path):
    result = {"metadata": {}, "partitions": {}}
    section = None
    with open(sig_path) as f:
        for line in f:
            line = line.strip()
            if not line or line.startswith("#"):
                continue
            if line.startswith("[") and line.endswith("]"):
                section = line[1:-1]
                continue
            if section and "=" in line:
                key, _, value = line.partition("=")
                result.setdefault(section, {})[key.strip()] = value.strip().strip('"')
    return result


def is_allwinner_bsp(partitions):
    return partitions.get("boot0.img_md5", "MISSING") != "MISSING"


def collect_subtargets(output_dir):
    images_dir = output_dir / "images" / "knulli" / "images"
    if not images_dir.is_dir():
        print(f"ERROR: {images_dir} not found — run the build first", file=sys.stderr)
        sys.exit(1)
    subtargets = []
    for sub in sorted(images_dir.iterdir()):
        sig_path = sub / "firmware.sig"
        if sig_path.exists():
            sig = parse_firmware_sig(sig_path)
            board = sig["metadata"].get("board", sub.name)
            if sig["metadata"].get("arch", "unknown") == "unknown":
                sig["metadata"]["arch"] = output_dir.name
            subtargets.append((board, sig, sig_path))
    if not subtargets:
        print("ERROR: No firmware.sig files found", file=sys.stderr)
        sys.exit(1)
    return subtargets


# ---------------------------------------------------------------------------
# Rootfs baseline
# ---------------------------------------------------------------------------

def save_rootfs_baseline(arch, new_md5, rootfs_src, sig_path, releases_dir):
    """Copy rootfs and sig into releases/ if not already stored.

    Returns the path to the stored rootfs file.
    """
    arch_dir = releases_dir
    arch_dir.mkdir(parents=True, exist_ok=True)

    dest_rootfs = arch_dir / f"{new_md5}_rootfs.squashfs"
    dest_sig    = arch_dir / f"{new_md5}_firmware.sig"

    if dest_rootfs.exists():
        print(f"  [baseline] already stored: {dest_rootfs.name}")
    else:
        size_mb = rootfs_src.stat().st_size / 1024 / 1024
        print(f"  [baseline] storing {new_md5[:8]}_rootfs… ({size_mb:.0f} MB)")
        shutil.copy2(rootfs_src, dest_rootfs)

    if not dest_sig.exists():
        shutil.copy2(sig_path, dest_sig)

    return dest_rootfs


# ---------------------------------------------------------------------------
# Patch generation
# ---------------------------------------------------------------------------

def generate_patches(arch, new_md5, new_rootfs_path, releases_dir, patches_dir):
    """Generate xdelta3 patches from every stored baseline to the new rootfs."""
    patches_dir.mkdir(parents=True, exist_ok=True)
    arch_dir = releases_dir / arch

    old_rootfs_files = sorted(arch_dir.glob("rootfs_*.squashfs"))
    candidates = [f for f in old_rootfs_files if f.stem[len("rootfs_"):] != new_md5]

    if not candidates:
        print(f"  [patches] no prior baselines for {arch} — nothing to diff")
        return

    for old_rootfs in candidates:
        old_md5 = old_rootfs.stem[len("rootfs_"):]
        patch_name = f"{old_md5}_to_{new_md5}.patch"
        patch_path = patches_dir / patch_name

        if patch_path.exists():
            print(f"  [patches] already exists: {patch_name}")
            continue

        print(f"  [patches] generating {patch_name} ...")
        result = subprocess.run(
            ["xdelta3", "-e", "-s", str(old_rootfs), str(new_rootfs_path), str(patch_path)],
            capture_output=True, text=True
        )
        if result.returncode != 0:
            print(f"  WARNING: xdelta3 failed for {patch_name}: {result.stderr.strip()}",
                  file=sys.stderr)
            patch_path.unlink(missing_ok=True)
        else:
            size_mb = patch_path.stat().st_size / 1024 / 1024
            print(f"  [patches] {patch_name}: {size_mb:.1f} MB")


# ---------------------------------------------------------------------------
# Boot-FAT files (non-Allwinner: kernel, initrd, DTBs, boot config)
# ---------------------------------------------------------------------------

def save_boot_files(board, arch, partitions, output_dir, boot_files_dir):
    """Copy boot-FAT files to updates/boot_files/{arch}/ if changed.

    Source files are read from the assembled boot FAT directory produced by
    create-boot-script.sh: output_dir/images/knulli/boot_{board}/

    Each file key in firmware.sig (except rootfs.squashfs) has a _path entry
    giving its location within the FAT (e.g. boot/linux, boot/initrd.lz4,
    boot/rk3566-anbernic-rg-arc-s.dtb, extlinux/extlinux.conf).
    """
    boot_dir = output_dir / "images" / "knulli" / f"boot_{board}"
    if not boot_dir.is_dir():
        print(f"  [boot_files] WARNING: {boot_dir} not found — skipping", file=sys.stderr)
        return

    dest_dir = boot_files_dir / arch / board
    dest_dir.mkdir(parents=True, exist_ok=True)

    for key, value in partitions.items():
        if not key.endswith("_md5") or key == "rootfs.squashfs_md5":
            continue
        file_key = key[: -len("_md5")]
        fat_path = partitions.get(f"{file_key}_path")
        if not fat_path or not value or value == "MISSING":
            continue

        src = boot_dir / fat_path
        if not src.exists():
            print(f"  [boot_files] WARNING: {src} not found — skipping", file=sys.stderr)
            continue

        dest = dest_dir / file_key
        if dest.exists() and md5_file(dest) == value:
            print(f"  [boot_files] {file_key}: unchanged")
            continue

        size_kb = src.stat().st_size / 1024
        print(f"  [boot_files] {file_key}: storing {value[:8]}… ({size_kb:.0f} KB)")
        shutil.copy2(src, dest)


# ---------------------------------------------------------------------------
# Allwinner BSP partition files
# ---------------------------------------------------------------------------

def save_partition_files(board, arch, partitions, source_dir, partitions_dir):
    """Copy Allwinner BSP partition images to updates/partitions/{board}/ if changed."""
    board_src = source_dir / "board" / "allwinner" / arch / board / "partitions"
    if not board_src.is_dir():
        print(f"  [partitions] WARNING: {board_src} not found — skipping", file=sys.stderr)
        return

    dest_dir = partitions_dir / board
    dest_dir.mkdir(parents=True, exist_ok=True)

    for part in ALLWINNER_PARTITIONS:
        src = board_src / part
        if not src.exists():
            continue

        expected_md5 = partitions.get(f"{part}_md5", "MISSING")
        if expected_md5 == "MISSING":
            continue

        dest = dest_dir / part
        if dest.exists() and md5_file(dest) == expected_md5:
            print(f"  [partitions] {board}/{part}: unchanged")
            continue

        print(f"  [partitions] {board}/{part}: storing {expected_md5[:8]}…")
        shutil.copy2(src, dest)


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

def main():
    parser = argparse.ArgumentParser(
        description="Save Knulli build artifacts as a baseline for OTA delta generation."
    )
    parser.add_argument(
        "--output-dir", required=True,
        help="Buildroot output directory for this arch (e.g. output/h700)"
    )
    parser.add_argument(
        "--baseline-dir", required=True,
        help="Persistent directory for baseline storage (survives build cleans)"
    )
    parser.add_argument(
        "--source-dir",
        help="Knulli repo root — required for Allwinner BSP partition file copying"
    )
    args = parser.parse_args()

    output_dir   = Path(args.output_dir).resolve()
    baseline_dir = Path(args.baseline_dir).resolve()
    source_dir   = Path(args.source_dir).resolve() if args.source_dir else None

    releases_dir   = baseline_dir / "releases"
    patches_dir    = baseline_dir / "updates" / "patches"
    partitions_dir = baseline_dir / "updates" / "partitions"
    boot_files_dir = baseline_dir / "updates" / "boot_files"

    rootfs_src = output_dir / "images" / "rootfs.squashfs"
    if not rootfs_src.exists():
        print(f"ERROR: {rootfs_src} not found — build may be incomplete", file=sys.stderr)
        sys.exit(1)

    print(f"Scanning {output_dir}/images/knulli/images/ ...")
    subtargets = collect_subtargets(output_dir)
    print(f"Found {len(subtargets)} board variant(s): {', '.join(b for b, _, _ in subtargets)}")

    seen_archs = set()

    for board, sig, sig_path in subtargets:
        m = sig["metadata"]
        p = sig["partitions"]
        arch    = m.get("arch", "unknown")
        new_md5 = p.get("rootfs.squashfs_md5", "MISSING")

        if new_md5 == "MISSING":
            print(f"\nWARNING: {board}: rootfs MD5 missing in firmware.sig — skipping",
                  file=sys.stderr)
            continue

        # rootfs baseline + patch generation — once per arch
        if arch not in seen_archs:
            print(f"\n[{arch}]")
            new_rootfs_path = save_rootfs_baseline(
                arch, new_md5, rootfs_src, sig_path, releases_dir
            )
            generate_patches(arch, new_md5, new_rootfs_path, releases_dir, patches_dir)
            seen_archs.add(arch)

        # Allwinner BSP: copy partition images from source tree
        if is_allwinner_bsp(p):
            print(f"\n[{board}]")
            if source_dir:
                save_partition_files(board, arch, p, source_dir, partitions_dir)
            else:
                print(f"  [partitions] --source-dir not provided — skipping partition copy")

        # Boot-FAT platforms: copy kernel, initrd, DTBs, boot config
        else:
            print(f"\n[{board}]")
            save_boot_files(board, arch, p, output_dir, boot_files_dir)

    print("\nBaseline save complete.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
