#!/usr/bin/env bash
variant=${$1:=iso}
nixos-rebuild build-image --flake .#live --image-variant $variant
