# Force QEMUARCH variable to be passed to check for which
# architecture the source code is being built
ifndef QEMUARCH
$(error QEMUARCH needs to be passed as an argument to make)
endif

ifneq ($(QEMUARCH),x86-64)
$(error Something went wrong, this Makefile should only be used when QEMUARCH=x86-64)
endif

BUILDDIR=../build/

# Target rules
all: build

# Create a raw binary from ELF
build: link
	${OBJCOPY} -O binary ${BUILDDIR}/hello_baremetal_x86-64.elf ${BUILDDIR}/hello_baremetal_x86-64.bin
	${OBJCOPY} -O binary ${BUILDDIR}/stage1.elf ${BUILDDIR}/stage1.bin
	${OBJCOPY} -O binary ${BUILDDIR}/stage2.elf ${BUILDDIR}/stage2.bin

# Link objects using the provided linker script
link: compile
# kernel
	${LD} -n -Tkernel/kernel.ld ${BUILDDIR}/bsp_init.o ${BUILDDIR}/multiboot2.o ${BUILDDIR}/kernel.o -o ${BUILDDIR}/hello_baremetal_x86-64.elf
# stage1 bootloader
	${LD} -m elf_i386 -Tstage1/stage1.ld ${BUILDDIR}/s1init.o -o ${BUILDDIR}/stage1.elf
# stage2 bootloader
	${LD} -m elf_i386 -Tstage2/stage2.ld ${BUILDDIR}/protected_mode.o  ${BUILDDIR}/stage2.o  ${BUILDDIR}/stage2_loader.o -o ${BUILDDIR}/stage2.elf


# Compile source but dont link
compile: assemble
# kernel (mcmodel=large since code is linked to high memory)
	${CC} ${CFLAGS} -mcmodel=large ${LDFLAGS} -c kernel/hello_baremetal_x86-64.c -o ${BUILDDIR}/kernel.o
# stage 2
	${CC} ${CFLAGS} ${LDFLAGS} -m32 -c stage2/stage2_loader.c -o ${BUILDDIR}/stage2_loader.o


# Assemble startup code
assemble: builddir
# kernel
	${AS} kernel/bsp_init.s -o ${BUILDDIR}/bsp_init.o
# Pass multiboot2.S through the preprocessor
	${CC} -E kernel/multiboot2.S > ${BUILDDIR}/multiboot2.s
	${AS} ${BUILDDIR}/multiboot2.s -o ${BUILDDIR}/multiboot2.o
# stage1 bl
	${AS} --32 stage1/s1init.s -o ${BUILDDIR}/s1init.o
# stage2 bl
	${AS} --32 stage2/stage2.s -o ${BUILDDIR}/stage2.o
	${AS} --32 stage2/protected_mode.s -o ${BUILDDIR}/protected_mode.o

builddir:
	mkdir -p ${BUILDDIR}

clean:
	rm -f ${BUILDDIR}*.o
	rm -f ${BUILDDIR}*.elf
	rm -f ${BUILDDIR}*.bin

# Create bootable image using grub-mkrescue
grub: build
	mkdir -p isofiles/boot/grub
	cp ${BUILDDIR}/hello_baremetal_x86-64.elf isofiles/boot/hello_baremetal_x86-64-grub.elf
	cp grub.cfg isofiles/boot/grub
	grub-mkrescue -o hello_baremetal_x86-64-grub.img isofiles
