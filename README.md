# Baremetal-HelloQEMU

Baremetal QEMU examples

These are introductory examples to showcase the use of QEMU to run baremetal applications.

## Build Status

| master  | [![Build Status][masterbadge]][masterpipeline]   |
|:-------:|--------------------------------------------------|
| dunfell | [![Build Status][dunfellbadge]][dunfellpipeline] |

[masterbadge]: https://dev.azure.com/aehs29/baremetal-qemu/_apis/build/status/baremetal-helloqemu?branchName=master
[masterpipeline]: https://dev.azure.com/aehs29/baremetal-qemu/_build/latest?definitionId=29&branchName=master
[dunfellbadge]: https://dev.azure.com/aehs29/baremetal-qemu/_apis/build/status/baremetal-helloqemu?branchName=dunfell
[dunfellpipeline]: https://dev.azure.com/aehs29/baremetal-qemu/_build/latest?definitionId=29&branchName=dunfell

## Usage: The Yocto Project & OpenEmbedded
While these examples can easily be built manually using a toolchain from the host system, its purpose is to serve as examples for baremetal application programming on The Yocto Project and OpenEmbedded which allow users to build and run these examples, along with the required toolchain and QEMU easily using the following steps:

1.- Clone the required repositories (Use -b dunfell or -b kirkstone if you want a stable release)
```bash
$ git clone https://git.yoctoproject.org/git/poky
$ cd poky
```
2.- Source the build environment file
```bash
$ source oe-init-build-env
```
3.- Add the required variables to your local.conf (Supported MACHINES are qemuarm64,qemuarm,armuarmv5)
```bash
$ echo "MACHINE = \"qemuarm64\"" >> ./conf/local.conf
$ echo "TCLIBC = \"baremetal\"" >> ./conf/local.conf
```
4.- Build the application
```bash
$ bitbake baremetal-helloworld
```
5.- Run the baremetal application on QEMU:
```bash
$ runqemu nographic
```
Example output:
```bash
runqemu - INFO - Running bitbake -e ...
runqemu - INFO - Continuing with the following parameters:
KERNEL: [tmp/deploy/images/qemuarm64/baremetal-helloworld-qemuarm64.bin]
MACHINE: [qemuarm64]
FSTYPE: [bin]
ROOTFS: [tmp/deploy/images/qemuarm64/baremetal-helloworld-qemuarm64.bin]
CONFFILE: [tmp/deploy/images/qemuarm64/baremetal-helloworld-qemuarm64.qemuboot.conf]

Hello OpenEmbedded!

```
## License & Credit

This work is based on what was done on:

[Qemu versatile baremetal](https://balau82.wordpress.com/2010/02/28/hello-world-for-bare-metal-arm-using-qemu/) and [qemu-sandbox](https://github.com/balau/arm-sandbox)
by Francesco B.

It was initially licensed as CC-BY-SA but the author has agreed to use the MIT License instead.

The above supported the versatilepb architecture, and this code has been rewritten to work properly on newer architectures such as cortex-a15 (virt and vexpress), cortex-a57, cortex-a53, cortex-a72 (virt), etc.
