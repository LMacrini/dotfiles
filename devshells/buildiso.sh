#!/usr/bin/env bash
variant=${1:-iso-installer}
nixos-rebuild build-image --flake .#live --image-variant $variant |& nom
