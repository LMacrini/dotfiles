#!/usr/bin/env bash

set -e
if ! command -v nixos-rebuild &> /dev/null; then
  echo "error: nixos-rebuild not found" >&2
  exit 1
fi

variant=${1:-iso-installer}
nixos-rebuild build-image --flake .#live --image-variant $variant |& nom
