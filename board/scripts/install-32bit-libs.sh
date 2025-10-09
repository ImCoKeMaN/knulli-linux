#!/bin/bash

set -e

TARGET_DIR=$1
BASE_DIR=$2

if [ -z "$TARGET_DIR" ]; then
    echo "ERROR: TARGET_DIR not provided"
    exit 1
fi

if [ -z "$BASE_DIR" ]; then
    echo "ERROR: BASE_DIR not provided"
    exit 1
fi

# BASE_DIR is relative (e.g., "/rk3326"), TARGET_DIR is absolute
# Extract the full output directory from TARGET_DIR
# TARGET_DIR is typically: /path/to/output/rk3326/target
# We want: /path/to/output/rk3326_armhf_libs/target

# Get the parent of TARGET_DIR (removes /target)
BUILD_OUTPUT_DIR="$(dirname ${TARGET_DIR})"

# Get the grandparent (removes /rk3326)
OUTPUT_ROOT_DIR="../$(dirname ${BUILD_OUTPUT_DIR})"

# Now construct the 32-bit libs path
# Extract just the build name from BASE_DIR (e.g., "rk3326")
BUILD_NAME="$(basename ${BASE_DIR})"

LIBS32_BUILD_DIR="${OUTPUT_ROOT_DIR}/${BUILD_NAME}_armhf_libs/target"

echo "================================================"
echo "Installing 32-bit libraries to 64-bit rootfs"
echo "================================================"
echo "TARGET_DIR: $TARGET_DIR"
echo "BASE_DIR: $BASE_DIR"
echo "BUILD_OUTPUT_DIR: $BUILD_OUTPUT_DIR"
echo "OUTPUT_ROOT_DIR: $OUTPUT_ROOT_DIR"
echo "BUILD_NAME: $BUILD_NAME"
echo "LIBS32_BUILD_DIR: $LIBS32_BUILD_DIR"
echo ""

# Check if 32-bit libs build exists
if [ ! -d "$LIBS32_BUILD_DIR" ]; then
    echo "WARNING: 32-bit libraries build not found at: $LIBS32_BUILD_DIR"
    echo "Skipping 32-bit library installation."
    echo ""
    echo "To build 32-bit libraries first, run:"
    echo "  make rk3326_armhf_libs-build"
    echo ""
    exit 0  # Don't fail the build, just warn
fi

# Create lib32 directories
echo "Creating lib32 directory structure..."
mkdir -p "${TARGET_DIR}/lib32"
mkdir -p "${TARGET_DIR}/usr/lib32"

# Copy the dynamic linker (ld-linux-armhf.so.3)
echo "Copying 32-bit dynamic linker..."
if [ -f "${LIBS32_BUILD_DIR}/lib/ld-linux-armhf.so.3" ]; then
    cp -av "${LIBS32_BUILD_DIR}/lib/ld-linux-armhf.so.3" "${TARGET_DIR}/lib/"
    echo "  ✓ Copied ld-linux-armhf.so.3"
else
    echo "  ✗ WARNING: ld-linux-armhf.so.3 not found!"
fi

# Copy all 32-bit libraries from /lib
echo ""
echo "Copying libraries from /lib to /lib32..."
if [ -d "${LIBS32_BUILD_DIR}/lib" ]; then
    # Copy all .so* files (regular files)
    find "${LIBS32_BUILD_DIR}/lib" -maxdepth 1 -name "*.so*" -type f -exec cp -av {} "${TARGET_DIR}/lib32/" \;
    # Copy symbolic links
    find "${LIBS32_BUILD_DIR}/lib" -maxdepth 1 -name "*.so*" -type l -exec cp -av {} "${TARGET_DIR}/lib32/" \;
    echo "  ✓ Copied /lib libraries"
else
    echo "  ✗ WARNING: ${LIBS32_BUILD_DIR}/lib not found!"
fi

