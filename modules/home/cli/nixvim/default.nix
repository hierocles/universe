{
  options,
  config,
  lib,
  pkgs,
  ...
}:
with lib;
with lib.universe; let
  cfg = config.universe.cli.nixvim;
in {
  options.universe.cli.nixvim = with types; {
    enable = mkBoolOpt false "Whether or not to enable neovim.";
    claude = mkBoolOpt false "Whether or not to enable claude-code.";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs;
      [
        alejandra
        deadnix
        statix
        nixpkgs-fmt
        rubyfmt
        stylua
        yamlfmt
        viu
        chafa
        tree-sitter
        ripgrep # Required for telescope live_grep
        fd # Better find for telescope
        nodejs # Required for some LSP servers
        python3 # Required for Python LSP and debugging
      ]
      ++ lib.optionals cfg.claude [
        claude-code
      ];

    programs.nixvim = {
      nixpkgs.config.allowUnfree = mkIf cfg.claude true;
      enable = true;
      defaultEditor = true;
      extraPlugins = with pkgs.vimPlugins; [
        direnv-vim
        nvim-lspconfig
      ];
      extraConfigLua = ''
        -- Configure DAP UI auto-open/close
        local dap, dapui = require("dap"), require("dapui")
        dap.listeners.after.event_initialized["dapui_config"] = function()
          dapui.open()
        end
        dap.listeners.before.event_terminated["dapui_config"] = function()
          dapui.close()
        end
        dap.listeners.before.event_exited["dapui_config"] = function()
          dapui.close()
        end
      '';

      globals = {
        mapleader = " ";
        direnv_auto = 1;
        direnv_silent_load = 0;
      };

      colorschemes.catppuccin.enable = true;
      highlight.extraWhitespace.bg = "red";

      keymaps = [
        # Window navigation
        {
          action = "<C-w>h";
          key = "<C-h>";
          options.desc = "Move to left window";
        }
        {
          action = "<C-w>j";
          key = "<C-j>";
          options.desc = "Move to bottom window";
        }
        {
          action = "<C-w>k";
          key = "<C-k>";
          options.desc = "Move to top window";
        }
        {
          action = "<C-w>l";
          key = "<C-l>";
          options.desc = "Move to right window";
        }

        # Quick save/quit
        {
          action = "<cmd>w<CR>";
          key = "<leader>w";
          options.desc = "Save file";
        }
        {
          action = "<cmd>q<CR>";
          key = "<leader>q";
          options.desc = "Quit";
        }
        {
          action = "<cmd>qa<CR>";
          key = "<leader>Q";
          options.desc = "Quit all";
        }

        # Buffer navigation
        {
          action = "<cmd>BufferLineCycleNext<CR>";
          key = "<Tab>";
          options.desc = "Next buffer";
        }
        {
          action = "<cmd>BufferLineCyclePrev<CR>";
          key = "<S-Tab>";
          options.desc = "Previous buffer";
        }
        {
          action = "<cmd>bd<CR>";
          key = "<leader>bd";
          options.desc = "Delete buffer";
        }
        {
          action = "<cmd>BufferLinePickClose<CR>";
          key = "<leader>bD";
          options.desc = "Pick buffer to close";
        }

        # File explorer
        {
          action = "<cmd>Neotree toggle<CR>";
          key = "<leader>e";
          options.desc = "Toggle file explorer";
        }
        {
          action = "<cmd>Neotree focus<CR>";
          key = "<leader>E";
          options.desc = "Focus file explorer";
        }

        # LSP
        {
          action = "<cmd>LspInfo<CR>";
          key = "<leader>li";
          options.desc = "LSP Info";
        }
        {
          action = "<cmd>lua vim.lsp.buf.definition()<CR>";
          key = "gd";
          options.desc = "Go to definition";
        }
        {
          action = "<cmd>lua vim.lsp.buf.references()<CR>";
          key = "gr";
          options.desc = "Find references";
        }
        {
          action = "<cmd>lua vim.lsp.buf.hover()<CR>";
          key = "K";
          options.desc = "Hover documentation";
        }
        {
          action = "<cmd>lua vim.lsp.buf.signature_help()<CR>";
          key = "<leader>k";
          options.desc = "Signature help";
        }
        {
          action = "<cmd>lua vim.lsp.buf.rename()<CR>";
          key = "<leader>rn";
          options.desc = "Rename symbol";
        }
        {
          action = "<cmd>lua vim.lsp.buf.code_action()<CR>";
          key = "<leader>ca";
          options.desc = "Code actions";
        }
        {
          action = "<cmd>lua vim.lsp.buf.format({ async = true })<CR>";
          key = "<leader>cf";
          options.desc = "Format code";
        }

        # Diagnostics
        {
          action = "<cmd>lua vim.diagnostic.goto_next()<CR>";
          key = "]d";
          options.desc = "Next diagnostic";
        }
        {
          action = "<cmd>lua vim.diagnostic.goto_prev()<CR>";
          key = "[d";
          options.desc = "Previous diagnostic";
        }
        {
          action = "<cmd>lua vim.diagnostic.open_float()<CR>";
          key = "<leader>df";
          options.desc = "Show diagnostic float";
        }
        {
          action = "<cmd>Trouble diagnostics toggle<CR>";
          key = "<leader>dx";
          options.desc = "Toggle diagnostics list";
        }

        # Telescope
        {
          action = "<cmd>Telescope find_files<CR>";
          key = "<leader>ff";
          options.desc = "Find files";
        }
        {
          action = "<cmd>Telescope live_grep<CR>";
          key = "<leader>fg";
          options.desc = "Live grep";
        }
        {
          action = "<cmd>Telescope buffers<CR>";
          key = "<leader>fb";
          options.desc = "Find buffers";
        }
        {
          action = "<cmd>Telescope help_tags<CR>";
          key = "<leader>fh";
          options.desc = "Help tags";
        }
        {
          action = "<cmd>Telescope lsp_definitions<CR>";
          key = "<leader>fd";
          options.desc = "Find definitions";
        }
        {
          action = "<cmd>Telescope lsp_references<CR>";
          key = "<leader>fr";
          options.desc = "Find references";
        }
        {
          action = "<cmd>Telescope lsp_document_symbols<CR>";
          key = "<leader>fs";
          options.desc = "Find document symbols";
        }

        # Git
        {
          action = "<cmd>Gitsigns next_hunk<CR>";
          key = "]h";
          options.desc = "Next git hunk";
        }
        {
          action = "<cmd>Gitsigns prev_hunk<CR>";
          key = "[h";
          options.desc = "Previous git hunk";
        }
        {
          action = "<cmd>Gitsigns preview_hunk<CR>";
          key = "<leader>hp";
          options.desc = "Preview git hunk";
        }
        {
          action = "<cmd>Gitsigns stage_hunk<CR>";
          key = "<leader>hs";
          options.desc = "Stage git hunk";
        }
        {
          action = "<cmd>Gitsigns reset_hunk<CR>";
          key = "<leader>hr";
          options.desc = "Reset git hunk";
        }
        {
          action = "<cmd>Gitsigns toggle_current_line_blame<CR>";
          key = "<leader>hb";
          options.desc = "Toggle git blame";
        }

        # Terminal
        {
          action = "<cmd>split | terminal<CR>";
          key = "<leader>th";
          options.desc = "Horizontal terminal";
        }
        {
          action = "<cmd>vsplit | terminal<CR>";
          key = "<leader>tv";
          options.desc = "Vertical terminal";
        }

        # Better escape for terminal mode
        {
          action = "<C-\\><C-n>";
          key = "<Esc>";
          mode = "t";
          options.desc = "Exit terminal mode";
        }

        # Debug keymaps
        {
          action = "<cmd>DapToggleBreakpoint<CR>";
          key = "<leader>db";
          options.desc = "Toggle breakpoint";
        }
        {
          action = "<cmd>DapContinue<CR>";
          key = "<leader>dc";
          options.desc = "Debug continue";
        }
        {
          action = "<cmd>DapStepOver<CR>";
          key = "<leader>do";
          options.desc = "Debug step over";
        }
        {
          action = "<cmd>DapStepInto<CR>";
          key = "<leader>di";
          options.desc = "Debug step into";
        }
        {
          action = "<cmd>DapStepOut<CR>";
          key = "<leader>dO";
          options.desc = "Debug step out";
        }
        {
          action = "<cmd>lua require('dapui').toggle()<CR>";
          key = "<leader>du";
          options.desc = "Toggle debug UI";
        }
        {
          action = "<cmd>DapTerminate<CR>";
          key = "<leader>dt";
          options.desc = "Debug terminate";
        }

        # Test keymaps
        {
          action = "<cmd>lua require('neotest').run.run()<CR>";
          key = "<leader>tr";
          options.desc = "Run nearest test";
        }
        {
          action = "<cmd>lua require('neotest').run.run(vim.fn.expand('%'))<CR>";
          key = "<leader>tf";
          options.desc = "Run tests in file";
        }
        {
          action = "<cmd>lua require('neotest').run.run({ strategy = 'dap' })<CR>";
          key = "<leader>td";
          options.desc = "Debug nearest test";
        }
        {
          action = "<cmd>lua require('neotest').summary.toggle()<CR>";
          key = "<leader>ts";
          options.desc = "Toggle test summary";
        }
        {
          action = "<cmd>lua require('neotest').output_panel.toggle()<CR>";
          key = "<leader>to";
          options.desc = "Toggle test output";
        }
      ];

      opts = {
        updatetime = 100;
        number = true;
        relativenumber = true;
        shiftwidth = 2;
        swapfile = false;
        undofile = true;
        incsearch = true;
        inccommand = "split";
        ignorecase = true;
        smartcase = true;
        signcolumn = "yes:1";
      };

      plugins = {
        claude-code = mkIf cfg.claude {
          enable = true;
          autoLoad = true;
        };

        # File management
        neo-tree = {
          enable = true;
          enableDiagnostics = true;
          enableGitStatus = true;
          enableModifiedMarkers = true;
          enableRefreshOnWrite = true;
          closeIfLastWindow = true;
          popupBorderStyle = "rounded";
          buffers = {
            bindToCwd = false;
            followCurrentFile = {
              enabled = true;
              leaveDirsOpen = true;
            };
          };
          window = {
            width = 30;
            height = 15;
            autoExpandWidth = false;
            mappings = {
              "<space>" = "none";
            };
          };
        };

        # Buffer management
        bufferline = {
          enable = true;
          settings.options = {
            mode = "buffers";
            themable = true;
            numbers = "ordinal";
            diagnostics = "nvim_lsp";
            separator_style = "slant";
            show_buffer_close_icons = false;
            show_close_icon = false;
            color_icons = true;
            offsets = [
              {
                filetype = "neo-tree";
                text = "Neo-tree";
                separator = true;
                text_align = "left";
              }
            ];
          };
        };

        # Git integration
        gitsigns = {
          enable = true;
          settings = {
            signs = {
              add = {text = "+";};
              change = {text = "~";};
              delete = {text = "_";};
              topdelete = {text = "‾";};
              changedelete = {text = "~";};
            };
            current_line_blame = true;
            current_line_blame_opts = {
              virt_text = true;
              virt_text_pos = "eol";
              delay = 300;
            };
          };
        };

        # Visual enhancements
        indent-blankline = {
          enable = true;
          settings = {
            indent = {char = "│";};
            scope = {enabled = false;};
            exclude = {
              buftypes = ["terminal" "nofile"];
              filetypes = ["help" "alpha" "dashboard" "neo-tree" "Trouble" "lazy"];
            };
          };
        };

        # Code commenting
        comment = {
          enable = true;
          settings = {
            opleader = {
              line = "gc";
              block = "gb";
            };
            toggler = {
              line = "gcc";
              block = "gbc";
            };
          };
        };

        # Autopairs
        nvim-autopairs = {
          enable = true;
          settings = {
            check_ts = true;
            ts_config = {
              lua = ["string" "source"];
              javascript = ["string" "template_string"];
            };
          };
        };

        # Surround text objects
        nvim-surround.enable = true;

        # Debugging support
        dap = {
          enable = true;
        };

        dap-ui = {
          enable = true;
          settings.floating.mappings.close = ["<ESC>" "q"];
        };

        dap-virtual-text.enable = true;
        dap-python.enable = true;

        # Testing support
        neotest = {
          enable = true;
          adapters = {
            python.enable = true;
            bash.enable = true;
          };
          settings = {
            quickfix = {
              enabled = true;
              open = false;
            };
          };
        };

        # Better quickfix
        trouble = {
          enable = true;
          settings = {
            modes = {
              diagnostics = {
                mode = "diagnostics";
              };
            };
            icons = {
              indent = {
                middle = "├ ";
                last = "└ ";
                fold_open = " ";
                fold_closed = " ";
              };
              folder_closed = " ";
              folder_open = " ";
              kinds = {
                Array = " ";
                Boolean = "󰨙 ";
                Class = " ";
                Constant = "󰏿 ";
                Constructor = " ";
                Enum = " ";
                EnumMember = " ";
                Event = " ";
                Field = " ";
                File = " ";
                Function = "󰊕 ";
                Interface = " ";
                Key = " ";
                Method = "󰊕 ";
                Module = " ";
                Namespace = "󰦮 ";
                Null = " ";
                Number = "󰎠 ";
                Object = " ";
                Operator = " ";
                Package = " ";
                Property = " ";
                String = " ";
                Struct = "󰆼 ";
                TypeParameter = " ";
                Variable = "󰀫 ";
              };
            };
          };
        };

        blink-cmp = {
          enable = true;
          setupLspCapabilities = true;
          settings = {
            appearance = {
              nerd_font_variant = "normal";
              use_nvim_cmp_as_default = true;
            };
            cmdline = {
              enabled = true;
              keymap = {preset = "inherit";};
              completion = {
                list.selection.preselect = false;
                menu = {auto_show = true;};
                ghost_text = {enabled = true;};
              };
            };
            completion = {
              menu.border = "rounded";
              accept = {
                auto_brackets = {
                  enabled = true;
                  semantic_token_resolution.enabled = false;
                };
              };
              documentation = {
                auto_show = true;
                window.border = "rounded";
              };
            };
            sources = {
              default = [
                "lsp"
                "buffer"
                "path"
                "snippets"
              ];
              providers = {
                buffer = {
                  enabled = true;
                  score_offset = 0;
                };
                lsp = {
                  name = "LSP";
                  enabled = true;
                  score_offset = 10;
                };
              };
            };
          };
        };

        blink-compat.enable = true;
        conform-nvim = {
          enable = true;
          settings = {
            formatters_by_ft = {
              css = ["prettier"];
              html = ["prettier"];
              json = ["prettier"];
              lua = ["stylua"];
              markdown = ["prettier"];
              nix = ["alejandra"];
              python = ["black"];
              ruby = ["rubyfmt"];
              yaml = ["yamlfmt"];
            };
          };
        };

        #lspkind = {
        #  enable = true;
        #  settings = {
        #    cmp = {
        #      enable = false; # Using with blink-cmp instead
        #      menu = {
        #        nvim_lsp = "[LSP]";
        #        nvim_lua = "[Lua]";
        #        path = "[Path]";
        #        buffer = "[Buffer]";
        #        snippets = "[Snippet]";
        #     };
        #    };
        #  };
        #};
        dressing.enable = true;
        fugitive.enable = true;
        fzf-lua.enable = true;
        git-conflict.enable = true;

        # Enhanced statusline
        lualine = {
          enable = true;
          settings = {
            options = {
              theme = "catppuccin";
              component_separators = {
                left = "";
                right = "";
              };
              section_separators = {
                left = "";
                right = "";
              };
              disabled_filetypes = {statusline = ["neo-tree"];};
              globalstatus = true;
            };
            sections = {
              lualine_a = ["mode"];
              lualine_b = [
                "branch"
                {
                  __unkeyed-1 = "diff";
                  symbols = {
                    added = " ";
                    modified = " ";
                    removed = " ";
                  };
                }
                "diagnostics"
              ];
              lualine_c = [
                {
                  __unkeyed-1 = "filename";
                  path = 1;
                  symbols = {
                    modified = " ●";
                    readonly = " ";
                    unnamed = "No Name";
                  };
                }
              ];
              lualine_x = [
                "encoding"
                "fileformat"
                "filetype"
              ];
              lualine_y = ["progress"];
              lualine_z = ["location"];
            };
            inactive_sections = {
              lualine_a = [];
              lualine_b = [];
              lualine_c = ["filename"];
              lualine_x = ["location"];
              lualine_y = [];
              lualine_z = [];
            };
          };
        };

        luasnip.enable = true;

        lsp = {
          enable = true;
          servers = {
            bashls.enable = true;
            jsonls.enable = true;
            lua_ls = {
              enable = true;
              settings.telemetry.enable = false;
            };
            marksman.enable = true;
            nil_ls = {
              enable = true;
              settings = {
                formatting.command = ["alejandra"];
              };
            };
            pyright = {
              enable = true;
              settings = {
                python = {
                  analysis = {
                    typeCheckingMode = "basic";
                    autoSearchPaths = true;
                    useLibraryCodeForTypes = true;
                    diagnosticMode = "workspace";
                  };
                };
              };
            };
            pylsp = {
              enable = false;
              settings.plugins = {
                black.enabled = true;
                flake8.enabled = false;
                isort.enabled = true;
                jedi.enabled = false;
                mccabe.enabled = false;
                pycodestyle.enabled = false;
                pydocstyle.enabled = true;
                pyflakes.enabled = false;
                pylint.enabled = true;
                rope.enabled = false;
                yapf.enabled = false;
              };
            };
            yamlls.enable = true;
          };
        };
        none-ls.sources.formatting.black.enable = true;
        oil.enable = true;
        telescope = {
          enable = true;
          settings.defaults = {
            file_ignore_patterns = [
              "%.git/"
              "node_modules/"
              "%.cache/"
            ];
            layout_config = {
              horizontal = {
                prompt_position = "top";
                preview_width = 0.55;
              };
              vertical = {
                mirror = false;
              };
              width = 0.87;
              height = 0.80;
              preview_cutoff = 120;
            };
            sorting_strategy = "ascending";
            winblend = 0;
          };
          extensions = {
            fzf-native = {
              enable = true;
            };
          };
        };
        treesitter = {
          enable = true;
          folding = false;
          settings.indent.enable = true;
        };
        web-devicons.enable = true;
        which-key = {
          enable = true;
          settings.preset = "helix";
        };
      };
      viAlias = true;
      vimAlias = true;
      vimdiffAlias = true;
    };
  };
}
