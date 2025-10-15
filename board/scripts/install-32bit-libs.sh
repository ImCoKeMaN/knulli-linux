#!/bin/bash

set -e

ARCH=$1

if [ -z "$ARCH" ]; then
    echo "ERROR: Architecture not provided"
    echo "Usage: $0 <architecture>"
    echo "Example: $0 rk3566"
    exit 1
fi

echo "================================================"
echo "Installing 32-bit libraries to 64-bit rootfs"
echo "================================================"
echo "Architecture: $ARCH"
echo ""

# Construct paths based on architecture
LIBS32_SOURCE_DIR="output/${ARCH}_armhf_libs/target"
TARGET_DIR="output/${ARCH}/target"

echo "32-bit source: $LIBS32_SOURCE_DIR"
echo "64-bit target: $TARGET_DIR"
echo ""

# Check if 32-bit libs build exists
if [ ! -d "$LIBS32_SOURCE_DIR" ]; then
    echo "WARNING: 32-bit libraries build not found at: $LIBS32_SOURCE_DIR"
    echo "Skipping 32-bit library installation."
    echo ""
    echo "To build 32-bit libraries first, run:"
    echo "  make ${ARCH}_armhf_libs-build"
    echo ""
    exit 0
fi

# Check if 64-bit target exists
if [ ! -d "$TARGET_DIR" ]; then
    echo "ERROR: 64-bit target directory not found at: $TARGET_DIR"
    echo ""
    echo "To build the main target first, run:"
    echo "  make ${ARCH}-build"
    echo ""
    exit 1
fi

# Create lib32 directories in the 64-bit target
echo "Creating lib32 directory structure..."
mkdir -p "${TARGET_DIR}/lib32"
mkdir -p "${TARGET_DIR}/usr/lib32"

# Copy the 32-bit dynamic linker to /lib (NOT /lib32)
echo ""
echo "Copying 32-bit dynamic linker..."
if [ -f "${LIBS32_SOURCE_DIR}/lib/ld-linux-armhf.so.3" ]; then
    cp -av "${LIBS32_SOURCE_DIR}/lib/ld-linux-armhf.so.3" "${TARGET_DIR}/lib/"
    echo "  ✓ Copied ld-linux-armhf.so.3 to /lib"
else
    echo "  ✗ WARNING: ld-linux-armhf.so.3 not found!"
fi

# Copy everything from /lib to /lib32 (preserving symlinks)
echo ""
echo "Copying /lib to /lib32..."
if [ -d "${LIBS32_SOURCE_DIR}/lib" ]; then
    rsync -av --exclude='ld-linux-armhf.so.3' "${LIBS32_SOURCE_DIR}/lib/" "${TARGET_DIR}/lib32/"
    echo "  ✓ Copied /lib contents to /lib32"
else
    echo "  ✗ WARNING: ${LIBS32_SOURCE_DIR}/lib not found!"
fi

# Copy everything from /usr/lib to /usr/lib32 (preserving symlinks and subdirectories)
echo ""
echo "Copying /usr/lib to /usr/lib32..."
if [ -d "${LIBS32_SOURCE_DIR}/usr/lib" ]; then
    rsync -av "${LIBS32_SOURCE_DIR}/usr/lib/" "${TARGET_DIR}/usr/lib32/"
    echo "  ✓ Copied /usr/lib contents to /usr/lib32"
else
    echo "  ✗ WARNING: ${LIBS32_SOURCE_DIR}/usr/lib not found!"
fi

# Create or append to ld.so.conf with lib32 paths
echo ""
echo "Configuring dynamic linker..."

if [ -f "${TARGET_DIR}/etc/ld.so.conf" ]; then
    grep -q "^/lib32$" "${TARGET_DIR}/etc/ld.so.conf" || echo "/lib32" >> "${TARGET_DIR}/etc/ld.so.conf"
    grep -q "^/usr/lib32$" "${TARGET_DIR}/etc/ld.so.conf" || echo "/usr/lib32" >> "${TARGET_DIR}/etc/ld.so.conf"
    grep -q "^/usr/local/lib32$" "${TARGET_DIR}/etc/ld.so.conf" || echo "/usr/local/lib32" >> "${TARGET_DIR}/etc/ld.so.conf"
    echo "  ✓ Updated existing /etc/ld.so.conf"
else
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
    ldconfig -r "${TARGET_DIR}" -v 2>&1 | head -n 20 || true
    echo "  ✓ Generated /etc/ld.so.cache"
else
    echo "  ⚠ WARNING: ldconfig not found on host"
    echo "    Cache will be generated on first boot"
fi

# Create a marker file to indicate 32-bit libs are installed
echo "armhf" > "${TARGET_DIR}/etc/multiarch"
echo "  ✓ Created /etc/multiarch marker"

# Print summary
echo ""
echo "================================================"
echo "32-bit library installation summary:"
echo "================================================"

LIB32_COUNT=$(find "${TARGET_DIR}/lib32" -type f 2>/dev/null | wc -l)
USRLIB32_COUNT=$(find "${TARGET_DIR}/usr/lib32" -type f 2>/dev/null | wc -l)
ALSA_PLUGINS=$(find "${TARGET_DIR}/usr/lib32/alsa-lib" -name "*.so" 2>/dev/null | wc -l)
PIPEWIRE_PLUGINS=$(find "${TARGET_DIR}/usr/lib32/pipewire-0.3" -name "*.so" 2>/dev/null | wc -l)

echo "  Files in /lib32:           $LIB32_COUNT"
echo "  Files in /usr/lib32:       $USRLIB32_COUNT"
echo "  ALSA plugins:              $ALSA_PLUGINS"
echo "  PipeWire plugins:          $PIPEWIRE_PLUGINS"
echo "  Total 32-bit files:        $((LIB32_COUNT + USRLIB32_COUNT))"

echo ""
echo "Key 32-bit libraries:"
for lib in libc.so.6 libm.so.6 libpthread.so.0 libdl.so.2 libGL.so.1 libEGL.so.1 libGLESv2.so.2 libasound.so.2; do
    if [ -e "${TARGET_DIR}/lib32/${lib}" ] || [ -e "${TARGET_DIR}/usr/lib32/${lib}" ]; then
        echo "  ✓ ${lib}"
    fi
done

echo ""
echo "Dynamic linker:"
[ -e "${TARGET_DIR}/lib/ld-linux-armhf.so.3" ] && echo "  ✓ /lib/ld-linux-armhf.so.3"

echo ""
echo "Configuration files:"
[ -f "${TARGET_DIR}/etc/ld.so.conf" ] && echo "  ✓ /etc/ld.so.conf"
[ -f "${TARGET_DIR}/etc/ld.so.cache" ] && echo "  ✓ /etc/ld.so.cache"
[ -f "${TARGET_DIR}/etc/multiarch" ] && echo "  ✓ /etc/multiarch"

echo "================================================"
echo ""

exit 0