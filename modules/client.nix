{ pkgs, ... }: {

  nixpkgs.overlays = [
    (final: prev: {
      prismlauncher-custom = prev.prismlauncher.overrideAttrs (oldAttrs: rec {
        version = "9.4";
        src = prev.fetchFromGitHub {
          owner = "PrismLauncher";
          repo = "PrismLauncher";
          rev = version;
          fetchSubmodules = true;
          hash = "sha256-Ndt0op00byJL2Xk2oJIMEwu8uVv0PTL9mHDk8kH3r/c=";
        };
      });
    })
  ];

  # Install the customized client launcher to the user environment
  home.packages = [
    pkgs.prismlauncher-custom
  ];

}
