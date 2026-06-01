{
  description = "A simple wrapper NixOS flake";

 inputs = {
    # NixOS official package source
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    # Claude Desktop
    flake-utils.url = "github:numtide/flake-utils";
    claude-desktop.url = "github:k3d3/claude-desktop-linux-flake";
    claude-desktop.inputs.nixpkgs.follows = "nixpkgs";
    claude-desktop.inputs.flake-utils.follows = "flake-utils";

    # Weaver
    weaver.url = "path:/path/to/your/project";
    weaver.inputs.nixpkgs.follows = "nixpkgs";

    # Engram — cross-project knowledge store (ingest CLI + query API)
    engram.url = "path:/path/to/your/engram";
    engram.inputs.nixpkgs.follows = "nixpkgs-unstable";

    # sops-nix — secrets management
    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";
  };


  outputs = { self, nixpkgs, nixpkgs-unstable, claude-desktop, weaver, engram, sops-nix, ... }@inputs: {
    # NixOS configuration matching the system hostname
    nixosConfigurations.king = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./configuration.nix
        weaver.nixosModules.default
        sops-nix.nixosModules.sops
      ];
      # Pass inputs to modules so they can access common inputs
      specialArgs = { inherit inputs nixpkgs-unstable; };
    };
  };
}
