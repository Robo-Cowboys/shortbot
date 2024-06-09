{
  pkgs,
  lib,
  config,
  inputs,
  ...
}: let
  # Create our own wrapper for treefmt so we can use treefmt-nix
  treefmtWrapper = inputs.treefmt-nix.lib.mkWrapper pkgs {
    projectRootFile = "devenv.nix";
    programs = {
      alejandra.enable = true;
      just.enable = true;
      mdformat.enable = true;
      black.enable = true;
      isort.enable = true;
    };
  };
in {
  dotenv.enable = true;

  packages = [
    pkgs.scrot
    pkgs.tk
    pkgs.python311Packages.tkinter
    pkgs.just
    treefmtWrapper
  ];

  languages = {
    python = {
      enable = true;
      version = "3.11.3";
      poetry = {
        enable = true;
        activate.enable = true;
        install.enable = true;
      };
    };
  };

  #  scripts = {
  #    setup-devenv.exec = ''
  #      set -eo pipefail
  #      if [ ! -f .env ]
  #      then
  #        echo "Copying .env.example to .env"
  #        cp .env.example .env
  #      fi
  #      set -a; source .env; set +a
  #      echo "Installing composer packages"
  #      ${composer} install > /dev/null
  #      echo "Installing npm packages"
  #      ${npm} ci > /dev/null
  #
  #      echo "Generating Keys"
  #      ${php} artisan key:generate > /dev/null
  #
  #      echo "Migrating Database"
  #      ${php} artisan migrate:fresh --seed --force > /dev/null
  #    '';
  #  };

  enterShell = ''
    just --list
  '';

  pre-commit.hooks = {
    detect-private-keys.enable = true;
    treefmt = {
      enable = true;
      package = treefmtWrapper;
    };
  };
}
