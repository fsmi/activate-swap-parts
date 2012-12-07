#! /bin/sh
### BEGIN INIT INFO
# Provides:          activate-swap-parts
# Required-Start:    mountall
# Required-Stop:
# Default-Start:     S
# Default-Stop:
# Short-Description: mount all swap partitions.
# Description:       Attempts to use all swap partitions on
#                    all hard disks.
### END INIT INFO

# Copyright (C) 2008  Fabian Knittel <fabian.knittel@avona.com>

. /lib/lsb/init-functions

[ -x /sbin/sfdisk -a -x /bin/grep -a -x /bin/sed ] || exit 1

kernel_cmdline_swaps() {
	for x in $(cat /proc/cmdline); do
		case $x in
		  SWAP=*)
			echo ${x#SWAP=}
			;;
		esac
	done
}
fdisk_swaps() {
	LANG=C /sbin/sfdisk -l -L -d 2>/dev/null | \
		/bin/grep '^/dev/.* : .*Id=82' | \
		/bin/sed -e 's,^\(/dev/[a-z0-9]\+\) :.*,\1,'
}
whole_disk_swaps () {
	LANG=C /usr/bin/file -sL /dev/[hsvx]d? | \
		/bin/fgrep 'swap file' | \
		/usr/bin/cut -d: -f1
}

case "$1" in
  start|"")
	swap_partitions=$(fdisk_swaps; whole_disk_swaps; kernel_cmdline_swaps)
	for swap_part in ${swap_partitions}; do
		log_action_begin_msg "Activating swap on partition ${swap_part}"
		swapon "${swap_part}"
		log_action_end_msg $?
	done
	;;
  restart|reload|force-reload)
	echo "Error: argument '$1' not supported" >&2
	exit 3
	;;
  stop)
	# No-op
	;;
  *)
	echo "Usage: activate-swap-parts.sh [start|stop]" >&2
	exit 3
	;;
esac

: 
