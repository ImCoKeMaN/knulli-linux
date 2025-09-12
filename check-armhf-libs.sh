#!/bin/bash

# list libraries in 64 and 32 bit builds
ls output/h700/target/usr/lib | awk 'BEGIN {FS="."} {print $1}' |grep lib | sort | uniq > ./liblist64.txt
ls output/h700_armhf_libs/target/usr/lib | awk 'BEGIN {FS="."} {print $1}' |grep lib | sort | uniq > ./liblist32.txt

echo
echo Missing libs:

if [[ $1 == '-a' ]]; then
  diff ./liblist64.txt ./liblist32.txt | grep lib | grep \<
  exit 0
fi

ignored='avahi libdns_sd' # avahi
ignored+=' samba libsmb libsamdb libnss libndr' # samba
ignored+=' libtevent wbclient dcerpc libnetapi' # samba
ignored+=' nfsid ntfs libbtrfs libext2fs libe2p libcom_err libss' # fs
ignored+=' libfdisk libparted' # fs
ignored+=' pigpio bluetooth libi2c' # hw
ignored+=' libelf libdw libasm' # elfutils
ignored+=' libgamestream moonlight' # moonlight
ignored+=' lightspark mupen libretro solarus' # emulators
ignored+=' mosquitto libxtables' # net
ignored+=' alpm' # pacman
ignored+=' libSAASound' # used by simcoupe
ignored+=' libSDL2_mixer_ext' # used by thextech
ignored+=' libgomp' # gcc
ignored+=' libip4tc libip6tc' # iptables
ignored+=' libprocps' # procps
ignored+=' libsyslog' # sysklogd

diff ./liblist64.txt ./liblist32.txt | grep lib | grep \< > libdiff.txt

for ignore in $ignored; do
  grep -v $ignore libdiff.txt > libdiff.txt.grep
  mv libdiff.txt.grep libdiff.txt
done

cat libdiff.txt
rm libdiff.txt
