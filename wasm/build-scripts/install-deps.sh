#!/bin/bash

cmds=()

# Detect what dependencies are missing.
for cmd in autoconf automake libtool pkg-config ragel
do
  if ! command -v $cmd &> /dev/null
  then
    cmds+=("$cmd")
  fi
done

# Install missing dependencies
if [ ${#cmds[@]} -ne 0 ];
then
  if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    # Fix Debian Buster repositories (end-of-life) by using archive repositories
    if grep -q "buster" /etc/apt/sources.list 2>/dev/null; then
      echo "Fixing Debian Buster repositories..."
      sed -i 's|http://deb.debian.org/debian|http://archive.debian.org/debian|g' /etc/apt/sources.list
      sed -i 's|http://security.debian.org/debian-security|http://archive.debian.org/debian-security|g' /etc/apt/sources.list
      sed -i '/buster-updates/d' /etc/apt/sources.list
      echo "deb http://archive.debian.org/debian buster main" > /etc/apt/sources.list
      echo "deb http://archive.debian.org/debian-security buster/updates main" >> /etc/apt/sources.list
      # Disable security updates check for archived repositories
      echo 'Acquire::Check-Valid-Until "false";' > /etc/apt/apt.conf.d/99no-check-valid-until
    fi
    
    apt-get update
    apt-get install -y ${cmds[@]}
  else
    brew install ${cmds[@]}
  fi
fi
