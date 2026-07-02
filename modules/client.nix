{ pkgs, ... }: {

  nixpkgs.overlays = [
    (final: prev: {
      prismlauncher-custom = prev.prismlauncher.overrideAttrs (oldAttrs: rec {

	# Metadata version name for my local package
        #version = "9.4";
        version = "9.x-branch;

        src = prev.fetchFromGitHub {
          owner = "PrismLauncher";
          repo = "PrismLauncher";

          # Target the exact branch string
          #rev = version;
          rev = "release-9.x";

          fetchSubmodules = true;
          #hash = "sha256-Ndt0op00byJL2Xk2oJIMEwu8uVv0PTL9mHDk8kH3r/c=";
          #hash = "";
	  # Use a zero/fake hash. Nix will fail on rebuild, 
          # inspect the download, and print out the correct hash for you to copy.
          hash = lib.fakeHash;
        };

      });
    })
  ];

  # Install the customized client launcher to the user environment
  home.packages = [
    pkgs.prismlauncher-custom
  ];

}
