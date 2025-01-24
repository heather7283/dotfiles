local builtin = require("telescope.builtin")
local pickers = require('telescope.pickers')
local finders = require('telescope.finders')
local conf = require('telescope.config').values

local function is_under_config()
    local cwd = vim.fn.getcwd()
    local config_path = vim.fn.expand('~/.config')
    return vim.startswith(cwd, config_path)
end

local options = {
    defaults = {
        -- people who use rounded borders should be shot on sight without any investigation
        borderchars = { "─", "│", "─", "│", "┌", "┐", "┘", "└" },
        mappings = {
            i = {
                ["<C-j>"] = "move_selection_next",
                ["<C-k>"] = "move_selection_previous",
            }
        },
        vimgrep_arguments = {
            "rg",
            "--color=never",
            "--no-heading",
            "--with-filename",
            "--line-number",
            "--column",
            "--smart-case",
            (is_under_config() and "--no-ignore-vcs")
        },
        layout_strategy = 'flex',
        layout_config = {
            flip_columns = 213, -- full width terminal window on my monitor
            preview_cutoff = 0,
        },
    },
}
require("telescope").setup(options)

local find_files_options = { no_ignore = is_under_config() }
vim.keymap.set("n", "<leader>ff", function()
    builtin.find_files(find_files_options)
end)

vim.keymap.set("n", "<leader>fg", builtin.live_grep)

vim.keymap.set("n", "<leader>fh", builtin.help_tags)

vim.keymap.set("n", "<leader>fb", function()
    builtin.buffers({
        initial_mode = "normal",
    })
end)

vim.keymap.set("n", "<leader>fj", function()
    builtin.jumplist({
        initial_mode = "normal",
        trim_text = true,
    })
end)

vim.keymap.set('n', '<leader>fw', function()
    local word = vim.fn.expand('<cword>')
    builtin.current_buffer_fuzzy_find({
        initial_mode = "normal",
        default_text = word,
    })
end)

vim.keymap.set('n', '<leader>fr', function()
    builtin.lsp_references({
        initial_mode = "normal",
        include_declaration = true,
        include_current_line = true,
        trim_text = true,
    })
end)

vim.keymap.set('n', '<leader>fd', function()
    builtin.diagnostics({
        initial_mode = "normal",
        no_unlisted = true,
    })
end)

-- https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#symbolKind
SymbolKind = {
	File = 1,
	Module = 2,
	Namespace = 3,
	Package = 4,
	Class = 5,
	Method = 6,
	Property = 7,
	Field = 8,
	Constructor = 9,
	Enum = 10,
	Interface = 11,
	Function = 12,
	Variable = 13,
	Constant = 14,
	String = 15,
	Number = 16,
	Boolean = 17,
	Array = 18,
	Object = 19,
	Key = 20,
	Null = 21,
	EnumMember = 22,
	Struct = 23,
	Event = 24,
	Operator = 25,
	TypeParameter = 26,
}

local function get_key_by_value(tbl, value)
    for key, val in pairs(tbl) do
        if val == value then
            return key
        end
    end
    return nil
end

local function find_symbols()
  local params = { textDocument = vim.lsp.util.make_text_document_params() }
  -- https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#textDocument_documentSymbol
  vim.lsp.buf_request(0, 'textDocument/documentSymbol', params, function(err, result, ctx)
    if err or not result then
      vim.notify('No symbols found', vim.log.levels.WARN)
      return
    end

    -- Filter to get only function symbols
    local functions = {}
    for _, symbol in ipairs(result) do
      if symbol.kind == SymbolKind.Function
      or symbol.kind == SymbolKind.Method
      or symbol.kind == SymbolKind.Interface or true then
        table.insert(functions, symbol)
      end
    end

    -- Create Telescope picker
    pickers.new({}, {
      prompt_title = 'Function Definitions',
      finder = finders.new_table({
        results = functions,
        entry_maker = function(entry)
          return {
            value = entry,
            ordinal = entry.name,
            display = string.format("%d: %s (%s)", entry.range.start.line + 1, entry.name,
                                    get_key_by_value(SymbolKind, entry.kind)),
            lnum = entry.range.start.line + 1,
            col = entry.range.start.character + 1,
            filename = vim.api.nvim_buf_get_name(0),
          }
        end,
      }),
      sorter = conf.generic_sorter({}),
      previewer = conf.grep_previewer({}),
    }):find()
  end)
end
vim.keymap.set("n", "<leader>fs", find_symbols)

