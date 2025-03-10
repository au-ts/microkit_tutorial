#
# Copyright 2025, UNSW
# SPDX-License-Identifier: BSD-2-Clause
#
{
  description = "A flake for the seL4 Microkit tutorial";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { nixpkgs, ... }:
    let
      microkit-version = "2.0.0";
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
                url = "https://github.com/seL4/microkit/releases/download/2.0.0/microkit-sdk-${microkit-version}-${microkit-platform}.tar.gz";
                hash = {
                  aarch64-darwin = "sha256-kvJgQbYTOkRYSizryxmRTwZ/Pb9apvxcV5IMtZaHf2w=";
                  x86_64-darwin = "sha256-SNCkJBnsEOl5VoNSZj0XTlr/yhHSNk6DiErhLNNPb3Q=";
                  x86_64-linux = "sha256-uuFHArShhts1sspWz3fcrGQHjRigtlRO9pbxGQL/GHk=";
                  aarch64-linux = "sha256-NOmRocveleD4VT+0MAizqkUk0O7P8LqDLM+NZziHkGI=";
                }.${system} or (throw "Unsupported system: ${system}");
              };

              nativeBuildInputs = with pkgs; [
                pkgsCross.aarch64-embedded.stdenv.cc.bintools
                pkgsCross.aarch64-embedded.stdenv.cc
                qemu
                gnumake
              ];
              # To avoid Nix adding compiler flags that are not available on a freestanding
              # environment.
              hardeningDisable = [ "all" ];
            };
        });
    };
}
