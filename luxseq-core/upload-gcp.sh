#!/bin/bash
# Szybki upload kernel image na GCP
# GCP wymaga tar.gz formatu dla raw images

set -e

BUCKET="${1:-nowy2}"
DISK_FILE="disk"
TAR_FILE="$DISK_FILE.tar.gz"
GCS_PATH="gs://$BUCKET/$TAR_FILE"

echo "🚀 LuxSeq → GCP Pipeline"
echo "========================"
echo ""

#echo "📝 K4: Upload GCP..."
gsutil -m cp "$DISK_FILE.tar.gz" "gs://$BUCKET/"
echo "   ✓ OK"

echo "📝 K5: Image..."
gcloud compute images describe luxseq-image >/dev/null 2>&1 && \
  gcloud compute images delete luxseq-image --quiet 2>/dev/null || true
gcloud compute images create luxseq-image \
  --source-uri="gs://$BUCKET/$DISK_FILE.tar.gz" \
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