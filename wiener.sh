#!/bin/sh

# This short script will help you install Autodesk Fusion 360 on your Arch based Linux distribution
# Forked from https://github.com/link12765/Fusion-360-Arch-Linux-Script
# Original Author: Dylan Dean Goebel - Contact: goebeld @ https://www.reddit.com/user/goebeld
# 
# Modified by Andrej Kenda (Kndndrj)

###########################################################
## Presets                                               ##
###########################################################
RED="\033[1;31m"
GREEN="\033[1;32m"
BROWN="\033[1;33m"
BLUE="\033[1;34m"
NC="\033[0m"
USAGE="$0 <package> [command] [options]\n\
  Commands:\n\
    install [-p, -t, -l]:\n\
      Downloads and installs specified package on your system.\n\
      Uses wineprefix for installation, temporary directory for storing downloads\n\
      and log directory for storing log files.\n\
    install-clean [-p, -t, -l]:\n\
      Uninstalls any found instances of the specified package before downloading and installing.\n\
      Uses wineprefix for installation, temporary directory for storing downloads\n\
      and log directory for storing log files.\n\
    uninstall:\n\
      Uninstalls any found instances of the specified package from the system.\n\n\
  Options:\n\
    -p <wine_prefix>  -- Path to directory to put a wineprefix in (basically an install directory),\n\
                         must be an absolute path!\n\
    -t <temp_dir>     -- Path to temporary directory (where to store downloads).\n\
    -l <log_dir>      -- Specify your own log file.\n\
    -h                -- Print this message and exit\n\n\
  To find availible packages, try runnig: \"$0 list-packages\"\n\n\
  For more information, check README.md at \"https://github.com/Kndndrj/wiener\""
  
FAIL_MESSAGE="${RED}Installation failed!${NC}\n\
  The file may be corrupt!\n\
  Please consider doing a clean install.\n\
  If you already tried that, check that you have the appropriate drivers installed.\n"
PACKAGE_URL="https://raw.githubusercontent.com/Kndndrj/wiener/master/packages"

###########################################################
## Helper functions                                      ##
###########################################################
install_prerequisites() {
  printf "\n${GREEN}Updating the system and installing prerequisites!${NC}\n\n"

  sudo pacman --needed -Syu "$@"
  if [ $? -ne 0 ]; then
    printf "${RED}Required packages could not be installed!${NC}\n"
    printf "Please make sure that you have enabled the \"multilib\" repository for pacman!\n"
    printf "To do this, uncomment the following lines in \"/etc/pacman.conf\":\n"
    printf "\t[multilib]\n"
    printf "\tInclude = /etc/pacman.d/mirrorlist\n\n"
    exit 1
  fi
}

retrieve_install_script() {
  # Install basic packages
  install_prerequisites wine wine-gecko wine-mono curl p7zip wget

  # Download package install
  printf "Retrieving package install script\n"
  mkdir -p /tmp/wiener
  wget --show-progress -q -P /tmp/wiener/ "$PACKAGE_URL/$PACKAGE_NAME"
  if [ $? -ne 0 ]; then
    printf "Package does not exist: $PACKAGE_NAME\n"
    exit 1
  fi
  printf "\n"

  # Source the package install and delete the file afterward
  . /tmp/wiener/$PACKAGE_NAME
  rm -rf /tmp/wiener
}


###########################################################
## Parse arguments                                       ##
###########################################################
parse_arguments() {
  # Parse additional arguments
  while getopts ":p:t:l:" option; do
    case "${option}" in
      p) 
        INSTALLDIR=${OPTARG};;
      t) 
        TEMPDIR=${OPTARG};;
      l)
        LOGDIR=${OPTARG};;
      :)
        printf "${RED}Error${NC}: Option \"-${OPTARG}\" requires an argument.\nUsage:\n${USAGE}\n"
        exit 1;;
      *)
        printf "${RED}Error${NC}: invalid argument: \"-${OPTARG}\".\nUsage:\n${USAGE}\n"
        exit 1;;
    esac
  done

  # Check for $INSTALLDIR and $TEMPDIR, use defaults if not specified
  if [ -z "$INSTALLDIR" ]; then
    INSTALLDIR="$HOME/.local/share/wiener/$PACKAGE_NAME"
  fi
  if [ -z "$TEMPDIR" ]; then
    TEMPDIR="$HOME/.local/share/wiener/$PACKAGE_NAME-temp/"
  fi
  if [ -z "$LOGDIR" ]; then
    LOGDIR="$TEMPDIR/logs"
  fi
}

