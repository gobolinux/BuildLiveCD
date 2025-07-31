# BuildLiveCD

This package contains utilities used to create the LiveCD environment, consisting of three major scripts: `UpdateEnvironment`, `CompressAndBuildISO`
as well as `RefreshLiveCD`.

We support two methods of ISO generation:
The first method generates a new ISO
from *scratch*, while the second method allows you to iterate upon an *existing*
ISO. 

> [!NOTE]
> All commands below are supposed to be run as root.

## Method 1

* **`UpdateEnvironment`**: This script fetches + compiles the ISOLINUX
  bootloader and the BusyBox package that lives in the LiveCD's initrd. It also
  fetches a copy of GoboLinux'
  [`InitRDScripts`](https://github.com/gobolinux/InitRDScripts) project, which
  is later packaged next to BusyBox in the initrd. The GoboLinux logo shown when
  booting the ISO is also handled here. This script converts the logo from PPM
  to LSS16 (the actual format understood by ISOLINUX.)

* **`CompressAndBuildISO`**: This script performs the automated generation of
  the LiveCD tree. It is divided in 4 different stages:

    1. ***ROLayer:*** given a list of GoboLinux binary packages and an empty
  target directory, this stage creates a new root filesystem tree (including
  `/System/Settings`, Aliens, and the legacy symlinks under `/`) and
  uncompresses all packages under `/Programs`. The default target directory is
  `Output/ROLayer`.

    2. ***SquashFS:*** creates a set of squashfs images from the *ROLayer*. The
  binary packages put on each squashfs image are selected according to the
  contents of the files at `BuildLiveCD/Data/Packages-List-*`. The generated
  squashfs files are saved under `Output/ISO`.

    3. ***InitRD:*** creates an initrd image by merging the `InitRDScripts` and
  `BusyBox` packages fetched earlier by `UpdateEnvironment`. The image, a
  compressed RAM filesystem, is stored as `Output/ISO/isolinux/initrd` once it's
  been prepared.

    4. ***ISO:*** this last stage runs *mkisofs* on `Output/ISO` (to produce an
  ISO file) and makes that ISO file hybrid so it boots when copied to a USB mass
  storage device. The output file is saved as `Output/GoboLinux-NoVersion.iso`.

## Method 2

* **`RefreshLiveCD`**: This script provides an alternative, more simplistic
  approach by iterating upon an existing ISO as a base. The first time it is
  called, the script extracts all squashfs images from a reference ISO to a
  given work directory. When called a second time, it can take an extra
  argument: a path with a collection of tarballs (GoboLinux packages, in
  *.tar.bz2* format). The script will then update the old versions with the new
  ones and will regenerate an ISO.

> [!IMPORTANT]
> Ensure that kernel module *loop* is loaded: `sudo modprobe loop`.

  *Usage:*
  ```
  # RefreshLiveCD <ISO_image> <work_dir> (<package_dir>)
  ```

> [!WARNING]
> Your currently symlinked kernel *has* to match the one found on the ISO –
> else initramfs generation will fail! In case of mismatch, you can supply
> your current/desired kernel via `<package_dir>` as a package.
