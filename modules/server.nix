{ pkgs, inputs, ... }: {

  nixpkgs.overlays = [
    inputs.nix-minecraft.overlay
  ];

  services.minecraft-servers = {
    enable = true;
    eula = true;

    #dataDir = "/var/lib/minecraft";
    dataDir = "/srv/minecraft";

    servers = {
      CreateAero = {

        enable = true;
        package = pkgs.neoforgeServers.neoforge-1_21_1;
        jvmOpts = "-Xmx8G -Xms8G -Dnet.neoforged.fml.VersionChecker.status=REMOVE";

        serverProperties = {
          online-mode = false;
          gamemode = "survival";
        };

        # Example packwiz modpack integration
        # modpack = pkgs.fetchPackwizModpack {
        #   url = "https://github.com/YourUsername/Modpack/raw/main/pack.toml";
        #   packHash = "sha256-...........................................=";
        # };

      }; # End of services.minecraft-servers.servers.CreateAero = { ... };
    }; # End of services.minecraft-servers.servers = { ... };

  }; # End of services.minecraft-servers = { ... };

} # End of {}:{ ... }
