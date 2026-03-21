#!/bin/bash
# Deploy raw bootimage na GCP (bez GRUB)

set -e

DISK_FILE="${1:-disk.raw}"

echo "🌩️  GCP Kernel Deployment (bootimage)"
echo "====================================="
echo "Disk:       $DISK_FILE"
echo ""


echo "📝 K3: Sprawdzenie obrazu..."
ls -lh "lux_loader/$DISK_FILE"
tar -Sczf "lux_loader/$DISK_FILE.tar.gz" -C lux_loader "$DISK_FILE"
echo "   ✓ OK"

echo "📝 K4: Upload GCP..."
gsutil -m cp "lux_loader/$DISK_FILE.tar.gz" "gs://nowy2/"
echo "   ✓ OK"

echo "📝 K5: Image..."
gcloud compute images describe luxseq-image >/dev/null 2>&1 && \
  gcloud compute images delete luxseq-image --quiet 2>/dev/null || true
gcloud compute images create luxseq-image \
  --source-uri="gs://nowy2/$DISK_FILE.tar.gz" \
  --architecture=X86_64 \
  --guest-os-features=UEFI_COMPATIBLE \
  --quiet
echo "   ✓ OK"

echo "📝 K6: VM..."
gcloud compute instances describe luxseq-vm --zone=us-central1-a >/dev/null 2>&1 && \
  gcloud compute instances delete luxseq-vm --zone=us-central1-a --quiet 2>/dev/null || true
gcloud compute instances create luxseq-vm \
  --image=luxseq-image --machine-type=e2-micro --zone=us-central1-a --metadata serial-port-enable=TRUE --quiet
echo "   ✓ OK"

echo ""
echo "🎉 Done!"
