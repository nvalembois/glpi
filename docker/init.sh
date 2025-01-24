#!/bin/sh
set -e
ls -la /data
for d in config files log marketplace dumps
do
  if [[ ! -d /data/$d ]]; then
    install -d -m 0750 /data/$d
  fi
done
