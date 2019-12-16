#!/bin/bash
set -e

> /tmp/idrms

# check for more than 2 droplet versions
for folder in $(find /var/vcap/store/shared/cc-droplets/ -type f | grep -v buildpack_cache |cut -c 1-77 | sort -u)
do
   ls -ltch $folder | awk 'NR>3 {print $9}' >> /tmp/idrms
done

# list the droplets
for droplet in $(cat /tmp/idrms)
do
  echo "older version droplet found with id: $droplet"
done
