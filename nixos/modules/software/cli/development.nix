{ config, pkgs, inputs, ... }:

{
  config = {
    environment.systemPackages = with pkgs; [
      # programming languages
      python3 # A high-level programming language
      gcc-unwrapped # The GNU Compiler Collection - C and C++ frontends
      gnumake # GNU version of 'make' utility
      #
      #formatters
      nixpkgs-fmt # current official style use nixpkgs-fmt --check file.nix
      nixfmt-rfc-style # new official style use nixfmt --check file.nix
      #nit needed if using vscode use vscode plugin nix-ide
      nixd # nix language server
      #
      #databases
      sqlite # SQLite CLI and library
      #
      #git
      gh # GitHub CLI (gh) is the official command line tool for GitHub.
    ];
    # required by nixd
    #nix.nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];
  };
}
