#!/bin/bash
# <SCRIPTNAME>
# <WHAT DOES THIS SCRIPT DO?>

# Alexander Swen
# Private contact: alex@swen.nu, 023-5325777, 06-21811135

# CHANGELOG:
# <DATE>	A.Swen	created.

# SETTINGS
date=$(date +%Y%m%d)
me=$(basename $0)
mydir=$(dirname $0)


# FUNCTIONS
die () {
  rc=$1
  shift
  echo "==========================">&2
  echo "====    FATAL  ERROR  ====" >&2
  echo "==========================">&2
  echo "" >&2
  echo $@ >&2
  exit $rc
}

usage () {
  echo "==========================" >&2
  echo "====       USAGE      ====" >&2
  echo "==========================" >&2
  echo "" >&2
  echo "Usage: ${me} <userfile>" >&2
  echo "" >&2
  echo "example: ${me} /tmp/userlist" >&2
  echo "" >&2
  exit 1
}

get_options () {
  [ $# -gt 0 ]||usage
  while getopts "s:d:D:u:g:" opt;do
    case ${opt} in
      u) export user=`echo ${OPTARG}` ;;
      *) usage;;
    esac
  done
}

# SCRIPT
[ ${UID} -gt 0 ] && die 0 only root may do that

# END