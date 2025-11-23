{pkgs, ...}: {
  # Install neovide GUI and AI dependencies
  home.packages = with pkgs; [
    neovide
    nodejs  # Required for GitHub Copilot
  ];

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

      # AI/LLM Features
      copilot-lua
      copilot-cmp
      CopilotChat-nvim
      plenary-nvim  # Required for telescope
      render-markdown-nvim # Markdown rendering for AI chat

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
      conform-nvim

      # Debugging (DAP)
      nvim-dap
      nvim-dap-ui
      nvim-dap-virtual-text
      nvim-dap-python
      nvim-dap-go

      # Testing
      neotest
      neotest-python
      neotest-rust
      neotest-go
      neotest-jest

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

      -- Neovide-specific settings
      if vim.g.neovide then
        vim.g.neovide_window_blurred = true
        vim.g.neovide_floating_blur_amount_x = 2.0
        vim.g.neovide_floating_blur_amount_y = 2.0
        vim.g.neovide_floating_shadow = true
        vim.g.neovide_floating_z_height = 10
        vim.g.neovide_light_angle_degrees = 45
        vim.g.neovide_light_radius = 5
        vim.g.neovide_background_color = "#24273a" .. string.format("%x", math.floor(255 * 0.85))
        vim.g.neovide_scroll_animation_length = 0.3
        vim.g.neovide_cursor_animation_length = 0.13
        vim.g.neovide_cursor_trail_size = 0.8
        vim.g.neovide_cursor_vfx_mode = "railgun"
        vim.g.neovide_hide_mouse_when_typing = true
        vim.g.neovide_refresh_rate = 60
        vim.g.neovide_remember_window_size = true
        vim.o.guifont = "JetBrainsMono NF:h11"
      end
    '';
    
    # Keymaps
    "nvim/lua/config/keymaps.lua".text = ''
      -- Define key mappings for Neovim
      local map = vim.keymap.set
      local opts = { noremap = true, silent = true }

      -- Cursor navigation: Long jumps with Ctrl and Shift
      -- Ctrl+arrows: Jump by word/paragraph
      map('n', '<C-Left>', 'b', opts)        -- Jump word backward
      map('n', '<C-Right>', 'w', opts)       -- Jump word forward
      map('n', '<C-Up>', '{', opts)          -- Jump paragraph up
      map('n', '<C-Down>', '}', opts)        -- Jump paragraph down
      map('i', '<C-Left>', '<C-o>b', opts)   -- Jump word backward (insert mode)
      map('i', '<C-Right>', '<C-o>w', opts)  -- Jump word forward (insert mode)
      map('i', '<C-Up>', '<C-o>{', opts)     -- Jump paragraph up (insert mode)
      map('i', '<C-Down>', '<C-o>}', opts)   -- Jump paragraph down (insert mode)

      -- Shift+arrows: Visual selection
      map('n', '<S-Left>', 'vh', opts)       -- Select left
      map('n', '<S-Right>', 'vl', opts)      -- Select right
      map('n', '<S-Up>', 'vk', opts)         -- Select up
      map('n', '<S-Down>', 'vj', opts)       -- Select down
      map('v', '<S-Left>', 'h', opts)        -- Extend selection left
      map('v', '<S-Right>', 'l', opts)       -- Extend selection right
      map('v', '<S-Up>', 'k', opts)          -- Extend selection up
      map('v', '<S-Down>', 'j', opts)        -- Extend selection down

      -- Window navigation (hjkl for compatibility, arrows for primary use)
      -- Consistent with OS: Alt=base, Alt+Shift=swap, Alt+Ctrl=resize
      map('n', '<C-h>', '<C-w>h', opts)
      map('n', '<C-j>', '<C-w>j', opts)
      map('n', '<C-k>', '<C-w>k', opts)
      map('n', '<C-l>', '<C-w>l', opts)
      map('n', '<A-Left>', '<C-w>h', opts)
      map('n', '<A-Down>', '<C-w>j', opts)
      map('n', '<A-Up>', '<C-w>k', opts)
      map('n', '<A-Right>', '<C-w>l', opts)

      -- Window swapping (matches OS: Super+Shift → Alt+Shift)
      map('n', '<A-S-Left>', '<C-w>H', opts)
      map('n', '<A-S-Down>', '<C-w>J', opts)
      map('n', '<A-S-Up>', '<C-w>K', opts)
      map('n', '<A-S-Right>', '<C-w>L', opts)

      -- Window resizing (matches OS: Super+Ctrl → Alt+Ctrl)
      map('n', '<A-C-Up>', ':resize -2<CR>', opts)
      map('n', '<A-C-Down>', ':resize +2<CR>', opts)
      map('n', '<A-C-Left>', ':vertical resize -2<CR>', opts)
      map('n', '<A-C-Right>', ':vertical resize +2<CR>', opts)
      
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
      map('n', '<leader>cc', '<cmd>lua require("toggleterm.terminal").Terminal:new({cmd="claude", direction="vertical"}):toggle()<CR>', opts)  -- Open Claude Code CLI
      map('t', '<Esc>', '<C-\\><C-n>', opts)

      -- Buffer navigation
      map('n', '<leader>c', ':Bdelete!<CR>', opts)

      -- Quick buffer switching with Alt+number
      map('n', '<A-1>', '<cmd>lua vim.cmd("buffer " .. vim.fn.getbufinfo({buflisted=1})[1].bufnr)<CR>', opts)
      map('n', '<A-2>', '<cmd>lua vim.cmd("buffer " .. vim.fn.getbufinfo({buflisted=1})[2].bufnr)<CR>', opts)
      map('n', '<A-3>', '<cmd>lua vim.cmd("buffer " .. vim.fn.getbufinfo({buflisted=1})[3].bufnr)<CR>', opts)
      map('n', '<A-4>', '<cmd>lua vim.cmd("buffer " .. vim.fn.getbufinfo({buflisted=1})[4].bufnr)<CR>', opts)
      map('n', '<A-5>', '<cmd>lua vim.cmd("buffer " .. vim.fn.getbufinfo({buflisted=1})[5].bufnr)<CR>', opts)
      map('n', '<A-6>', '<cmd>lua vim.cmd("buffer " .. vim.fn.getbufinfo({buflisted=1})[6].bufnr)<CR>', opts)
      map('n', '<A-7>', '<cmd>lua vim.cmd("buffer " .. vim.fn.getbufinfo({buflisted=1})[7].bufnr)<CR>', opts)
      map('n', '<A-8>', '<cmd>lua vim.cmd("buffer " .. vim.fn.getbufinfo({buflisted=1})[8].bufnr)<CR>', opts)
      map('n', '<A-9>', '<cmd>lua vim.cmd("buffer " .. vim.fn.getbufinfo({buflisted=1})[9].bufnr)<CR>', opts)
      
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

      -- Custom motion remaps
      map({'n', 'v', 'o'}, 'B', '^', opts)  -- B to start of first char
      map({'n', 'v', 'o'}, 'E', '$', opts)  -- E to end of line

      -- AI/Copilot keybindings
      map('n', '<leader>ai', ':CopilotChatToggle<CR>', opts)  -- Toggle Copilot Chat
      map('v', '<leader>ae', ':CopilotChatExplain<CR>', opts) -- Explain selected code
      map('v', '<leader>ar', ':CopilotChatReview<CR>', opts)  -- Review selected code
      map('v', '<leader>af', ':CopilotChatFix<CR>', opts)     -- Fix selected code
      map('v', '<leader>ao', ':CopilotChatOptimize<CR>', opts) -- Optimize selected code
      map('v', '<leader>ad', ':CopilotChatDocs<CR>', opts)    -- Generate docs
      map('v', '<leader>at', ':CopilotChatTests<CR>', opts)   -- Generate tests
      map('n', '<leader>ac', ':CopilotChatCommit<CR>', opts)  -- Generate commit message

      -- Debugging (DAP) keybindings
      map('n', '<leader>db', '<cmd>lua require("dap").toggle_breakpoint()<CR>', opts)  -- Toggle breakpoint
      map('n', '<leader>dc', '<cmd>lua require("dap").continue()<CR>', opts)  -- Continue/Start debugging
      map('n', '<leader>di', '<cmd>lua require("dap").step_into()<CR>', opts)  -- Step into
      map('n', '<leader>do', '<cmd>lua require("dap").step_over()<CR>', opts)  -- Step over
      map('n', '<leader>dO', '<cmd>lua require("dap").step_out()<CR>', opts)  -- Step out
      map('n', '<leader>dr', '<cmd>lua require("dap").repl.toggle()<CR>', opts)  -- Toggle REPL
      map('n', '<leader>dl', '<cmd>lua require("dap").run_last()<CR>', opts)  -- Run last
      map('n', '<leader>dt', '<cmd>lua require("dapui").toggle()<CR>', opts)  -- Toggle DAP UI
      map('n', '<leader>dx', '<cmd>lua require("dap").terminate()<CR>', opts)  -- Terminate session

      -- Testing (Neotest) keybindings
      map('n', '<leader>tn', '<cmd>lua require("neotest").run.run()<CR>', opts)  -- Run nearest test
      map('n', '<leader>tf', '<cmd>lua require("neotest").run.run(vim.fn.expand("%"))<CR>', opts)  -- Run file
      map('n', '<leader>td', '<cmd>lua require("neotest").run.run({strategy = "dap"})<CR>', opts)  -- Debug nearest test
      map('n', '<leader>ts', '<cmd>lua require("neotest").summary.toggle()<CR>', opts)  -- Toggle summary
      map('n', '<leader>to', '<cmd>lua require("neotest").output.open({enter = true})<CR>', opts)  -- Open output
      map('n', '<leader>tS', '<cmd>lua require("neotest").run.stop()<CR>', opts)  -- Stop test
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
      -- Configure AI/LLM features
      require('config.plugins.ai')

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

      -- Configure formatting
      require('config.plugins.conform')

      -- Configure debugging
      require('config.plugins.dap')

      -- Configure testing
      require('config.plugins.neotest')
    '';
    
    # AI/LLM Configuration
    "nvim/lua/config/plugins/ai.lua".text = ''
      -- Configure GitHub Copilot
      require('copilot').setup({
        suggestion = {
          enabled = true,
          auto_trigger = true,
          debounce = 75,
          keymap = {
            accept = "<M-l>",      -- Alt+l to accept suggestion
            accept_word = "<M-w>", -- Alt+w to accept word
            accept_line = "<M-j>", -- Alt+j to accept line
            next = "<M-]>",        -- Alt+] for next suggestion
            prev = "<M-[>",        -- Alt+[ for previous suggestion
            dismiss = "<C-]>",     -- Ctrl+] to dismiss
          },
        },
        panel = {
          enabled = true,
          auto_refresh = false,
          keymap = {
            jump_prev = "[[",
            jump_next = "]]",
            accept = "<CR>",
            refresh = "gr",
            open = "<M-CR>"  -- Alt+Enter to open panel
          },
          layout = {
            position = "bottom",
            ratio = 0.4
          },
        },
        filetypes = {
          ["*"] = true,  -- Enable for all filetypes by default
          help = false,  -- Disable for help files
          gitrebase = false,
          hgcommit = false,
          svn = false,
          cvs = false,
        },
        copilot_node_command = 'node',
        server_opts_overrides = {},
      })

      -- Configure Copilot completion source
      require('copilot_cmp').setup()

      -- Configure CopilotChat
      require('CopilotChat').setup({
        debug = false,
        model = 'copilot:claude-sonnet-4.5',  -- Use Claude Sonnet 4.5
        temperature = 0.1,
        question_header = '## User ',
        answer_header = '## Copilot ',
        error_header = '## Error ',
        separator = ' ',
        show_folds = true,
        show_help = true,
        auto_follow_cursor = true,
        auto_insert_mode = false,
        clear_chat_on_new_prompt = false,
        context = 'buffers', -- Use 'buffers' or 'buffer'
        history_path = vim.fn.stdpath('data') .. '/copilotchat_history',
        callback = nil,
        selection = function(source)
          local select = require('CopilotChat.select')
          return select.visual(source) or select.buffer(source)
        end,
        prompts = {
          Explain = {
            prompt = '/COPILOT_EXPLAIN Write an explanation for the active selection as paragraphs of text.',
          },
          Review = {
            prompt = '/COPILOT_REVIEW Review the selected code.',
            callback = function(response, source)
              -- Custom callback for review
            end,
          },
          Fix = {
            prompt = '/COPILOT_FIX There is a problem in this code. Rewrite the code to show it with the bug fixed.',
          },
          Optimize = {
            prompt = '/COPILOT_REFACTOR Optimize the selected code to improve performance and readability.',
          },
          Docs = {
            prompt = '/COPILOT_DOCS Please add documentation comments to the selected code.',
          },
          Tests = {
            prompt = '/COPILOT_TESTS Please generate tests for my code.',
          },
          Commit = {
            prompt = 'Write commit message for the change with commitizen convention. Make sure the title has maximum 50 characters and message is wrapped at 72 characters. Wrap the whole message in code block with language gitcommit.',
          },
        },
        window = {
          layout = 'vertical',  -- 'vertical', 'horizontal', 'float'
          width = 0.4,
          height = 0.6,
          relative = 'editor',
          border = 'single',
          title = 'Copilot Chat',
          footer = nil,
          zindex = 1,
        },
        mappings = {
          complete = {
            detail = 'Use @<Tab> or /<Tab> for options.',
            insert ='<Tab>',
          },
          close = {
            normal = 'q',
            insert = '<C-c>'
          },
          reset = {
            normal ='<C-r>',
            insert = '<C-r>'
          },
          submit_prompt = {
            normal = '<CR>',
            insert = '<C-s>'
          },
          accept_diff = {
            normal = '<C-y>',
            insert = '<C-y>'
          },
          yank_diff = {
            normal = 'gy',
          },
          show_diff = {
            normal = 'gd'
          },
          show_system_prompt = {
            normal = 'gp'
          },
          show_user_selection = {
            normal = 'gs'
          },
        },
      })

      -- Configure render-markdown for better AI chat display
      require('render-markdown').setup({
        enabled = true,
        max_file_size = 1.5,
        log_level = 'error',
        file_types = { 'markdown', 'copilot-chat' },
        render_modes = { 'n', 'c' },
        anti_conceal = {
          enabled = true,
        },
        heading = {
          enabled = true,
          sign = true,
          icons = { '◉ ', '○ ', '✸ ', '✿ ' },
        },
        code = {
          enabled = true,
          sign = true,
          style = 'full',
          left_pad = 0,
          right_pad = 0,
          width = 'full',
          border = 'thin',
          highlight = 'RenderMarkdownCode',
        },
        bullet = {
          enabled = true,
          icons = { '●', '○', '◆', '◇' },
          right_pad = 0,
          highlight = 'RenderMarkdownBullet',
        },
      })
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
          -- Existing
          'lua_ls',
          'rust_analyzer',
          'pyright',
          'html',
          'cssls',
          'jsonls',
          'bashls',
          'marksman',
          -- C/C++
          'clangd',
          -- JavaScript/TypeScript
          'ts_ls',
          -- Zig
          'zls',
          -- Solidity
          'solidity',
          -- YAML
          'yamlls',
          -- Go
          'gopls',
          -- Ruby
          'ruby_lsp',
          -- XML
          'lemminx',
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
      
      -- Setup Nix language server separately
      require('lspconfig').nil_ls.setup({})
      
      -- Configure completion
      local cmp = require('cmp')
      local cmp_select = {behavior = cmp.SelectBehavior.Select}
      
      cmp.setup({
        sources = {
          {name = 'copilot', group_index = 2},
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
          -- Show buffer numbers (ordinal position) for Alt+number navigation
          numbers = function(opts)
            return string.format('%s', opts.ordinal)
          end,
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
        win = {
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
      }
    '';

    # Conform Configuration (Formatting)
    "nvim/lua/config/plugins/conform.lua".text = ''
      require('conform').setup({
        formatters_by_ft = {
          lua = { 'stylua' },
          python = { 'black', 'isort' },
          rust = { 'rustfmt' },
          javascript = { 'prettier' },
          typescript = { 'prettier' },
          javascriptreact = { 'prettier' },
          typescriptreact = { 'prettier' },
          json = { 'prettier' },
          yaml = { 'prettier' },
          markdown = { 'prettier' },
          html = { 'prettier' },
          css = { 'prettier' },
          go = { 'gofmt', 'goimports' },
          c = { 'clang-format' },
          cpp = { 'clang-format' },
          zig = { 'zigfmt' },
          solidity = { 'forge-fmt' },
          haskell = { 'ormolu' },
          ruby = { 'rubocop' },
          xml = { 'xmlformat' },
        },
        format_on_save = {
          timeout_ms = 500,
          lsp_fallback = true,
        },
      })
    '';

    # DAP Configuration (Debugging)
    "nvim/lua/config/plugins/dap.lua".text = ''
      local dap = require('dap')
      local dapui = require('dapui')

      -- Setup DAP UI
      dapui.setup({
        icons = { expanded = "▾", collapsed = "▸", current_frame = "▸" },
        mappings = {
          expand = { "<CR>", "<2-LeftMouse>" },
          open = "o",
          remove = "d",
          edit = "e",
          repl = "r",
          toggle = "t",
        },
        layouts = {
          {
            elements = {
              { id = "scopes", size = 0.25 },
              "breakpoints",
              "stacks",
              "watches",
            },
            size = 40,
            position = "left",
          },
          {
            elements = {
              "repl",
              "console",
            },
            size = 0.25,
            position = "bottom",
          },
        },
      })

      -- Setup virtual text
      require('nvim-dap-virtual-text').setup()

      -- Auto open/close DAP UI
      dap.listeners.after.event_initialized["dapui_config"] = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated["dapui_config"] = function()
        dapui.close()
      end
      dap.listeners.before.event_exited["dapui_config"] = function()
        dapui.close()
      end

      -- Python configuration
      require('dap-python').setup('python')

      -- Go configuration
      require('dap-go').setup()

      -- C/C++ configuration (via lldb)
      dap.adapters.lldb = {
        type = 'executable',
        command = 'lldb-vscode',
        name = 'lldb'
      }
      dap.configurations.cpp = {
        {
          name = 'Launch',
          type = 'lldb',
          request = 'launch',
          program = function()
            return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
          end,
          cwd = "''${workspaceFolder}",
          stopOnEntry = false,
          args = {},
        },
      }
      dap.configurations.c = dap.configurations.cpp
      dap.configurations.rust = dap.configurations.cpp
    '';

    # Neotest Configuration (Testing)
    "nvim/lua/config/plugins/neotest.lua".text = ''
      require('neotest').setup({
        adapters = {
          require('neotest-python')({
            dap = { justMyCode = false },
            runner = 'pytest',
            python = 'python',
            pytest_discover_instances = true,
          }),
          require('neotest-rust')({
            args = { '--no-capture' },
          }),
          require('neotest-go'),
          require('neotest-jest')({
            jestCommand = 'npm test --',
            env = { CI = true },
            cwd = function()
              return vim.fn.getcwd()
            end,
          }),
        },
        quickfix = {
          enabled = true,
          open = false,
        },
        status = {
          enabled = true,
          virtual_text = true,
          signs = true,
        },
        icons = {
          passed = "✓",
          running = "⟳",
          failed = "✗",
          skipped = "⊘",
          unknown = "?",
        },
      })
    '';
  };
}