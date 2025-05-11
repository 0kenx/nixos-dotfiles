{pkgs, ...}: {
  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    defaultEditor = true;

    # Install plugins
    plugins = with pkgs.vimPlugins; [
      # LSP
      nvim-lspconfig
      mason-nvim
      mason-lspconfig-nvim
      lsp-zero-nvim
      nvim-cmp
      cmp-nvim-lsp
      cmp-buffer
      cmp-path
      luasnip
      cmp_luasnip
      friendly-snippets

      # Tree-sitter
      nvim-treesitter.withAllGrammars
      nvim-treesitter-textobjects
      
      # Telescope
      telescope-nvim
      telescope-fzf-native-nvim
      
      # Git
      vim-fugitive
      gitsigns-nvim
      
      # Visual
      catppuccin-nvim
      lualine-nvim
      nvim-web-devicons
      bufferline-nvim
      indent-blankline-nvim
      nvim-colorizer-lua
      
      # File explorer
      nvim-tree-lua
      
      # Utilities
      which-key-nvim
      auto-pairs
      comment-nvim
      toggleterm-nvim
      trouble-nvim
      nvim-autopairs
      
      # Languages/filetype support
      rust-tools-nvim
      neodev-nvim
      crates-nvim
      markdown-preview-nvim
      vim-nix
    ];

    # Setup Lua configuration
    extraConfig = ''
      lua require('config')
    '';
  };
  
  # Place Lua configuration files in ~/.config/nvim/lua
  xdg.configFile = {
    # Core configuration
    "nvim/lua/config/init.lua".text = ''
      -- Load all configuration modules
      require('config.options')
      require('config.keymaps')
      require('config.autocmds')
      require('config.colorscheme')
      require('config.plugins')
    '';
    
    # General options
    "nvim/lua/config/options.lua".text = ''
      -- General Neovim settings
      vim.opt.number = true
      vim.opt.relativenumber = true
      vim.opt.mouse = 'a'
      vim.opt.ignorecase = true
      vim.opt.smartcase = true
      vim.opt.hlsearch = true
      vim.opt.wrap = false
      vim.opt.breakindent = true
      vim.opt.tabstop = 2
      vim.opt.shiftwidth = 2
      vim.opt.expandtab = true
      vim.opt.termguicolors = true
      vim.opt.scrolloff = 8
      vim.opt.sidescrolloff = 8
      vim.opt.signcolumn = 'yes'
      vim.opt.splitright = true
      vim.opt.splitbelow = true
      vim.opt.updatetime = 100
      vim.opt.timeoutlen = 300
      vim.g.mapleader = " "
      vim.g.maplocalleader = " "
      vim.opt.clipboard = 'unnamedplus'
      vim.opt.cursorline = true
      vim.opt.undofile = true
      vim.opt.pumheight = 10
      vim.opt.completeopt = 'menu,menuone,noselect'
    '';
    
    # Keymaps
    "nvim/lua/config/keymaps.lua".text = ''
      -- Define key mappings for Neovim
      local map = vim.keymap.set
      local opts = { noremap = true, silent = true }

      -- Better window movement
      map('n', '<C-h>', '<C-w>h', opts)
      map('n', '<C-j>', '<C-w>j', opts)
      map('n', '<C-k>', '<C-w>k', opts)
      map('n', '<C-l>', '<C-w>l', opts)
      
      -- Resize windows with arrows
      map('n', '<C-Up>', ':resize -2<CR>', opts)
      map('n', '<C-Down>', ':resize +2<CR>', opts)
      map('n', '<C-Left>', ':vertical resize -2<CR>', opts)
      map('n', '<C-Right>', ':vertical resize +2<CR>', opts)
      
      -- Move text up and down
      map('n', '<A-j>', '<Esc>:m .+1<CR>==', opts)
      map('n', '<A-k>', '<Esc>:m .-2<CR>==', opts)
      map('v', '<A-j>', ":m '>+1<CR>gv=gv", opts)
      map('v', '<A-k>', ":m '<-2<CR>gv=gv", opts)
      
      -- Better indenting
      map('v', '<', '<gv', opts)
      map('v', '>', '>gv', opts)
      
      -- Clear search highlighting
      map('n', '<Esc>', ':noh<CR>', opts)
      
      -- File explorer
      map('n', '<leader>e', ':NvimTreeToggle<CR>', opts)
      map('n', '<leader>o', ':NvimTreeFocus<CR>', opts)
      
      -- Window splitting
      map('n', '<leader>\\', ':vsplit<CR>', opts)
      map('n', '<leader>-', ':split<CR>', opts)
      
      -- Terminal
      map('n', '<leader>t', ':ToggleTerm<CR>', opts)
      map('t', '<Esc>', '<C-\\><C-n>', opts)
      
      -- Buffer navigation
      map('n', '<S-l>', ':bnext<CR>', opts)
      map('n', '<S-h>', ':bprevious<CR>', opts)
      map('n', '<leader>c', ':Bdelete!<CR>', opts)
      
      -- Telescope
      map('n', '<leader>ff', ':Telescope find_files<CR>', opts)
      map('n', '<leader>fg', ':Telescope live_grep<CR>', opts)
      map('n', '<leader>fb', ':Telescope buffers<CR>', opts)
      map('n', '<leader>fh', ':Telescope help_tags<CR>', opts)
      map('n', '<leader>fp', ':Telescope oldfiles<CR>', opts)
      map('n', '<leader>fc', ':Telescope current_buffer_fuzzy_find<CR>', opts)
      
      -- LSP
      map('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
      map('n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)
      map('n', '<leader>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
      map('n', '<leader>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
      map('n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
      map('n', '<leader>ld', '<cmd>lua vim.diagnostic.open_float()<CR>', opts)
      map('n', '[d', '<cmd>lua vim.diagnostic.goto_prev()<CR>', opts)
      map('n', ']d', '<cmd>lua vim.diagnostic.goto_next()<CR>', opts)
      map('n', '<leader>lf', '<cmd>lua vim.lsp.buf.format({ async = true })<CR>', opts)
      
      -- Diagnostics
      map('n', '<leader>xx', '<cmd>TroubleToggle<CR>', opts)
      map('n', '<leader>xw', '<cmd>TroubleToggle workspace_diagnostics<CR>', opts)
      map('n', '<leader>xd', '<cmd>TroubleToggle document_diagnostics<CR>', opts)
      
      -- Git
      map('n', '<leader>gs', ':Git<CR>', opts)
      map('n', '<leader>gj', ':Gitsigns next_hunk<CR>', opts)
      map('n', '<leader>gk', ':Gitsigns prev_hunk<CR>', opts)
      map('n', '<leader>gl', ':Gitsigns blame_line<CR>', opts)
      map('n', '<leader>gp', ':Gitsigns preview_hunk<CR>', opts)
      map('n', '<leader>gr', ':Gitsigns reset_hunk<CR>', opts)
      map('n', '<leader>gR', ':Gitsigns reset_buffer<CR>', opts)
      map('n', '<leader>gs', ':Gitsigns stage_hunk<CR>', opts)
      map('n', '<leader>gu', ':Gitsigns undo_stage_hunk<CR>', opts)
      map('n', '<leader>gd', ':Gitsigns diffthis<CR>', opts)
    '';
    
    # Autocommands
    "nvim/lua/config/autocmds.lua".text = ''
      -- Define autocommands
      local augroup = vim.api.nvim_create_augroup
      local autocmd = vim.api.nvim_create_autocmd

      -- Remove trailing whitespace on save
      local TrimWhiteSpaceGrp = augroup('TrimWhiteSpaceGrp', {})
      autocmd('BufWritePre', {
        group = TrimWhiteSpaceGrp,
        pattern = '*',
        command = '%s/\\s\\+$//e',
      })
      
      -- Highlight on yank
      local YankHighlight = augroup('YankHighlight', {})
      autocmd('TextYankPost', {
        group = YankHighlight,
        pattern = '*',
        callback = function()
          vim.highlight.on_yank({ higroup = 'IncSearch', timeout = 200 })
        end,
      })
      
      -- Resize splits when window is resized
      local ResizeGrp = augroup('ResizeGrp', {})
      autocmd('VimResized', {
        group = ResizeGrp,
        pattern = '*',
        command = 'tabdo wincmd =',
      })
      
      -- Return to last edit position when opening files
      local LastPosition = augroup('LastPosition', {})
      autocmd('BufReadPost', {
        group = LastPosition,
        pattern = '*',
        callback = function()
          if vim.fn.line("'\"") > 0 and vim.fn.line("'\"") <= vim.fn.line('$') then
            vim.fn.setpos('.', vim.fn.getpos("'\""))
            vim.api.nvim_exec('normal! zz', false)
          end
        end,
      })
    '';
    
    # Colorscheme
    "nvim/lua/config/colorscheme.lua".text = ''
      -- Set up the Catppuccin colorscheme
      require('catppuccin').setup({
        flavour = 'macchiato', -- latte, frappe, macchiato, mocha
        transparent_background = false,
        term_colors = true,
        dim_inactive = {
          enabled = true,
          shade = "dark",
          percentage = 0.15,
        },
        integrations = {
          cmp = true,
          gitsigns = true,
          nvimtree = true,
          telescope = true,
          which_key = true,
          indent_blankline = { enabled = true },
          native_lsp = {
            enabled = true,
            virtual_text = {
              errors = { "italic" },
              hints = { "italic" },
              warnings = { "italic" },
              information = { "italic" },
            },
            underlines = {
              errors = { "underline" },
              hints = { "underline" },
              warnings = { "underline" },
              information = { "underline" },
            },
          },
        },
      })
      
      vim.cmd.colorscheme 'catppuccin'
    '';
    
    # Plugin configuration
    "nvim/lua/config/plugins.lua".text = ''
      -- Configure LSP with Mason
      require('config.plugins.lsp')
      
      -- Configure Treesitter
      require('config.plugins.treesitter')
      
      -- Configure Telescope
      require('config.plugins.telescope')
      
      -- Configure UI elements
      require('config.plugins.ui')
      
      -- Configure utilities
      require('config.plugins.utilities')
    '';
    
    # LSP Configuration
    "nvim/lua/config/plugins/lsp.lua".text = ''
      local lsp_zero = require('lsp-zero')
      
      lsp_zero.on_attach(function(client, bufnr)
        -- Default keybindings are set in keymaps.lua
        lsp_zero.default_keymaps({buffer = bufnr})
      end)
      
      -- Setup Mason
      require('mason').setup({})
      require('mason-lspconfig').setup({
        ensure_installed = {
          'lua_ls',
          'rust_analyzer',
          'pyright',
          'tsserver',
          'html',
          'cssls',
          'jsonls',
          'bashls',
          'marksman',
          'nil_ls',   -- Nix language server
        },
        handlers = {
          lsp_zero.default_setup,
          lua_ls = function()
            require('lspconfig').lua_ls.setup(lsp_zero.nvim_lua_ls())
          end,
          rust_analyzer = function()
            require('rust-tools').setup({})
          end,
        }
      })
      
      -- Configure completion
      local cmp = require('cmp')
      local cmp_select = {behavior = cmp.SelectBehavior.Select}
      
      cmp.setup({
        sources = {
          {name = 'path'},
          {name = 'nvim_lsp'},
          {name = 'luasnip', keyword_length = 2},
          {name = 'buffer', keyword_length = 3},
        },
        formatting = lsp_zero.cmp_format(),
        mapping = cmp.mapping.preset.insert({
          ['<C-p>'] = cmp.mapping.select_prev_item(cmp_select),
          ['<C-n>'] = cmp.mapping.select_next_item(cmp_select),
          ['<C-Space>'] = cmp.mapping.complete(),
          ['<C-e>'] = cmp.mapping.abort(),
          ['<CR>'] = cmp.mapping.confirm({select = true}),
          ['<Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            else
              fallback()
            end
          end, {'i', 's'}),
          ['<S-Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            else
              fallback()
            end
          end, {'i', 's'}),
        }),
      })
      
      -- Setup neodev for Lua development
      require('neodev').setup()
      
      -- Set up rust-tools
      require('crates').setup()
    '';
    
    # Treesitter Configuration
    "nvim/lua/config/plugins/treesitter.lua".text = ''
      require('nvim-treesitter.configs').setup {
        highlight = {
          enable = true,
        },
        indent = {
          enable = true,
        },
        textobjects = {
          select = {
            enable = true,
            lookahead = true,
            keymaps = {
              ["af"] = "@function.outer",
              ["if"] = "@function.inner",
              ["ac"] = "@class.outer",
              ["ic"] = "@class.inner",
              ["aa"] = "@parameter.outer",
              ["ia"] = "@parameter.inner",
            },
          },
          move = {
            enable = true,
            set_jumps = true,
            goto_next_start = {
              ["]f"] = "@function.outer",
              ["]c"] = "@class.outer",
            },
            goto_next_end = {
              ["]F"] = "@function.outer",
              ["]C"] = "@class.outer",
            },
            goto_previous_start = {
              ["[f"] = "@function.outer",
              ["[c"] = "@class.outer",
            },
            goto_previous_end = {
              ["[F"] = "@function.outer",
              ["[C"] = "@class.outer",
            },
          },
        },
        incremental_selection = {
          enable = true,
          keymaps = {
            init_selection = '<CR>',
            scope_incremental = '<CR>',
            node_incremental = '<TAB>',
            node_decremental = '<S-TAB>',
          },
        },
      }
    '';
    
    # Telescope Configuration
    "nvim/lua/config/plugins/telescope.lua".text = ''
      local telescope = require('telescope')
      
      telescope.setup {
        defaults = {
          mappings = {
            i = {
              ['<C-j>'] = 'move_selection_next',
              ['<C-k>'] = 'move_selection_previous',
            }
          },
          file_ignore_patterns = {
            "node_modules",
            ".git/",
            "dist/",
            "build/",
            "target/",
          },
        },
        extensions = {
          fzf = {
            fuzzy = true,
            override_generic_sorter = true,
            override_file_sorter = true,
            case_mode = "smart_case",
          }
        }
      }
      
      telescope.load_extension('fzf')
    '';
    
    # UI Configuration
    "nvim/lua/config/plugins/ui.lua".text = ''
      -- Configure lualine
      require('lualine').setup {
        options = {
          theme = 'catppuccin',
          component_separators = { left = "", right = "" },
          section_separators = { left = "", right = "" },
          globalstatus = true,
        },
        sections = {
          lualine_a = {'mode'},
          lualine_b = {'branch', 'diff', 'diagnostics'},
          lualine_c = {'filename'},
          lualine_x = {'encoding', 'fileformat', 'filetype'},
          lualine_y = {'progress'},
          lualine_z = {'location'}
        },
      }
      
      -- Configure bufferline
      require('bufferline').setup {
        options = {
          mode = 'buffers',
          separator_style = 'slant',
          always_show_bufferline = false,
          show_buffer_close_icons = true,
          show_close_icon = true,
          color_icons = true,
          diagnostics = 'nvim_lsp',
          diagnostics_indicator = function(_, _, diagnostics_dict, _)
            local s = " "
            if diagnostics_dict.error then
              s = s .. "E" .. diagnostics_dict.error .. " "
            end
            if diagnostics_dict.warning then
              s = s .. "W" .. diagnostics_dict.warning .. " "
            end
            return s
          end,
          offsets = {
            {
              filetype = "NvimTree",
              text = "File Explorer",
              highlight = "Directory",
              separator = true
            }
          },
        },
      }
      
      -- Configure indent-blankline
      require('ibl').setup {
        indent = {
          char = "▏",
        },
        scope = {
          enabled = true,
          show_start = false,
          show_end = false,
        },
      }
      
      -- Configure colorizer
      require('colorizer').setup {
        filetypes = { '*' },
        user_default_options = {
          RGB = true,
          RRGGBB = true,
          names = false,
          RRGGBBAA = true,
          css = true,
          css_fn = true,
          mode = 'background',
        },
      }
      
      -- Configure NvimTree
      require('nvim-tree').setup {
        disable_netrw = true,
        hijack_netrw = true,
        sync_root_with_cwd = true,
        view = {
          width = 30,
        },
        renderer = {
          group_empty = true,
          icons = {
            show = {
              git = true,
              folder = true,
              file = true,
              folder_arrow = true,
            },
          },
        },
        filters = {
          dotfiles = false,
        },
        git = {
          enable = true,
          ignore = false,
        },
        actions = {
          open_file = {
            quit_on_open = false,
            resize_window = true,
          },
        },
      }
    '';
    
    # Utilities Configuration
    "nvim/lua/config/plugins/utilities.lua".text = ''
      -- Configure which-key
      require('which-key').setup {
        plugins = {
          spelling = {
            enabled = true,
          },
        },
        window = {
          border = "single",
        },
      }
      
      -- Configure Comment.nvim
      require('Comment').setup()
      
      -- Configure toggleterm
      require('toggleterm').setup {
        size = 20,
        open_mapping = [[<c-\\>]],
        shade_terminals = true,
        shading_factor = 2,
        direction = "float",
        float_opts = {
          border = "curved",
          highlights = {
            border = "Normal",
            background = "Normal",
          },
        },
      }
      
      -- Configure trouble.nvim
      require('trouble').setup {
        position = "bottom",
        height = 10,
        icons = true,
        mode = "workspace_diagnostics",
        fold_open = "",
        fold_closed = "",
        group = true,
        padding = true,
        action_keys = {
          close = "q",
          cancel = "<esc>",
          refresh = "r",
          jump = {"<cr>", "<tab>"},
          open_split = {"<c-x>"},
          open_vsplit = {"<c-v>"},
          open_tab = {"<c-t>"},
          jump_close = {"o"},
          toggle_mode = "m",
          toggle_preview = "P",
          hover = "K",
          preview = "p",
          close_folds = {"zM", "zm"},
          open_folds = {"zR", "zr"},
          toggle_fold = {"zA", "za"},
          previous = "k",
          next = "j"
        },
      }
      
      -- Configure autopairs
      require('nvim-autopairs').setup {
        check_ts = true,
        ts_config = {
          lua = {'string', 'source'},
          javascript = {'string', 'template_string'},
        },
        disable_filetype = {'TelescopePrompt', 'vim'},
      }
      
      -- Configure gitsigns
      require('gitsigns').setup {
        signs = {
          add          = { text = '│' },
          change       = { text = '│' },
          delete       = { text = '_' },
          topdelete    = { text = '‾' },
          changedelete = { text = '~' },
          untracked    = { text = '┆' },
        },
        signcolumn = true,
        numhl = false,
        linehl = false,
        word_diff = false,
        current_line_blame = false,
        current_line_blame_opts = {
          virt_text = true,
          virt_text_pos = 'eol',
          delay = 1000,
          ignore_whitespace = false,
        },
        current_line_blame_formatter = '<author>, <author_time:%Y-%m-%d> - <summary>',
        sign_priority = 6,
        update_debounce = 100,
        status_formatter = nil, -- Use default
        watch_gitdir = {
          interval = 1000,
          follow_files = true,
        },
        preview_config = {
          border = 'single',
          style = 'minimal',
          relative = 'cursor',
          row = 0,
          col = 1,
        },
        diff_opts = {
          internal = true,
        },
        yadm = {
          enable = false,
        },
      }
    '';
  };
}