{ pkgs ? import <nixpkgs> { config = { allowUnfree = true; }; } }:
pkgs.mkShell {
  buildInputs = with pkgs; [
    gcc                # GNU C Compiler
    clang              # Alternative C compiler
    readline           # Library for command line editing
    glibc              # GNU C Library
    lldb               # Debugger (alternative to gdb)
    vscode             # Visual Studio Code (unfree)
    gdb                # GNU Debugger (optional but useful)
    fish               # Fish shell for interactive use
    git                # Version control
    gh                 # GitHub CLI
    musl               # Alternative C library
    cmake              # Build system generator
    pkg-config         # Helps configure libraries and compiler flags
    autoconf           # Tool for generating configuration scripts
    automake           # Tool for generating Makefile.in files
    libtool            # Generic library support script
    libiconv           # Character encoding conversion library
    zlib               # Compression library
    openssl            # SSL/TLS toolkit
    libpng             # PNG image library
binutils
editline
libedit
linenoise-ng
libjpeg            # JPEG image library
  ];
  shellHook = ''
    echo "Welcome to your C development shell!"
    echo "This environment includes tools for native development and cross-compiling to Windows."
    echo "Additional packages can be added to ~/Documents/projs/c/shell.nix"
    exec ${pkgs.fish}/bin/fish
  '';
}