###########################################################
## Procedures                                            ##
###########################################################
install() {
  retrieve_install_script

  parse_arguments "$@"

  printf "${BROWN}Start of installation${NC}\n"

  # Check if the $INSTALLDIR already exists
  if [ -d "$INSTALLDIR" ]; then
    printf "${BROWN}Warning${NC}: The directory \"$INSTALLDIR\" already exists!\n"
    printf "         Do you want to overwrite this directory anyway? [y/N] "
    read answer
    if [ "$answer" != "y" ] && [ "$answer" != "Y" ]; then
      printf "         Aborting install!\n"
      exit 1
    else
      # Delete install directory, but preserve the previous uninstall data
      printf "         Moving on with the install!\n"
      mv "$INSTALLDIR/$PACKAGE_NAME-wiener-uninstall.data" "/tmp/" 2>/dev/null
      rm -rf $INSTALLDIR
      mkdir -p $INSTALLDIR
      mv "/tmp/$PACKAGE_NAME-wiener-uninstall.data" "$INSTALLDIR/" 2>/dev/null
    fi
  fi

  # Wait for conformation
  printf "Specified directories are:\n"
  printf "Prefix directory:     $INSTALLDIR\n"
  printf "Temporary directory:  $TEMPDIR\n"
  printf "Log directory:        $LOGDIR\n"
  printf "Continue? [y/N] "
  read answer
  if [ "$answer" != "y" ] && [ "$answer" != "Y" ]; then
    printf "Aborting!\n"
    exit 1
  fi

  install_prerequisites $PACKAGE_PREREQUISITES

  # Make the required directories
  mkdir -p $INSTALLDIR
  mkdir -p $TEMPDIR
  mkdir -p $LOGDIR

  # Store directories in a file for uninstall
  printf "$INSTALLDIR\n$TEMPDIR\n$LOGDIR\n" >> $INSTALLDIR/$PACKAGE_NAME-wiener-uninstall.data

  download_packages
  install_packages

  # Exit message
  printf "\n\n\n${GREEN}$PACKAGE_NAME has been installed!${NC}\n"
  printf "\n\nWine should have automatically created a \".desktop\" file in ~/.local/share/applications/wine/Programs/\n"
  printf "If that's not the case, check \"help\" (-h flag).\n\n"

  # Removing the temporary directory
  printf "One more thing. If the installation didn't go according to plan,\n"
  printf "you don't have to download all the files again if you keep the temporary directory.\n"
  printf "Do you want to keep it (\"$TEMPDIR\")? [y/N] "
  read answer
  if [ "$answer" != "y" ] && [ "$answer" != "Y" ]; then
    printf "Removing $TEMPDIR!\n"
    rm -rf $TEMPDIR
  fi

  printf "Done!\n"
}

uninstall() {
  printf "${BROWN}Uninstalling $PACKAGE_NAME${NC}\n"

  # Find the uninstall file
  uninstall_file="$(find $HOME/ -name "$PACKAGE_NAME-wiener-uninstall.data" -type f 2>/dev/null)"
  num_of_uninstalls=$(printf "$uninstall_file\n" | wc -l)

  if [ -z "$uninstall_file" ]; then
    printf "It seems that you don't have $PACKAGE_NAME installed on your system!\n"
    return
  fi

  # If there are more than one "...uninstall.data" found, let the user choose.
  if [ $num_of_uninstalls -gt 1 ]; then
    printf "More than one instance of $PACKAGE_NAME found.\n"
    printf "$(dirname $uninstall_file)\n" | nl
    printf "Which one do you want to remove? [1-$num_of_uninstalls] [0 - remove all] "
    read answer
    if [ $answer -gt $num_of_uninstalls ] 2>/dev/null || \
       [ $answer -lt 0 ] 2>/dev/null || \
       ! [ "$answer" -eq "$answer" ] 2>/dev/null; then
      printf "Not a valid choice! Try uninstalling again.\n"
      exit 1
    fi
    # If answer equals 0 then all choices will be deleted
    if [ $answer -ne 0 ]; then
      uninstall_file=$(printf "$uninstall_file\n" | sed -n ${answer}p)
    fi
  fi

  printf "The following directories will be removed:\n"
  sort $uninstall_file | uniq
  printf "Continue? [y/N] "
  read answer
  if [ "$answer" != "y" ] && [ "$answer" != "Y" ]; then
    printf "Aborting!\n"
    exit 1
  fi

  # Remove the files
  for file in $(sort $uninstall_file | uniq); do
    printf "Removed file: $file\n"
    rm -rf "$file"
  done
  printf "\n\n${GREEN}$PACKAGE_NAME is now uninstalled!${NC}\n"
}

list_packages() {
  PACKAGE_LIST=$(curl --silent "https://api.github.com/repos/kndndrj/wiener/contents/packages")
  printf "$PACKAGE_LIST\n" | grep -E "\bname\b\":" | sed -E "s/.*\"([^\"]+)\".*/\1/"
}

###########################################################
## Entry point                                           ##
###########################################################
# Get package name
PACKAGE_NAME="$1"
[ -z "$PACKAGE_NAME" ] && exit 1
[ "$PACKAGE_NAME" = "-h" ] && printf "${USAGE}\n" && exit
[ "$PACKAGE_NAME" = "list-packages" ] && list_packages && exit

shift

# Get procedure
case "$1" in
  install)
    shift
    install "$@"
    exit;;
  install-clean)
    shift
    uninstall
    install "$@"
    exit;;
  uninstall)
    uninstall
    exit;;
  *)
    printf "Invalid usage\n"
    printf "Only use one of these:\n"
    printf "\"$0 <pkg> install\"\n\"$0 <pkg> install-clean\"\n\"$0 <pkg> uninstall\"\n"
    printf "For help, run: \"$0 -h\"\n"
    exit 1
esac
