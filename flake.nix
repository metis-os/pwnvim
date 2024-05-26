{
  description = "PwnVim:- Neovim, the less is more 👾";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
      in
      {
        devShells.default = pkgs.mkShell {

          packages = [ pkgs.neovim ];

          shellHook = ''
            ln -s $(pwd) ~/.config/pwnvim
            export NVIM_APPNAME=pwnvim
          '';

        };
      });
}
