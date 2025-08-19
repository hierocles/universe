{
  lib,
  config,
  pkgs,
  namespace,
  ...
}: let
  inherit (lib) mkEnableOption mkIf;

  cfg = config.${namespace}.cli-apps.neovim;
in {
  options.${namespace}.cli-apps.neovim = {
    enable = mkEnableOption "Neovim";
  };

  config = mkIf cfg.enable {
    programs.neovim = {
      enable = true;
      defaultEditor = true;
      viAlias = true;
      vimAlias = true;
      withNodeJs = true;
      withPython3 = true;
      withRuby = true;
    };

    # Additional packages
    home.packages = with pkgs; [
      # LSP servers
      nil # Nix LSP
      rust-analyzer
      typescript-language-server
      lua-language-server
      bash-language-server

      # Formatters
      alejandra # Nix formatter
      rustfmt
      prettier
      stylua
      shfmt

      # Linters
      statix # Nix linter
      clippy
      eslint_d
      luacheck
      shellcheck

      # Tree-sitter
      tree-sitter

      # Additional tools
      ripgrep
      fd
      fzf
      bat
      delta
    ];

    # Session variables
    home.sessionVariables = {
      PAGER = "less";
      MANPAGER = "less";
      NPM_CONFIG_PREFIX = "$HOME/.npm-global";
      EDITOR = "nvim";
      VISUAL = "nvim";
    };

    # Shell aliases
    programs.zsh.shellAliases = {
      vim = "nvim";
      vimdiff = "nvim -d";
      vi = "nvim";
    };

    # Neovim configuration
    xdg.configFile = {
      "nvim/init.lua".text = ''
        -- Neovim configuration
        vim.g.mapleader = " "
        vim.g.maplocalleader = " "

        -- Basic settings
        vim.opt.number = true
        vim.opt.relativenumber = true
        vim.opt.shiftwidth = 2
        vim.opt.expandtab = true
        vim.opt.smartindent = true
        vim.opt.wrap = false
        vim.opt.incsearch = true
        vim.opt.hlsearch = true
        vim.opt.ignorecase = true
        vim.opt.smartcase = true
        vim.opt.termguicolors = true
        vim.opt.background = "dark"
        vim.opt.clipboard = "unnamedplus"
        vim.opt.mouse = "a"
        vim.opt.showmatch = true
        vim.opt.cursorline = true
        vim.opt.signcolumn = "yes"
        vim.opt.updatetime = 300
        vim.opt.timeoutlen = 300

        -- Key mappings
        local map = vim.keymap.set

        -- File explorer
        map('n', '<leader>e', ':NvimTreeToggle<CR>', { silent = true })

        -- Fuzzy finder
        map('n', '<leader>ff', ':Telescope find_files<CR>', { silent = true })
        map('n', '<leader>fg', ':Telescope live_grep<CR>', { silent = true })
        map('n', '<leader>fb', ':Telescope buffers<CR>', { silent = true })
        map('n', '<leader>fh', ':Telescope help_tags<CR>', { silent = true })

        -- File operations
        map('n', '<leader>w', ':w<CR>', { silent = true })
        map('n', '<leader>q', ':q<CR>', { silent = true })
        map('n', '<leader>bd', ':bd<CR>', { silent = true })

        -- Window navigation
        map('n', '<C-h>', '<C-w>h', { silent = true })
        map('n', '<C-j>', '<C-w>j', { silent = true })
        map('n', '<C-k>', '<C-w>k', { silent = true })
        map('n', '<C-l>', '<C-w>l', { silent = true })

        -- LSP
        map('n', 'gd', vim.lsp.buf.definition, { silent = true })
        map('n', 'gr', vim.lsp.buf.references, { silent = true })
        map('n', 'K', vim.lsp.buf.hover, { silent = true })
        map('n', '<leader>rn', vim.lsp.buf.rename, { silent = true })
        map('n', '<leader>ca', vim.lsp.buf.code_action, { silent = true })

        -- Git
        map('n', '<leader>gb', ':GitBlame<CR>', { silent = true })
        map('n', '<leader>gd', ':Gvdiffsplit<CR>', { silent = true })

        -- Terminal
        map('n', '<leader>tt', ':ToggleTerm<CR>', { silent = true })
        map('t', '<Esc>', '<C-\\><C-n>', { silent = true })

        -- Colorscheme
        vim.cmd.colorscheme('catppuccin')
      '';

      "nvim/lua/plugins.lua".text = ''
        -- Plugin manager
        local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
        if not vim.loop.fs_stat(lazypath) then
          vim.fn.system({
            "git",
            "clone",
            "--filter=blob:none",
            "https://github.com/folke/lazy.nvim.git",
            "--branch=stable",
            lazypath,
          })
        end
        vim.opt.rtp:prepend(lazypath)

        -- Plugin configuration
        require("lazy").setup({
          -- Theme
          {
            "catppuccin/nvim",
            name = "catppuccin",
            priority = 1000,
            config = function()
              vim.cmd.colorscheme("catppuccin")
            end,
          },

          -- File explorer
          {
            "nvim-tree/nvim-tree.lua",
            dependencies = { "nvim-tree/nvim-web-devicons" },
            config = function()
              require("nvim-tree").setup({
                git = { enable = true, ignore = false },
                view = { width = 30 },
                renderer = { icons = { show = { git = true } } },
              })
            end,
          },

          -- Fuzzy finder
          {
            "nvim-telescope/telescope.nvim",
            dependencies = { "nvim-lua/plenary.nvim" },
            config = function()
              require("telescope").setup({
                defaults = {
                  mappings = {
                    i = {
                      ["<C-j>"] = "move_selection_next",
                      ["<C-k>"] = "move_selection_previous",
                    },
                  },
                },
              })
            end,
          },

          -- LSP
          {
            "neovim/nvim-lspconfig",
            dependencies = {
              "hrsh7th/cmp-nvim-lsp",
              "hrsh7th/cmp-buffer",
              "hrsh7th/cmp-path",
              "hrsh7th/cmp-cmdline",
              "hrsh7th/nvim-cmp",
              "L3MON4D3/LuaSnip",
              "saadparwaiz1/cmp_luasnip",
            },
            config = function()
              local cmp = require("cmp")
              local luasnip = require("luasnip")

              cmp.setup({
                snippet = {
                  expand = function(args)
                    luasnip.lsp_expand(args.body)
                  end,
                },
                mapping = cmp.mapping.preset.insert({
                  ["<C-b>"] = cmp.mapping.scroll_docs(-4),
                  ["<C-f>"] = cmp.mapping.scroll_docs(4),
                  ["<C-Space>"] = cmp.mapping.complete(),
                  ["<C-e>"] = cmp.mapping.abort(),
                  ["<CR>"] = cmp.mapping.confirm({ select = true }),
                  ["<Tab>"] = cmp.mapping(function(fallback)
                    if cmp.visible() then
                      cmp.select_next_item()
                    elseif luasnip.expand_or_jumpable() then
                      luasnip.expand_or_jump()
                    else
                      fallback()
                    end
                  end, { "i", "s" }),
                  ["<S-Tab>"] = cmp.mapping(function(fallback)
                    if cmp.visible() then
                      cmp.select_prev_item()
                    elseif luasnip.jumpable(-1) then
                      luasnip.jump(-1)
                    else
                      fallback()
                    end
                  end, { "i", "s" }),
                }),
                sources = cmp.config.sources({
                  { name = "nvim_lsp" },
                  { name = "luasnip" },
                }, {
                  { name = "buffer" },
                  { name = "path" },
                }),
              })

              -- LSP servers
              local lspconfig = require("lspconfig")

              -- Nix LSP
              lspconfig.nil_ls.setup({})

              -- Rust LSP
              lspconfig.rust_analyzer.setup({})

              -- TypeScript LSP
              lspconfig.tsserver.setup({})

              -- Lua LSP
              lspconfig.lua_ls.setup({})

              -- Bash LSP
              lspconfig.bashls.setup({})
            end,
          },

          -- Treesitter
          {
            "nvim-treesitter/nvim-treesitter",
            build = ":TSUpdate",
            config = function()
              require("nvim-treesitter.configs").setup({
                ensure_installed = {
                  "nix", "rust", "typescript", "javascript", "lua", "bash",
                  "json", "yaml", "toml", "markdown", "python", "go"
                },
                highlight = { enable = true },
                indent = { enable = true },
              })
            end,
          },

          -- Git integration
          {
            "lewis6991/gitsigns.nvim",
            config = function()
              require("gitsigns").setup({})
            end,
          },

          -- Status line
          {
            "nvim-lualine/lualine.nvim",
            dependencies = { "nvim-tree/nvim-web-devicons" },
            config = function()
              require("lualine").setup({
                theme = "catppuccin",
              })
            end,
          },

          -- Buffer line
          {
            "akinsho/bufferline.nvim",
            dependencies = { "nvim-tree/nvim-web-devicons" },
            config = function()
              require("bufferline").setup({})
            end,
          },

          -- Indent guides
          {
            "lukas-reineke/indent-blankline.nvim",
            config = function()
              require("indent_blankline").setup({
                show_current_context = true,
                show_current_context_start = true,
              })
            end,
          },

          -- Comment
          {
            "numToStr/Comment.nix",
            config = function()
              require("Comment").setup({})
            end,
          },

          -- Surround
          {
            "kylechui/nvim-surround",
            config = function()
              require("nvim-surround").setup({})
            end,
          },

          -- Auto pairs
          {
            "windwp/nvim-autopairs",
            config = function()
              require("nvim-autopairs").setup({})
            end,
          },

          -- Terminal
          {
            "akinsho/toggleterm.nvim",
            config = function()
              require("toggleterm").setup({
                direction = "float",
                size = 20,
              })
            end,
          },
        })
      '';
    };
  };
}
