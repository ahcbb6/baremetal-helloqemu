# Force QEMUARCH variable to be passed to check for which
# architecture the source code is being built
ifndef QEMUARCH
$(error QEMUARCH needs to be passed as an argument to make)
endif

ifndef LIBC
LIBC="baremetal"
endif

BUILDDIR=build/

contains = $(foreach v,$2,$(if $(findstring $1,$v),$v))
# LIBS="-L../recipe-sysroot/usr/lib/ -l:libc.a"

ifeq ($(LIBC),newlib)
ifneq ($(QEMUARCH),aarch64)
sources:=$(addsuffix ${QEMUARCH}, hello_baremetal_ startup_)
else
sources:=$(addsuffix ${QEMUARCH}, hello_newlib_ startup_)
endif
else
sources:=$(addsuffix ${QEMUARCH}, hello_baremetal_ startup_)
endif

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
link: assemble compile
	sed -i 's~startup.o~$(call contains,startup,${objs})~g' ${lscript}.ld
	${LD} -T${lscript}.ld ${objs} $(LIBS) -o ${executable}.elf

# Assemble startup code
assemble: builddir
	${AS} $(filter startup%,${sources}).s -o $(call contains,startup,${objs})

# Compile source but dont link
# ${CC} -c $(filter hello%,${sources}).c -o $(call contains,hello,${objs})
compile:
	${CC} ${CFLAGS} ${LDFLAGS} -c $(filter hello%,${sources}).c -o $(call contains,hello,${objs})

builddir:
	mkdir -p ${BUILDDIR}

clean:
	rm -f ${BUILDDIR}*.o
	rm -f ${BUILDDIR}*.elf
	rm -f ${BUILDDIR}*.bin
