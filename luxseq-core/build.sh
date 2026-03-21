#!/bin/bash
set -e

path="lux_loader"
logs="logs"
disk_name="disk.raw"
disk="$path/$disk_name"
disk_image=""
b_lux_boot="false"
DEPLOY="false"
tar=""
DISK_FILE="disk.raw"
gcp="false"
RUN_QEMU="false"
b_kernel="false"
speaker="false"

mkdir $logs -p

while test $# -gt 0; do
    case "$1" in
    -h | --help) echo "Usage: $0 [options]"; echo "Options:"; echo "  -h, --help        Show this help message"; echo "  -truncate         Create a disk image using truncate"; echo "  -dump             Dump the binary content of the disk image"; echo "  -t, --test <file> Test the disk image with QEMU"; echo "  -b_lux_boot     Build the lux_boot from ASM code"; echo "  -tar <file>      Create a tar.gz archive of the disk image"; echo "  -deploy           Deploy the disk image to GCP"; echo "  -disk <file>     Specify a custom disk image file"; echo "  -gcp              Prepare for GCP deployment (creates and populates disk.raw)"; echo "  -run              Run the disk image in QEMU"; exit 0 ;;
    -t | --test) shift; hex="";;
    -b | --lux_boot) shift; b_lux_boot="true" ;;
    -k | --kernel) shift; b_kernel="true" ;;
    -s | --speaker) shift; speaker="true" ;;
    -tar) shift; tar="true"; DISK_FILE="$1"; shift; echo "Tar flag set to: $tar" ;;
    -d | --deploy) shift; DEPLOY="true" ;;
    -disk) shift; DISK_FILE="$1"; shift; echo "Disk flag set to: $DISK_FILE" ;;
    -gcp) shift; gcp="true" ;;
    -run) shift; RUN_QEMU="true" ;;
    *) echo "Unknown option: $1"; exit 1 ;;
    esac
done


if [ "$b_lux_boot" = "true" ]; then
    echo "🔧 Budowanie kodu ASM..."
    mkdir lux_loader -p
    nasm -f bin src/lux_boot.asm -o $path/lux_boot.bin 
    echo "   ✓ Kod ASM zbudowany"
else
    echo "⚠️  Pomijamy budowanie kodu ASM (build-asm)"
fi

echo ""

if [ "$b_kernel" = "true" ]; then
    echo "🔧 Budowanie kernela Rust..."
    cargo rustc --release -- -C link-arg=-Tlinker.ld
    llvm-objcopy -O binary target/x86_64-unknown-none/release/luxseq-core $path/kernel.bin
    objdump -d target/x86_64-unknown-none/release/luxseq-core | head -n 20 
    echo "   ✓ Kernel Rust zbudowany"
else
    echo "⚠️  Pomijamy budowanie kernela Rust (build-kernel)"
fi

if [ "$gcp" = "true" ]; then
    echo "📦 Deployment na GCP..."
    echo ""
    # 1. Stwórz surowy plik dysku (minimum 1GB dla GCP, żeby nie marudził)
    dd if=/dev/zero of=$disk bs=1M count=1024
    truncate -s 1G $disk
    echo "   ✓ Surowy plik dysku stworzony"
    # 2. Wypal swój lux_boot i kernel do tego pliku
    dd if=$path/lux_boot.bin of=$disk bs=512 conv=notrunc
    echo "   ✓ Bootloader wypalony"
<<<<<<< HEAD
    # Kernel wyłączony na życzenie architekta (Lux Logic Phase)
    # dd if=$path/kernel.bin of=$disk bs=512 seek=3 conv=notrunc
=======
    # dd if=$path/kernel.bin of=$disk bs=512 seek=1 conv=notrunc
    # echo "   ✓ Kernel wypalony"
>>>>>>> 4ebb20e (start)
    sync
    echo "   ✓ OK"
    hexdump -C $disk | head -n 32
    # 3. Spakuj to dokładnie tak, jak chce Google (format GNU tar!)
    tar --format=gnu -Sczf $path/lux_boot.tar.gz $disk_name
    ls -lh $disk
    echo "   ✓ Obraz dysku spakowany"
    # 4. Wyślij na GCP i stwórz maszynę
else
    echo "⚠️  Pomijamy deployment na GCP (deploy)"
fi

# Opcjonalnie: deployment
if [ "$DEPLOY" = "true" ]; then
    DISK_FILE="${1:-disk.raw}"

    echo "📦 Deployment na GCP..."
    echo ""
    ./deploy-gcp.sh "$DISK_FILE"
fi


# uruchom się na QEMU
if [ "$RUN_QEMU" = "true" ]; then
    echo "🚀 Uruchamianie na QEMU..."
    if [ "$speaker" = "true" ]; then
        # qemu-system-x86_64 -drive format=raw,file=disk.raw -serial stdio -soundhw pcspk
        qemu-system-x86_64 -audiodev pa,id=snd0 -machine pcspk-audiodev=snd0 -drive format=raw,file=$disk
    else
        qemu-system-x86_64 -drive format=raw,file=$disk -vga virtio -serial stdio -D $logs/qemu.log -d int,cpu_reset,guest_errors
    fi
    echo "   ✓ OK"
else
    echo "⚠️  Pomijamy uruchamianie na QEMU (run)"
fi