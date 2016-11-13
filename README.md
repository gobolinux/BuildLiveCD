# BuildLiveCD

This package contains utilities used to create the LiveCD environment. There are
two major scripts in this package: UpdateEnvironment and CompressAndBuildISO.

* UpdateEnvironment: 
This script fetches + compiles the ISOLINUX bootloader and the BusyBox package
that lives in the LiveCD's initrd. It also fetches a copy of GoboLinux'
InitRDScripts project, which is later packaged next to BusyBox in the initrd.
The GoboLinux logo shown when booting the ISO is also handled here. This script
converts the logo from PPM to LSS16 (the actual format understood by ISOLINUX.)

* CompressAndBuildISO:
This script performs the automated generation of the LiveCD tree. It is divided
in 4 different stages:

  1. ROLayer: given a list of GoboLinux binary packages and an empty target directory,
this stage creates a new root filesystem tree (including /System/Settings, Aliens,
and the legacy symlinks under /) and uncompresses all packages under /Programs.
The default target directory is `Output/ROLayer`.

  2. SquashFS: creates a set of squashfs images from the ROLayer. The binary packages
put on each squashfs image are selected according to the contents of the files at
`BuildLiveCD/Data/Packages-List-*`. The generated squashfs files are saved under
`Output/ISO`.

  3. InitRD: creates an initrd image by merging the InitRDScripts and BusyBox packages
fetched earlier by UpdateEnvironment. The image, a compressed RAM filesystem, is
stored as `Output/ISO/isolinux/initrd` once it's been prepared.

  4. ISO: this last stage runs mkisofs on Output/ISO (to produce an ISO file) and
makes that ISO file hybrid so it boots when copied to a USB mass storage device.
The output file is saved as `Output/GoboLinux-NoVersion.iso`.
