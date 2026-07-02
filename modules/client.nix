{ pkgs, lib, ... }: 
let
  # 1. First, compile the raw 9.4 source from your exact commit
  prismlauncher-unwrapped-pinned = pkgs.prismlauncher-unwrapped.overrideAttrs (oldAttrs: {
    version = "9.4-commit-385bb50";

    src = pkgs.fetchFromGitHub {
      owner = "PrismLauncher";
      repo = "PrismLauncher";
      rev = "385bb500b9195765a6e6fb5c81855b24eb48bf91";
      fetchSubmodules = true;
      # Use the fake hash string to explicitly calculate the source signature
      #hash = lib.fakeHash;
      hash = "sha256-Ndt0op00byJL2Xk2oJIMEwu8uVv0PTL9mHDk8kH3r/c=";
    };

    # Append the missing Qt compatibility package to the build environment
    buildInputs = (oldAttrs.buildInputs or [ ]) ++ [
      pkgs.qt6.qt5compat
    ];

  });

  # 2. Inject our custom built binary right into the official runtime wrapper
  prismlauncher-pinned = pkgs.prismlauncher.override {
    prismlauncher-unwrapped = prismlauncher-unwrapped-pinned;
  };
in
{
  # Prevent documentation cache indexing from blocking your build steps
  programs.man.generateCaches = false;

  # Deploy the newly wrapped pinned package to your profile environment
  home.packages = lib.mkForce [
    prismlauncher-pinned
  ];
}
