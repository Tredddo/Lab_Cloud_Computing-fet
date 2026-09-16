# Dockerized FET (University Project)

> **Special Thanks to the Creator**
> Before diving into this Docker implementation, a massive and heartfelt thank you goes to **Liviu Lalescu**, developer of FET. His dedication to developing and distributing this software globally, at no cost, represents a significant contribution to the educational community. His commitment to the open-source community are truly inspiring.

This repository provides containerized environments to run **FET**, the free timetabling software, using Podman/Docker.

It includes two setups:
1. `Dockerfile`: Downloads and runs the official pre-compiled binaries (Published to Docker Hub [tredddo/fet](https://hub.docker.com/repository/docker/tredddo/fet)).
2. `Dockerfile.source`: Builds FET from source using the [rodolforg/fet](https://github.com/rodolforg/fet) repository.

## Use the app inside Podman

*Note: I use Podman, but Docker commands are fully compatible.*

Build the image locally:
```bash
podman build -t fet .
```

Run the container (interactive bash or list files):
```Bash

podman run --rm -it --entrypoint /bin/bash localhost/fet:latest
podman run --rm --entrypoint ls localhost/fet:latest -la
```

## Import files and use the UI

If you want to use the graphical interface of FET, you need to forward the X11 socket to the container.

> **Security Warning (X11 Forwarding)**
> The use of `xhost` and the sharing of the `/tmp/.X11-unix` socket intentionally bypasses container display isolation. This setup is provided **strictly for local testing and development purposes** to access the UI.

```Bash
xhost +local:

podman run --rm -i \
  -e DISPLAY=$DISPLAY \
  -v /tmp/.X11-unix:/tmp/.X11-unix \
  -v ~/Downloads/fet-dev/examples/Italy/2010/:/app/data \
  --entrypoint ./bin/fet \
  localhost/fet-cli

# To disable:
xhost -local:
```

# Transparency & Development Process

As part of this university project, here is the documentation on how the environment was set up, tested, and published.

## How to publish images
```Bash

# Log in to Docker Hub (docker.io)
podman login docker.io

# Tag the image (with the version)
podman tag fet-cli:latest docker.io/<username>/<repo>:<tag>

# Push to Docker Hub
podman push docker.io/<username>/<repo>:<tag>
```

## VM Setup for compilation testing

To test the compilation environment securely, I used a QEMU Virtual Machine:
```Bash

# 1. Download ubuntu iso from the OFFICIAL website ([https://www.ubuntu-it.org/download](https://www.ubuntu-it.org/download))
# 2. Create the disk with qemu (qcow2 copy-on-write format)
qemu-img create -f qcow2 ubuntu-disk.qcow2 25G

# 3. Run the vm (NOTE: -m = RAM, -smp = Cores/Threads)
qemu-system-x86_64 -enable-kvm -m 4096 -smp 2 -hda ubuntu-disk.qcow2
```

## Dependencies & Packages used (Debian Bookworm)

### For the Build Stage:
> [!NOTE]
> The author of FET suggests compiling Qt. build-essential was suggested by the author and includes some of the packages listed and more.

    git, make, g++, build-essential

    qtchooser, qt5-qmake, qtbase5-dev, qtbase5-dev-tools

    ca-certificates, libqt5network5

### For rendering the UI (Runtime):

    libqt5core5a, libqt5xml5, libgl1, libglib2.0-0

    libqt5widgets5, libqt5gui5, libopengl0, libxcb-cursor0

## List of the link of the packages used

### For the Build Stage:
https://packages.debian.org/bookworm/git
https://packages.debian.org/bookworm/make
https://packages.debian.org/bookworm/g++
https://packages.debian.org/bookworm/build-essential
https://packages.debian.org/bookworm/qtchooser
https://packages.debian.org/bookworm/qt5-qmake
https://packages.debian.org/bookworm/qtbase5-dev
https://packages.debian.org/bookworm/qtbase5-dev-tools
https://packages.debian.org/bookworm/ca-certificates

https://packages.debian.org/bookworm/libqt5network5 (Required for update checks)

### For rendering the UI (Runtime):
https://packages.debian.org/it/bookworm/libqt5core5a
https://packages.debian.org/bookworm/libqt5xml5
https://packages.debian.org/bookworm/libgl1
https://packages.debian.org/bookworm/libglib2.0-0
https://packages.debian.org/bookworm/libqt5widgets5
https://packages.debian.org/bookworm/libqt5gui5
https://packages.debian.org/bookworm/libopengl0
https://packages.debian.org/bookworm/libxcb-cursor0

## Source Code Modifications (AGPL-3.0 Compliance)

During the creation of the `Dockerfile.source`, a minor modification to the original FET source code was required to ensure successful compilation in the Debian Bookworm environment due to a missing Qt header.

To fix the compilation error, the following command is applied automatically during the Docker build process to inject the missing `#include <QSet>` directive at the very first line of the code:

**File modified:** `src/interface/errorrenderer.cpp`
**Command applied:**
```bash
  sed -i '1s/^/#include <QSet>\n/' src/interface/errorrenderer.cpp
```

**License**

The Dockerfiles in this repository are released under the AGPL-3.0 License. FET is developed by Liviu Lalescu and licensed under AGPL-3.0.
