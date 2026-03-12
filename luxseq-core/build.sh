#!/bin/bash
# LuxSeq Kernel Build System
# Budowanie kernela + bootloadera przez bootimage i opcjonalny deploy na GCP

set -e

echo "🚀 LuxSeq Kernel Build"
echo "======================"
echo ""

# Sprawdzenie czy bootimage jest zainstalowany
if ! command -v bootimage &> /dev/null; then
    echo "📦 Instalacja bootimage..."
    cargo install bootimage
fi
echo "   ✓ bootimage jest zainstalowany"

# Sprawdzenie czy nightly jest aktywny
if ! rustup toolchain list | grep -q "nightly.*active"; then
    echo "⚠️  Uaktywniamy nightly toolchain..."
    rustup override set nightly
fi
echo "   ✓ nightly toolchain jest aktywny"

# Sprawdzenie target
if ! rustup target list | grep -q "x86_64-unknown-none (installed)"; then
    echo "📦 Instalacja x86_64-unknown-none target..."
    rustup target add x86_64-unknown-none
fi
echo "   ✓ x86_64-unknown-none target zainstalowany"
echo ""

# Budowanie kernela+bootloadera
BUILD_TYPE="${1:-release}"
DISK_FILE="${2:-disk.raw}"
BOOT_IMG="${3:-target/x86_64-unknown-none/release/bootimage-luxseq-core.bin}"
DISK_SIZE="${4:-30G}"

if [ "$BUILD_TYPE" = "debug" ]; then
    echo "🐛 DEBUG BUILD"
    time cargo bootimage --target x86_64-unknown-none
    OUTPUT_PATH="target/x86_64-unknown-none/debug/bootimage-luxseq-core"
elif [ "$BUILD_TYPE" = "release" ]; then
    echo "⚡ RELEASE BUILD"
    time cargo bootimage --release --target x86_64-unknown-none
    OUTPUT_PATH="target/x86_64-unknown-none/release/bootimage-luxseq-core.bin"
elif [ "$BUILD_TYPE" = "cargo" ]; then
    echo "📏 SIZE OPTIMIZED BUILD"
    time cargo build --release --target x86_64-unknown-none
    OUTPUT_PATH="target/x86_64-unknown-none/release/luxseq-core"
else
    echo "❌ Nieznany typ builda: $BUILD_TYPE"
    echo "   Dostępne opcje: debug, release, size"
    exit 1
fi

echo ""
echo "✅ Kernel kompilacja gotowa!"
echo "📍 $OUTPUT_PATH"
file "$OUTPUT_PATH"
ls -lh "$OUTPUT_PATH"
echo ""

echo "📝 K1: Tworzenie sparse disk.raw..."
truncate -s "$DISK_SIZE" "$DISK_FILE"
echo "   ✓ OK"

echo "📝 K2: Zapis bootloadera..."
dd if="$BOOT_IMG" of="$DISK_FILE" bs=512 conv=notrunc status=none
sync
echo "   ✓ OK"

# Opcjonalnie: deployment
if [ "$2" = "deploy" ] || [ "$2" = "gcp" ]; then
    DISK_FILE="${3:-disk.raw}"

    echo "📦 Deployment na GCP..."
    echo ""
    ./deploy-gcp.sh "$DISK_FILE"
fi