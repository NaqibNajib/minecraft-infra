{
  description = "Unified Minecraft Server and Client Configuration Flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nix-minecraft.url = "github:Infinidoge/nix-minecraft";
    devenv.url = "github:cachix/devenv";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, nix-minecraft, devenv, home-manager, ... }@inputs:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in {


      #-----------------------------------------------
      # NixOS Module for your Server Host
      #-----------------------------------------------
      nixosModules.minecraft-server = {
        imports = [
          nix-minecraft.nixosModules.minecraft-servers
          ./modules/server.nix
        ];
      };


      #-----------------------------------------------
      # Home Manager Module for your Client Host
      #-----------------------------------------------
      homeModules.minecraft-client = ./modules/client.nix;


      #-----------------------------------------------
      # Development Shell for Modpack/Server administration tools
      #-----------------------------------------------
      devShells.${system}.default = devenv.lib.mkShell {
        inherit pkgs inputs;
        modules = [ ./devenv.nix ];
      };


    };
}
