{ config, pkgs, ... }:

{
  home.username = "joy";
  home.homeDirectory = "/home/joy";

  home.stateVersion = "24.05";

  # Install necessary packages
  home.packages = with pkgs; [
    ripgrep fd nodejs_23 clang
    rustc rustup lldb
    fzf # Fuzzy Finder
  ];

  # Neovim configuration for Rust development with better UI
  programs.neovim = {
    enable = true;
    defaultEditor = true;

    plugins = with pkgs.vimPlugins; [
      # Theme & UI
      everforest
      lualine-nvim
      nvim-web-devicons
      nvim-tree-lua

      # Navigation
      telescope-nvim
      plenary-nvim

      # Syntax Highlighting & LSP
      nvim-treesitter
      nvim-treesitter-context
      nvim-lspconfig
      rust-tools-nvim
      nvim-dap
      gitsigns-nvim

      # Completion & Snippets
      nvim-cmp
      cmp-nvim-lsp
      cmp-buffer
      cmp-path
      cmp-cmdline
      luasnip
      cmp_luasnip
    ];

    extraConfig = ''
      " General settings
      set number
      set relativenumber
      set termguicolors
      set background=dark
      set mouse=a
      set clipboard=unnamedplus
      set splitbelow
      set splitright

      " Theme
      let g:everforest_background = 'hard'
      let g:everforest_enable_italic = 1
      colorscheme everforest

      " File Explorer (NvimTree)
      lua << EOF
      require("nvim-tree").setup()
      vim.keymap.set("n", "<C-o>", ":NvimTreeToggle<CR>", { noremap = true, silent = true })
      EOF

      " Statusline (Lualine)
      lua << EOF
      require("lualine").setup({
        options = {
          theme = "everforest",
          icons_enabled = true
        }
      })
      EOF

      " Telescope keybindings
      lua << EOF
      local telescope = require("telescope.builtin")
      vim.keymap.set("n", "<leader>ff", telescope.find_files, { noremap = true, silent = true })
      vim.keymap.set("n", "<leader>fg", telescope.live_grep, { noremap = true, silent = true })
      EOF

      " Treesitter Parser Directory Fix for NixOS
      lua << EOF
      local parser_install_dir = vim.fn.stdpath("data") .. "/nvim-treesitter-parsers"
      vim.fn.mkdir(parser_install_dir, "p") -- Ensure directory exists
      require("nvim-treesitter.install").prefer_git = true
      require("nvim-treesitter.install").compilers = { "clang", "gcc" }
      require("nvim-treesitter.configs").setup {
        ensure_installed = { "rust", "lua", "python", "c" },
        highlight = { enable = true },
        indent = { enable = true },
        parser_install_dir = parser_install_dir
      }
      vim.opt.runtimepath:append(parser_install_dir)
      EOF

      " Rust LSP & Auto-completion
      lua << EOF
      local lspconfig = require("lspconfig")
      local rust_tools = require("rust-tools")
      local cmp = require("cmp")
      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      -- Attach Rust Analyzer properly
      rust_tools.setup({
        server = {
          capabilities = capabilities,
          on_attach = function(client, bufnr)
            local opts = { noremap=true, silent=true, buffer=bufnr }
            vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)  -- Go to Definition
            vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)  -- Show Hover Info
            vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts) -- Rename symbol
            vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts) -- Code actions
            vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, opts) -- Show diagnostics
          end,
          settings = {
            ["rust-analyzer"] = {
              cargo = { allFeatures = true },
              checkOnSave = { command = "clippy" },
              diagnostics = { enable = true }
            }
          }
        }
      })

      -- Auto-completion setup
      cmp.setup({
        mapping = {
          ["<Tab>"] = cmp.mapping.select_next_item(),  -- ✅ Tab cycles forward
          ["<S-Tab>"] = cmp.mapping.select_prev_item(), -- ✅ Shift+Tab cycles backward
          ["<CR>"] = cmp.mapping.confirm({ select = true }), -- ✅ Enter selects completion
        },
        sources = {
          { name = "nvim_lsp" },
          { name = "luasnip" },
          { name = "buffer" },
          { name = "path" }
        }
      })
      EOF

      " Keybindings
      nnoremap <C-a> ggVG
      vnoremap <C-S-c> "+y  " ✅ Fixed Copy
      inoremap <C-S-v> <C-r>+  " ✅ Fixed Paste
    '';
  };

  # Set up environment variables for Rust
  home.sessionVariables = {
    CARGO_HOME = "$HOME/.cargo";
    RUSTUP_HOME = "$HOME/.rustup";
  };

  # Enable Home Manager itself
  programs.home-manager.enable = true;
}

