{
  description = "A simple wrapper NixOS flake";

  inputs = {
    # NixOS official package source
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    
    # Claude Desktop for Linux
    claude-desktop = {
      url = "github:k3d3/claude-desktop-linux-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, claude-desktop, ... }@inputs: {
    # NixOS configuration matching the system hostname
    nixosConfigurations.king = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        # Import the previous configuration.nix we used,
        # so the old configuration file still takes effect
        ./configuration.nix
        
        # Claude Desktop module
        ./modules/claude-desktop.nix
      ];
      # Pass inputs to modules so they can access claude-desktop
      specialArgs = { inherit inputs; };
    };
  };
}