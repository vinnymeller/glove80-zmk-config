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
    git-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      git-hooks,
      flake-utils,
      nixpkgs,
      zmk,
      zmk-helpers,
      ...
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs { inherit system; };
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
      in
      {
        checks = {
          pre-commit-check = git-hooks.lib.${system}.run {
            src = ./.;
            hooks =
              let
                keymap = "${pkgs.keymap-drawer}/bin/keymap";
                checkKeymap = pkgs.writeShellScriptBin "update-keymap-svg" ''
                  mv keymap.svg keymap.svg.bak || true
                  ${keymap} parse -z config/glove80.keymap | ${keymap} draw - > keymap.svg
                  cmp_result=$(cmp keymap.svg keymap.svg.bak && echo 0 || echo 1)
                  rm keymap.svg.bak || true
                  if [ "$cmp_result" -ne 0 ]; then
                    echo "Keymap SVG has changed, please update it."
                    exit 1
                  fi
                '';
              in
              {
                update-svg = {
                  enable = true;
                  name = "Update keymap SVG";
                  entry = "${checkKeymap}/bin/update-keymap-svg";
                  pass_filenames = false;
                  stages = [ "pre-commit" ];
                };

              };
          };
        };
        devShells = {
          default = pkgs.mkShell {
            inherit (self.checks.${system}.pre-commit-check) shellHook;
            buildInputs = self.checks.${system}.pre-commit-check.enabledPackages;
          };
        };
        defaultPackage = firmware.combine_uf2 glove80_left glove80_right;
      }
    );
}
