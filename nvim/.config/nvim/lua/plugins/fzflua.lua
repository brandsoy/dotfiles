return {
  'ibhagwan/fzf-lua',
  -- optional for icon support
  -- dependencies = { "nvim-tree/nvim-web-devicons" },
  -- or if using mini.icons/mini.nvim
  dependencies = { 'echasnovski/mini.icons' },
  winopts = {
    -- split = "belowright new",-- open in a split instead?
    -- "belowright new"  : split below
    -- "aboveleft new"   : split above
    -- "belowright vnew" : split right
    -- "aboveleft vnew   : split left
    -- Only valid when using a float window
    -- (i.e. when 'split' is not defined, default)
    height = 0.85, -- window height
    width = 0.80, -- window width
    row = 0.35, -- window row position (0=top, 1=bottom)
    col = 0.50, -- window col position (0=left, 1=right)
    -- border argument passthrough to nvim_open_win()
    border = 'rounded',
    -- Backdrop opacity, 0 is fully opaque, 100 is fully transparent (i.e. disabled)
    backdrop = 60,
    -- title         = "Title",
    -- title_pos     = "center",        -- 'left', 'center' or 'right'
    -- title_flags   = false,           -- uncomment to disable title flags
    fullscreen = false, -- start fullscreen?
    -- enable treesitter highlighting for the main fzf window will only have
    -- effect where grep like results are present, i.e. "file:line:col:text"
    -- due to highlight color collisions will also override `fzf_colors`
    -- set `fzf_colors=false` or `fzf_colors.hl=...` to override
    treesitter = {
      enabled = true,
      fzf_colors = { ['hl'] = '-1:reverse', ['hl+'] = '-1:reverse' },
    },
    preview = {
      -- default     = 'bat',           -- override the default previewer?
      -- default uses the 'builtin' previewer
      border = 'rounded', -- preview border: accepts both `nvim_open_win`
      -- and fzf values (e.g. "border-top", "none")
      -- native fzf previewers (bat/cat/git/etc)
      -- can also be set to `fun(winopts, metadata)`
      wrap = false, -- preview line wrap (fzf's 'wrap|nowrap')
      hidden = false, -- start preview hidden
      vertical = 'down:45%', -- up|down:size
      horizontal = 'right:60%', -- right|left:size
      layout = 'flex', -- horizontal|vertical|flex
      flip_columns = 100, -- #cols to switch to horizontal on flex
      -- Only used with the builtin previewer:
      title = true, -- preview border title (file/buf)?
      title_pos = 'center', -- left|center|right, title alignment
      scrollbar = 'float', -- `false` or string:'float|border'
      -- float:  in-window floating border
      -- border: in-border "block" marker
      scrolloff = -1, -- float scrollbar offset from right
      -- applies only when scrollbar = 'float'
      delay = 20, -- delay(ms) displaying the preview
      -- prevents lag on fast scrolling
      winopts = { -- builtin previewer window options
        number = true,
        relativenumber = false,
        cursorline = true,
        cursorlineopt = 'both',
        cursorcolumn = false,
        signcolumn = 'no',
        list = false,
        foldenable = false,
        foldmethod = 'manual',
      },
    },
    on_create = function()
      -- called once upon creation of the fzf main window
      -- can be used to add custom fzf-lua mappings, e.g:
      --   vim.keymap.set("t", "<C-j>", "<Down>", { silent = true, buffer = true })
    end,
    -- called once _after_ the fzf interface is closed
    -- on_close = function() ... end
  },
  previewers = {
    cat = {
      cmd = 'cat',
      args = '-n',
    },
    bat = {
      cmd = 'bat',
      args = '--color=always --style=numbers,changes',
    },
    head = {
      cmd = 'head',
      args = nil,
    },
    git_diff = {
      -- if required, use `{file}` for argument positioning
      -- e.g. `cmd_modified = "git diff --color HEAD {file} | cut -c -30"`
      cmd_deleted = 'git diff --color HEAD --',
      cmd_modified = 'git diff --color HEAD',
      cmd_untracked = 'git diff --color --no-index /dev/null',
      -- git-delta is automatically detected as pager, set `pager=false`
      -- to disable, can also be set under 'git.status.preview_pager'
    },
    man = {
      -- NOTE: remove the `-c` flag when using man-db
      -- replace with `man -P cat %s | col -bx` on OSX
      cmd = 'man -c %s | col -bx',
    },
    builtin = {
      syntax = true, -- preview syntax highlight?
      syntax_limit_l = 0, -- syntax limit (lines), 0=nolimit
      syntax_limit_b = 1024 * 1024, -- syntax limit (bytes), 0=nolimit
      limit_b = 1024 * 1024 * 10, -- preview limit (bytes), 0=nolimit
      -- previewer treesitter options:
      -- enable specific filetypes with: `{ enabled = { "lua" } }
      -- exclude specific filetypes with: `{ disabled = { "lua" } }
      -- disable `nvim-treesitter-context` with `context = false`
      -- disable fully with: `treesitter = false` or `{ enabled = false }`
      treesitter = {
        enabled = true,
        disabled = {},
        -- nvim-treesitter-context config options
        context = { max_lines = 1, trim_scope = 'inner' },
      },
      -- By default, the main window dimensions are calculated as if the
      -- preview is visible, when hidden the main window will extend to
      -- full size. Set the below to "extend" to prevent the main window
      -- from being modified when toggling the preview.
      toggle_behavior = 'default',
      -- Title transform function, by default only displays the tail
      -- title_fnamemodify = function(s) vim.fn.fnamemodify(s, ":t") end,
      -- preview extensions using a custom shell command:
      -- for example, use `viu` for image previews
      -- will do nothing if `viu` isn't executable
      extensions = {
        -- neovim terminal only supports `viu` block output
        ['png'] = { 'viu', '-b' },
        -- by default the filename is added as last argument
        -- if required, use `{file}` for argument positioning
        ['svg'] = { 'chafa', '{file}' },
        ['jpg'] = { 'ueberzug' },
      },
      -- if using `ueberzug` in the above extensions map
      -- set the default image scaler, possible scalers:
      --   false (none), "crop", "distort", "fit_contain",
      --   "contain", "forced_cover", "cover"
      -- https://github.com/seebye/ueberzug
      ueberzug_scaler = 'cover',
      -- Custom filetype autocmds aren't triggered on
      -- the preview buffer, define them here instead
      -- ext_ft_override = { ["ksql"] = "sql", ... },
      -- render_markdown.nvim integration, enabled by default for markdown
      render_markdown = { enabled = true, filetypes = { ['markdown'] = true } },
    },
    -- Code Action previewers, default is "codeaction" (set via `lsp.code_actions.previewer`)
    -- "codeaction_native" uses fzf's native previewer, recommended when combined with git-delta
    codeaction = {
      -- options for vim.diff(): https://neovim.io/doc/user/lua.html#vim.diff()
      diff_opts = { ctxlen = 3 },
    },
    codeaction_native = {
      diff_opts = { ctxlen = 3 },
      -- git-delta is automatically detected as pager, set `pager=false`
      -- to disable, can also be set under 'lsp.code_actions.preview_pager'
      -- recommended styling for delta
      --pager = [[delta --width=$COLUMNS --hunk-header-style="omit" --file-style="omit"]],
    },
  },
  opts = {},
  keys = {
    {
      '<leader>ff',
      function()
        require('fzf-lua').files()
      end,
      desc = 'Find Files in project directory',
    },
    {
      '<leader>fg',
      function()
        require('fzf-lua').live_grep()
      end,
      desc = 'Find by grepping in project directory',
    },
    {
      '<leader>fc',
      function()
        require('fzf-lua').files { cwd = vim.fn.stdpath 'config' }
      end,
      desc = 'Find in neovim configuration',
    },
    {
      '<leader>fh',
      function()
        require('fzf-lua').helptags()
      end,
      desc = '[F]ind [H]elp',
    },
    {
      '<leader>fk',
      function()
        require('fzf-lua').keymaps()
      end,
      desc = '[F]ind [K]eymaps',
    },
    {
      '<leader>fb',
      function()
        require('fzf-lua').builtin()
      end,
      desc = '[F]ind [B]uiltin FZF',
    },
    {
      '<leader>fw',
      function()
        require('fzf-lua').grep_cword()
      end,
      desc = '[F]ind current [W]ord',
    },
    {
      '<leader>fW',
      function()
        require('fzf-lua').grep_cWORD()
      end,
      desc = '[F]ind current [W]ORD',
    },
    {
      '<leader>fd',
      function()
        require('fzf-lua').diagnostics_document()
      end,
      desc = '[F]ind [D]iagnostics',
    },
    {
      '<leader>fr',
      function()
        require('fzf-lua').resume()
      end,
      desc = '[F]ind [R]esume',
    },
    {
      '<leader>fo',
      function()
        require('fzf-lua').oldfiles()
      end,
      desc = '[F]ind [O]ld Files',
    },
    {
      '<leader><leader>',
      function()
        require('fzf-lua').buffers()
      end,
      desc = '[,] Find existing buffers',
    },
    {
      '<leader>/',
      function()
        require('fzf-lua').lgrep_curbuf()
      end,
      desc = '[/] Live grep the current buffer',
    },
  },
}
