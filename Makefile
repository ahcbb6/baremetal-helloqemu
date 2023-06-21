# Force QEMUARCH variable to be passed to check for which
# architecture the source code is being built
ifndef QEMUARCH
$(error QEMUARCH needs to be passed as an argument to make)
endif

ifeq ($(QEMUARCH),x86-64)
$(error Something went wrong, this Makefile should not be used when QEMUARCH=x86-64, use Makefile from x86-64 directory instead)
endif

BUILDDIR=build/

contains = $(foreach v,$2,$(if $(findstring $1,$v),$v))

sources:=$(addsuffix ${QEMUARCH}, hello_baremetal_ startup_)
outfiles:=$(addprefix ${BUILDDIR}, ${sources})
objs:=$(addsuffix .o, ${outfiles})
lscript:=$(addsuffix ${QEMUARCH}, linkerscript_)
executable:=$(strip $(call contains,hello,${outfiles}))

# Target rules
all: build

# Create a raw binary from ELF
build: link
	${OBJCOPY} -O binary ${executable}.elf ${executable}.bin

# Link objects using the provided linker script
link: compile
	sed -i 's~startup.o~$(call contains,startup,${objs})~g' ${lscript}.ld
	${LD} -T${lscript}.ld ${objs} -o ${executable}.elf

# Compile source but dont link
compile: assemble
	${CC} ${CFLAGS} ${LDFLAGS} -c $(filter hello%,${sources}).c -o $(call contains,hello,${objs})

# Assemble startup code
ifeq ($(QEMUARCH),x86)
assemble: | builddir
# startup code for qemux86 is using Intel syntax
	nasm -f elf32 $(filter startup%,${sources}).s -o $(call contains,startup,${objs})
else
assemble: | builddir
	${AS} $(filter startup%,${sources}).s -o $(call contains,startup,${objs})
endif

builddir:
	mkdir -p ${BUILDDIR}

clean:
	rm -f ${BUILDDIR}*.o
	rm -f ${BUILDDIR}*.elf
	rm -f ${BUILDDIR}*.bin
