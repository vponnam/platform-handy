#!/bin/bash
set -e

> /tmp/idrms

# check for more than 2 droplet versions
for folder in $(find /var/vcap/store/shared/cc-droplets/ -type f | grep -v buildpack_cache |cut -c 1-77 | sort -u)
do
   ls -ltch $folder | awk 'NR>3 {print $9}' >> /tmp/idrms
done

# older droplet versions
printf "\n*************\nTotal droplets with more than 2 versions are: $(cat /tmp/idrms | wc -l)\n"
printf "File created with name: '/tmp/idrms' has all the droplet IDs\n*************\n"
