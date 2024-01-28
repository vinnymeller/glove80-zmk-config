{
  description = "Glove80 ZMK Configuration Builder";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    self,
    flake-utils,
    nixpkgs,
    ...
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs {inherit system;};
      # config = ./config;
      config = ./.;
      firmware = import ./zmk {inherit pkgs;};

      glove80_left = firmware.zmk.override {
        board = "glove80_lh";
        keymap = "${config}/config/glove80.keymap";
        kconfig = "${config}/config/glove80.conf";
      };
      glove80_right = firmware.zmk.override {
        board = "glove80_rh";
        keymap = "${config}/config/glove80.keymap";
        kconfig = "${config}/config/glove80.conf";
      };
    in {
      defaultPackage = firmware.combine_uf2 glove80_left glove80_right;
    });
}
