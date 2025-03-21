{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    systems.url = "github:nix-systems/default";
  };

  outputs = { nixpkgs, systems, ... }:
    let
      forEachSystem =
        function: nixpkgs.lib.genAttrs (import systems) (system: function (import nixpkgs {
          system = system;
          config.allowUnfree = true; # Allow unfree packages like VSCode
        }));
    in
    {
      devShells = forEachSystem (pkgs: {
        glibc = pkgs.mkShell {
          env = {
            RUST_SRC_PATH = "${pkgs.rustPlatform.rustLibSrc}";
          };
          nativeBuildInputs = with pkgs; [
            cargo
            rustc
            rust-analyzer
            rustfmt
            clippy
            rustup
            glibc
            neovim
            ripgrep   # For Telescope
            fd        # For Telescope
            nodejs    # Required for LSP and some plugins
          ];
        };

        musl = pkgs.mkShell {
          env = {
            RUST_SRC_PATH = "${pkgs.rustPlatform.rustLibSrc}";
          };
          nativeBuildInputs = with pkgs; [
            cargo
            rustc
            rust-analyzer
            rustfmt
            clippy
            rustup
            musl
            vscode
            neovim
            ripgrep
            fd
            nodejs
          ];
        };

        mingw = pkgs.mkShell {
          env = {
            RUST_SRC_PATH = "${pkgs.rustPlatform.rustLibSrc}";
          };
          nativeBuildInputs = with pkgs; [
            cargo
            rustc
            rust-analyzer
            rustfmt
            clippy
            rustup
            pkgs.pkgsCross.mingw32.buildPackages.gcc
            pkgs.pkgsCross.mingwW64.buildPackages.gcc
            pkgs.wine # Optional: Run Windows executables
            neovim
            ripgrep
            fd
            nodejs
          ];
        };
      });

      # ✅ Install Neovim & Rust tools system-wide
      packages = forEachSystem (pkgs: {
        default = pkgs.neovim; # Install Neovim system-wide
        rust-analyzer = pkgs.rust-analyzer;
        rust = pkgs.rustc;
        cargo = pkgs.cargo;
        rustfmt = pkgs.rustfmt;
        clippy = pkgs.clippy;
      });
    };
}