# Copy all 32-bit libraries from /usr/lib
echo ""
echo "Copying libraries from /usr/lib to /usr/lib32..."
if [ -d "${LIBS32_BUILD_DIR}/usr/lib" ]; then
    # Copy all .so* files (regular files)
    find "${LIBS32_BUILD_DIR}/usr/lib" -maxdepth 1 -name "*.so*" -type f -exec cp -av {} "${TARGET_DIR}/usr/lib32/" \;
    # Copy symbolic links
    find "${LIBS32_BUILD_DIR}/usr/lib" -maxdepth 1 -name "*.so*" -type l -exec cp -av {} "${TARGET_DIR}/usr/lib32/" \;
    echo "  ✓ Copied /usr/lib libraries"
else
    echo "  ✗ WARNING: ${LIBS32_BUILD_DIR}/usr/lib not found!"
fi

# Create or append to ld.so.conf with lib32 paths
echo ""
echo "Configuring dynamic linker..."

# Check if ld.so.conf already exists
if [ -f "${TARGET_DIR}/etc/ld.so.conf" ]; then
    # Append lib32 paths if not already present
    grep -q "^/lib32$" "${TARGET_DIR}/etc/ld.so.conf" || echo "/lib32" >> "${TARGET_DIR}/etc/ld.so.conf"
    grep -q "^/usr/lib32$" "${TARGET_DIR}/etc/ld.so.conf" || echo "/usr/lib32" >> "${TARGET_DIR}/etc/ld.so.conf"
    grep -q "^/usr/local/lib32$" "${TARGET_DIR}/etc/ld.so.conf" || echo "/usr/local/lib32" >> "${TARGET_DIR}/etc/ld.so.conf"
    echo "  ✓ Updated existing /etc/ld.so.conf"
else
    # Create new ld.so.conf
    cat > "${TARGET_DIR}/etc/ld.so.conf" << 'EOF'
# Dynamic linker configuration for 64-bit with 32-bit compatibility
/lib
/usr/lib
/lib32
/usr/lib32
/usr/local/lib
/usr/local/lib32
EOF
    echo "  ✓ Created /etc/ld.so.conf"
fi

# Generate ld.so.cache
echo ""
echo "Generating ld.so.cache..."
if command -v ldconfig >/dev/null 2>&1; then
    # Use host ldconfig with -r option
    ldconfig -r "${TARGET_DIR}" 2>&1 | head -n 20 || true
    echo "  ✓ Generated ld.so.cache using host ldconfig"
else
    echo "  ⚠ WARNING: ldconfig not found, cache not generated"
    echo "    Cache will be generated on first boot"
fi

# Create a marker file to indicate 32-bit libs are installed
echo "armhf" > "${TARGET_DIR}/etc/multiarch"
echo "  ✓ Created multiarch marker"

# Print summary
echo ""
echo "================================================"
echo "32-bit library installation summary:"
echo "================================================"
LIB32_COUNT=$(find "${TARGET_DIR}/lib32" -name "*.so*" 2>/dev/null | wc -l)
USRLIB32_COUNT=$(find "${TARGET_DIR}/usr/lib32" -name "*.so*" 2>/dev/null | wc -l)
echo "  Libraries in /lib32:     $LIB32_COUNT"
echo "  Libraries in /usr/lib32: $USRLIB32_COUNT"
echo "  Total 32-bit libraries:  $((LIB32_COUNT + USRLIB32_COUNT))"

# Show some key libraries
echo ""
echo "Key 32-bit libraries installed:"
for lib in libc.so.6 libm.so.6 libpthread.so.0 libdl.so.2 libGL.so.1 libEGL.so.1; do
    if [ -e "${TARGET_DIR}/lib32/${lib}" ] || [ -e "${TARGET_DIR}/usr/lib32/${lib}" ]; then
        echo "  ✓ ${lib}"
    fi
done

echo "================================================"
echo ""

exit 0