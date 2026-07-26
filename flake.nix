# flake.nix
{
  description = "Unified Minecraft Server and Client Configuration Flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nix-minecraft.url = "github:Infinidoge/nix-minecraft";
    #devenv.url = "github:cachix/devenv";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = {
    self, nixpkgs, nix-minecraft,
    #devenv,
    home-manager,
    ...
  }@inputs:
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
      #devShells.${system}.default = devenv.lib.mkShell {
      #  inherit pkgs inputs;
      #  modules = [
      #    {
      #      #devenv.root = "${./.}";
      #      devenv.root = "";
      #    }
      #    ./devenv.nix
      #  ];
      #};
      devShells.${system}.default = pkgs.mkShell {
        packages = [
          pkgs.packwiz
          pkgs.git
        ];

        shellHook = ''
          echo "---------------------------------------------------------"
          echo "⚒️ Minecraft Server/Client Development Environment Active"
          echo "---------------------------------------------------------"
          #echo "packwiz tool version: $(packwiz --version)"
        '';
      };

      #-----------------------------------------------
      # Flake Checks for Automated Testing
      #-----------------------------------------------
      #
      # To run all checks in parallel:
      #   nix flake check
      #
      # To run check on devShells build
      #   nix build .#checks.x86_64-linux.devShell-build
      #
      # To run test on nixosModules.minecraft-server wheater it evaluates porperly without syntax or option type errors.
      #   nix build .#checks.x86_64-linux.server-module-eval --no-link
      # Note: The --no-link flag tells Nix to evaluate and build the check result without creating a ./result symlink in your working directory.
      #
      # To run test on homeModules.minecraft-client
      #   nix build .#checks.x86_64-linux.client-module-eval --no-link
      # Note: The --no-link flag tells Nix to evaluate and build the check result without creating a ./result symlink in your working directory.
      #
      # To run test vm
      #   nix build .#checks.x86_64-linux.server-vm-test
      #
      checks.${system} = {

        # Test that the default devShell builds and contains packwiz
        devShell-build = self.devShells.${system}.default;

        /*

        # Test evaluation of the NixOS module configuration
        server-module-eval = (nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs;  };
          modules = [
            self.nixosModules.minecraft-server
            {
              boot.loader.grub.device = "nodev";
              fileSystems."/" = {
                device = "/dev/null";
                fsType = "ext4";
              };
            }
          ];
        }).config.system.build.toplevel;

        # Test evaluation of the Home Manager Client Module
        client-module-eval = (home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          extraSpecialArgs = { inherit inputs;  };
          modules = [
            self.homeModules.minecraft-client
            {
              # Minimal required boilerplate for Home Manager evaluation
              home.username = "testuser";
              home.homeDirectory = "/home/testuser";
              home.stateVersion = "24.05";
            }
          ];
        }).activationPackage;

        # Full VM Integration Test (boots a VM and checks if service runs)
        server-vm-test = nixpkgs.lib.testers.runNixOSTest {
          name = "minecraft-server-startup-test";
          node = {
            specialArgs = { inherit inputs; };
          };
          nodes.server = { pkgs, ... }: {
            imports = [ self.nixosModules.minecraft-server ];

            # Basic dummy configuration to allow the test VM to boot
            services.minecraft-servers = {
              enable = true;
              eula = true;
            };
          };

          testScript = ''
            server.wait_for_unit("multi-user.target")
            server.succeed("systemctl is-enabled minecraft-servers.target || true")
          '';
        };

        */

      };

    };
}
