#!/usr/bin/env bash
nix run github:nix-community/nixos-generators -- --flake .#live -f install-iso -o result |& nom
