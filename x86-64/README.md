# Baremetal-HelloQEMU

## How it works:
QEMU refuses to boot using the -kernel argument for x86-64 ELF64 files:

(see https://github.com/qemu/qemu/blob/master/hw/i386/multiboot.c#L199)

Which forces us to create an image to pass to QEMU, this image needs to be
multiboot2 compatible, this is achievable by piggybacking into grub2,
specifically `grub-mkrescue`, however `grub-mkrescue` requires some extra runtime
dependencies and files that usually come from the hosts own grub installation,
since this is meant to work with OpenEmbedded, this complicated things a bit
due to host contamination and `xorriso` coming from *meta-oe* instead of *oe-core*,
instructions to use `grub-mkrescue` are still included informative purposes,
folks are welcome to use that if they please but it wont be considered default.


QEMU that can boot if we place the artifacts in the correct place
(stage1 bootloader, stage2 bootloader and the kernel itself), essentially this
solution boots into real mode (16 bit 8086 emulation mode) via the stage1
bootloader, which jumps to the stage2 bootloader to load the 64 bit kernel and
get into protected mode (32 bit), to finally jump into the loaded 64 bit kernel.


## Creating an image ####

### Using dd
An iso image can be created via dd by placing artifacts in the right location:
```
dd if=/dev/zero of=build/iso.img bs=1M count=10 status=none
dd if=build/stage1.bin of=build/iso.img bs=512 count=1 conv=notrunc
dd if=build/stage2.bin of=build/iso.img bs=512 seek=1 count=64 conv=notrunc
dd if=build/hello_baremetal_x86-64.bin of=build/iso.img bs=512 seek=65 conv=notrunc
```
###  or

### Using grub-mkrescue
An image can also be created relying on `grub-mkrescue` using:
```
mkdir -p isofiles/boot/grub
cp build/hello_baremetal_x86-64.elf isofiles/boot/
cp grub.cfg isofiles/boot/grub
grub-mkrescue -o iso.img isofiles
```
where the contents of a simple grub.cfg are:
```
timeout=0
default=0
menuentry "Hello Baremetal X86-64 kernel" {
  multiboot2 /boot/hello_baremetal_x86-64.elf hello_baremetal_x86-64.elf
}
```


## Booting in QEMU ####
This is meant to be used with OpenEmbedded, simply running runqemu works automatically:
```
$ runqemu nographic
Hello OpenEmbedded on x86-64!
```

It also can be booted manually by invoking:
```
qemu-system-x86_64  -m 128 -drive file=build/iso.img,index=0,media=disk,format=raw -nographic
Hello OpenEmbedded on x86-64!
```