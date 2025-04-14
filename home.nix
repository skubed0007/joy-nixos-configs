{
  config,
  pkgs,
  ...
}: {
  # Inject the rust-overlay into the nixpkgs passed to Home Manager.
  nixpkgs.overlays = [
    (import (builtins.fetchTarball {
      url = "https://github.com/oxalica/rust-overlay/archive/master.tar.gz";
      sha256 = "1zm1c7p7cg3nzbz3gg3xmv96sg0mdxg6ml0snnhrpnwqphhjlmw8";
    }))
  ];
  nixpkgs.config.allowUnfree = true;
  home.username = "joy";
  home.homeDirectory = "/home/joy";
  home.stateVersion = "24.05";

  home.packages = with pkgs; [
    inkscape
zip
unzip
clang-tools
linuxKernel.packages.linux_6_6.perf
    haruna
spotify
    mpv
    flameshot
    gruvbox-gtk-theme
    lightdm-enso-os-greeter
    whitesur-gtk-theme
    gedit
    neovim
    yt-dlp
    steam-run
    krita
    nodejs
    apple-cursor
    fluent-gtk-theme
    whitesur-icon-theme
    # Install your Rust toolchain from the overlay.
    (rust-bin.stable.latest.default.override {
      # This adds the rust-src component
      extensions = ["rust-src"];
    })
    vscode
    # Other development tools.
    zig
    clang
    lldb
    gdb
    git
    code-cursor
    gh
    pkg-config
    cmake
    openssl.dev
  ];

  programs.home-manager.enable = true;
}
