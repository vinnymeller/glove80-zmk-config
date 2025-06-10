{
  description = "Glove80 ZMK Configuration Builder";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    zmk = {
      url = "github:moergo-sc/zmk";
      flake = false;
    };
    zmk-helpers = {
      url = "github:urob/zmk-helpers";
      flake = false;
    };
  };

  outputs = {
    self,
    flake-utils,
    nixpkgs,
    zmk,
    zmk-helpers,
    ...
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs {inherit system;};
      firmware = import zmk { inherit pkgs; };

      glove80_left = firmware.zmk.override {
        board = "glove80_lh";
        keymap = "${self}/config/glove80.keymap";
        kconfig = "${self}/config/glove80.conf";
        extraModules = [ zmk-helpers ];
      };
      glove80_right = firmware.zmk.override {
        board = "glove80_rh";
        keymap = "${self}/config/glove80.keymap";
        kconfig = "${self}/config/glove80.conf";
        extraModules = [ zmk-helpers ];
      };
    in {
      defaultPackage = firmware.combine_uf2 glove80_left glove80_right;
    });
}
