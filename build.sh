#!/usr/bin/env sh

nix build '.?submodules=1' -o combined
