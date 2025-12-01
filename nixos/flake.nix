{
  description = "A simple wrapper NixOS flake";

  inputs = {
    # NixOS official package source
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
  };

  outputs = { self, nixpkgs, ... }@inputs: {
    # NixOS configuration matching the system hostname
    nixosConfigurations.king = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        # Import the previous configuration.nix we used,
        # so the old configuration file still takes effect
        ./configuration.nix
      ];
      # Pass inputs to modules so they can access common inputs
      specialArgs = { inherit inputs; };
    };
  };
}
