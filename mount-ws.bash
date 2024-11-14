#!/bin/bash

sudo mkdir -p /mnt/w1
sudo mount -t drvfs A: /mnt/w1

sudo mkdir -p /mnt/w2
sudo mount -t drvfs B: /mnt/w2

for dirve in {A...Z}; do
  if [[ -e /mnt/$drive ]]; then
    echo "La unidad $drive ya está montada"
  elif [[ -e /mnt/c/Users/cesar.hernandezb ]]; then
    if mount | grep -q "/mnt/$drive"; then
      echo "La unidad $drive ya está montada."
    else
      echo "Montando la unidad $drive..."
      sudo mount -t drvfs "$drive:" "/mnt/$drive"
    fi
  fi
done
