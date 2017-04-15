#!/bin/bash
set -e

for yov in $(find /var/vcap/store/shared/cc-droplets/ -type f | grep -v buildpack_cache |cut -c 1-77)
 do
   cd $yov
   ls -ltch | awk 'NR>3 {print $9}' > /tmp/idrms
   for dude in $(cat /tmp/idrms)
    do
    echo "Removing older version droplet with id: $dude"
    rm -rf $dude
   done
 done

