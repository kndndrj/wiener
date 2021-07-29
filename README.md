# Install Arch Linux Programs Through WINE
[![Wine - 6.13-1](https://img.shields.io/badge/Wine-6.13--1-red?style=for-the-badge)](https://www.winehq.org/) [![DXVK - v1.9](https://img.shields.io/badge/DXVK-v1.9-2ea44f?style=for-the-badge)](https://github.com/doitsujin/dxvk) [![winetricks - 20210206-next](https://img.shields.io/badge/winetricks-20210206--next-2ea44f?style=for-the-badge)](https://github.com/Winetricks/winetricks)

The script automatically downloads and installs the programs on your system and
it also installs any prerequisites first, so you don't have to worry about
them.

## Requirements
Before installing, please make sure to have the appropriate graphics drivers
installed. Reffer to
[Lutris](https://github.com/lutris/docs/blob/master/InstallingDrivers.md#arch--manjaro--other-arch-derivatives)
and [Arch](https://wiki.archlinux.org/title/Xorg#Driver_installation) wikis.

## Download
To download the script, open a new terminal window, navigate to a folder in
which you want to save the script (e.g. `cd ~/Downloads`) and copy the
following code snippet to the terminal:
```sh
curl -Lo wiener.sh https://raw.githubusercontent.com/Kndndrj/wiener/master/wiener.sh; \
chmod +x wiener.sh
```
That should have created a new file called `wiener.sh`.

Alternatively you can just clone the git repository.

## Usage
#### Simple Install
For a simple installation, just run:
```sh
./wiener.sh <package_name> install
```
#### Custom Install Directory
If you want to specify your own install directory and a directory to store
downloads to, run:
```sh
./wiener.sh <package_name> install -p <your/install/directory> -t <your/downloads/directory>
```
#### Installation Failed
If the installation process was interrupted or you have any other problems
during install, try using `install-clean` instead of `install`. For example:
```sh
./wiener.sh <package_name> install-clean -p <your/install/directory> ...
```
#### Uninstalling
To uninstall, simply run:
```sh
./wiener.sh <package_name> uninstall
```
And follow the on-screen instructions.
#### List Availible Packages
To list all packages that can be installed, run:
```sh
./wiener.sh list-packages
```
#### Special Cases
If you have any other needs, read `help`. You find it by running:
```sh
./wiener.sh -h
```

## Problems
#### Can't find a ".desktop" file
First check in ~/.local/share/applications. Desktop files should be somewhere
close.

## Other
If you have any other questions or comments, feel free to post them into the
[Issues](https://github.com/Kndndrj/wiener/issues) section.
