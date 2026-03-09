#!/usr/bin/env bash
nix run github:nix-community/nur#repos.rycee.mozilla-addons-to-nix \
        modules/nixosModules/features/browser/addons.json \
        modules/nixosModules/features/browser/_generated-addons.nix
