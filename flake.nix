#
# Copyright 2025, UNSW
# SPDX-License-Identifier: BSD-2-Clause
#
{
  description = "A flake for the seL4 Microkit tutorial";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
  };

  outputs = { nixpkgs, ... }:
    let
      microkit-version = "2.1.0";
      microkit-platforms = {
        aarch64-darwin = "macos-aarch64";
        x86_64-darwin = "macos-x86-64";
        x86_64-linux = "linux-x86-64";
        aarch64-linux = "linux-aarch64";
      };

      forAllSystems = with nixpkgs.lib; genAttrs (builtins.attrNames microkit-platforms);
    in
    {
      devShells = forAllSystems
        (system: {
          default =
            let
              pkgs = import nixpkgs {
                inherit system;
              };
            in
            # mkShellNoCC, because we do not want the cc from stdenv to leak into this shell
            pkgs.mkShellNoCC rec {
              name = "microkit_tutorial";

              microkit-platform = microkit-platforms.${system} or (throw "Unsupported system: ${system}");

              env.MICROKIT_SDK = pkgs.fetchzip {
                url = "https://github.com/seL4/microkit/releases/download/${microkit-version}/microkit-sdk-${microkit-version}-${microkit-platform}.tar.gz";
                hash =
                  {
                    aarch64-darwin = "sha256-SzwdHm0O++5MCZ4+a8o12JOSWJLHl4QK/TU3jyLFNo8=";
                    x86_64-darwin = "sha256-l5XKyNMhR1ofHeumvJqdl+yNSKX0/beevBmuoCxDRnU=";
                    x86_64-linux = "sha256-6I3usfpwEe50xxo4u1Bv206CPJJIhZGtwak8doVk+GE=";
                    aarch64-linux = "sha256-hw3C2lffXTeqpVL/L9j6hG4HnBqZHsGiZwK6UQVlJ6s=";
                  }
                  .${system} or (throw "Unsupported system: ${system}");
              };

              nativeBuildInputs = with pkgs; [
                pkgsCross.aarch64-embedded.stdenv.cc.bintools
                pkgsCross.aarch64-embedded.stdenv.cc
                qemu
                gnumake
                curl
              ];
              # To avoid Nix adding compiler flags that are not available on a freestanding
              # environment.
              hardeningDisable = [ "all" ];
            };
        });
    };
}
