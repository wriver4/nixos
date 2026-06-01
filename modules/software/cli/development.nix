{ pkgs, inputs, ... }:

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
      #diagramming
      d2 # D2 is a modern diagram scripting language that turns text into diagrams.
      #
      #databases
      sqlite # SQLite CLI and library
      #
      #git
      gh # GitHub CLI (gh) is the official command line tool for GitHub.
      mkcert # Generate locally-trusted development certificates
      inputs.engram.packages.${pkgs.stdenv.hostPlatform.system}.engram-api
    ];
    # required by nixd
    #nix.nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];
  };
}
