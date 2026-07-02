{ pkgs, ... }: {

  # Packages that will be available in your terminal inside this folder
  packages = [
    pkgs.packwiz
    pkgs.git
  ];

  enterShell = ''
    echo "⚒️ Minecraft Server/Client Development Environment Active"
    echo "packwiz tool version: $(packwiz --version)"
  '';

}
