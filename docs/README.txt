===============================================================================
                       MINECRAFT INFRASTRUCTURE FLAKE
===============================================================================

INTRODUCTION
------------

This repository manages a unified, declarative configuration for both a
Minecraft server instance and a customized Prism Launcher client setup using
the Nix ecosystem (NixOS, Flakes, Home Manager, and Devenv).

By keeping this repository separate from your main system configuration, you
gain modularity, easier version tracking for game mods/launchers, and the
ability to share configurations across different hosts seamlessly.

The project exports two primary modules:

1. A NixOS Module for deploying a managed Minecraft server.
2. A Home Manager Module for installing a custom-built Prism Launcher client.


PREREQUISITES
-------------

Before you begin, ensure your target hosts have the following enabled:

* Nix with Flakes enabled
* git
* direnv (highly recommended for local development)


GETTING STARTED / INSTALLATION
------------------------------

1. Clone the Repository

   To start hacking or deploying, clone this repository onto your machine:

   $ git clone https://github.com/your-username/minecraft-infra.git ~/src/minecraft-infra
   $ cd ~/src/minecraft-infra

2. Initialize the Development Shell

   If you have direnv installed, run:

   $ direnv allow
 
   Otherwise, manually drop into the shell using:

   $ nix develop

   This automatically loads all required tooling (like 'packwiz' and 'git')
   without installing them globally on your system.


HOW TO USE AND INTEGRATE IN YOUR CONFIGURATIONS
-----------------------------------------------

This project is built to be consumed as a Flake input inside your main system
or home configuration repositories.

A. Integrating the Server (NixOS)

   In your main NixOS system flake.nix, add this repository as an input:

   inputs.mc-project.url = "github:your-username/minecraft-infra";

   Then, add the module to your nixosSystem modules list:

   outputs = { self, nixpkgs, mc-project, ... }: {
     nixosConfigurations.your-server-hostname = nixpkgs.lib.nixosSystem {
       modules = [
         ./hardware-configuration.nix
         mc-project.nixosModules.minecraft-server
       ];
     };
   };

B. Integrating the Client (Home Manager)

   Similarly, add the input to your desktop/user flake and pass it to your
   Home Manager configuration profile:

   outputs = { self, nixpkgs, home-manager, mc-project, ... }: {
     homeConfigurations."youruser" = home-manager.lib.homeManagerConfiguration {
       pkgs = nixpkgs.legacyPackages.x86_64-linux;
       modules = [
         ./home.nix
         mc-project.homeModules.minecraft-client
       ];
     };
   };


DAY-TO-DAY WORKFLOW & LOCAL TESTING
-----------------------------------

When you are modifying server configs, adding mods, or updating the client
launcher layout, use the following workflows:

1. Local Sandbox Testing (Without Pushing to GitHub)

   To test modifications locally on your machine before committing them publicly,
   instruct your main system rebuild command to temporarily override the
   tracked input with your local directory:

   $ cd ~/src/nixos-config
   $ nixos-rebuild switch --flake .#yourHost --override-input mc-project path:/home/youruser/src/minecraft-infra

   or

   $ cd ~/src/nixos-config
   $ nh os test . -- --override-input mc-project path:/home/pouruser/src/minecraft-infra

   CRITICAL SAFETY NOTE: Nix flakes will completely ignore files that are not
   tracked by Git. If you create a new file or script within this repository,
   you MUST run 'git add <file>' or Nix will act as if it does not exist.

2. Committing and Pushing Changes

   Once you verify that your changes evaluate cleanly:

   $ cd ~/src/minecraft-infra
   $ git add .
   $ git commit -m "feat: upgrade server performance variables"
   $ git push origin main

3. Syncing the Production Hosts

   To deploy the newly pushed GitHub changes to your active server or client
   machines, navigate to your respective system configuration directory and
   update the lockfile tracking references:

   $ cd ~/src/nixos-config
   $ nix flake update mc-project
   $ nixos-rebuild switch --flake .


CONTRIBUTING & REQUESTING MERGES
--------------------------------

If you are working in a team environment or using a branch-based workflow:

1. Create a descriptive feature branch:

   $ git checkout -b feature/optimize-jvm-flags

2. Make your alterations, stage them, and push the branch up to your personal fork:

   $ git push origin feature/optimize-jvm-flags

3. Open your browser, navigate to the public GitHub repository page, and click
   "Compare & pull request" to submit your merge request for evaluation.
===============================================================================
