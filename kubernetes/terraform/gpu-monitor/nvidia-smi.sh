#!/bin/bash

readonly OK=0
readonly NONOK=1

/usr/bin/nvidia-smi
exit_code=$?

if [ $exit_code -eq 0 ]; then
  exit $OK
else
  exit $NONOK
fi