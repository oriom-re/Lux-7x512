#!/bin/bash
echo "🔒 Sealing Lux-7x512 Genesis Artifact..."

# 1. Clean build artifacts
rm -rf target/
rm -rf lux_loader/
rm -rf logs/
rm -f disk.raw

# 2. Create the Time Capsule
CAPSULE_NAME="lux_genesis_artifact_$(date +%Y%m%d).tar.gz"
cd ..
tar --exclude='target' --exclude='.git' --exclude='logs' -czf $CAPSULE_NAME luxseq-core/

echo "✅ Artifact sealed: ../$CAPSULE_NAME"
echo "   Ready for long-term storage."
echo "   Goodbye."