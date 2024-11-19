-- Initialize history state
local M = {}

M.man_history = {}
M.man_history_position = 0

function M.get_pattern_position(word)
  -- Get cursor position
  local cursor_pos = vim.api.nvim_win_get_cursor(0)
  local line = cursor_pos[1]
  local col = cursor_pos[2]

  -- Find all matches in buffer
  local matches = {}
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)

  for i, line_content in ipairs(lines) do
    local start = 1
    while true do
      local match_start, match_end = line_content:find(word, start, true)
      if not match_start then break end
      table.insert(matches, {line = i, col = match_start})
      start = match_end + 1
    end
  end

  -- Find which match number corresponds to cursor position
  local current_match = 0
  for i, match in ipairs(matches) do
    if match.line == line and match.col <= col + 1 then
      current_match = i
    end
  end

  return current_match, #matches
end

function M.jump_to_nth_pattern(pattern, n)
    local matches = {}
    local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)

    -- Collect all matches
    for i, line_content in ipairs(lines) do
        local start = 1
        while true do
            local match_start, match_end = line_content:find(pattern, start, true)
            if not match_start then break end
            table.insert(matches, {line = i, col = match_start})
            start = match_end + 1
        end
    end

    -- Jump to nth match if it exists
    if matches[n] then
        vim.api.nvim_win_set_cursor(0, {matches[n].line, matches[n].col - 1})
        return true
    end

    return false
end

function M.print_history()
    vim.notify(vim.inspect(vim.tbl_extend('error', {pos = M.man_history_position}, M.man_history)), vim.log.levels.INFO)
end

-- Add new entry to history
function M.push(entry)
    -- Remove any entries after current position
    for i = #M.man_history, M.man_history_position + 1, -1 do
        table.remove(M.man_history, i)
    end

    -- Add new entry and update position
    table.insert(M.man_history, entry)
    M.man_history_position = #M.man_history
end

-- Move to previous entry
function M.prev()
    if M.man_history_position > 1 then
        local prev_name = M.man_history[M.man_history_position].name
        local prev_index = M.man_history[M.man_history_position].index
        M.man_history_position = M.man_history_position - 1
        local name = M.man_history[M.man_history_position].name
        M.open_page_by_name(name)
        M.jump_to_nth_pattern(prev_name, prev_index)
    else
        vim.notify("Last page in history", vim.log.levels.WARN)
        vim.defer_fn(function() vim.cmd('echo ""') end, 2000)
    end
end

-- Move to next entry
function M.next()
    if M.man_history_position < #M.man_history then
        local prev_name = M.man_history[M.man_history_position].name
        local prev_index = M.man_history[M.man_history_position].index
        M.man_history_position = M.man_history_position + 1
        local name = M.man_history[M.man_history_position].name
        M.open_page_by_name(name)
        -- M.jump_to_nth_pattern(prev_name, prev_index)
    else
        vim.notify("No next page in history", vim.log.levels.WARN)
        vim.defer_fn(function() vim.cmd('echo ""') end, 2000)
    end
end

function M.open_page_under_cursor()
    local cword = vim.fn.expand('<cword>')
    local section = cword:match('%((%d+)%)')
    local page = cword:match('([^(]+)')
    local page_name = section and
        (page .. '(' .. section .. ')') or
        cword

    local entry = {
        name = page_name,
        index = M.get_pattern_position(page_name)
    }
    if M.open_page_by_name(page_name) == nil then
        M.push(entry)
    end
end

function M.open_page_by_name(name)
    local status, error = pcall(function() vim.cmd('Man ' .. name) end)
    if error ~= nil then
        vim.notify('Man page not found: ' .. name, vim.log.levels.WARN)
        vim.defer_fn(function() vim.cmd('echo ""') end, 2000)
        return error
    end
    return nil
end

return M
