local ls = require("nlist.ls")
local utils = require("nlist.utils")
local Path = require("plenary.path")

local M = {}

local P = {
    show_hidden = true,
    positions = {},
    list = {}
}

P.get_selected_entry = function()
    local line, _ = unpack(vim.api.nvim_win_get_cursor(0))
    return P.list[line]
end

P.save_position = function()
    local pos = vim.api.nvim_win_get_cursor(0)
    P.positions[P.cwd:absolute()] = { pos[1], 0 }
end

P.restore_position = function()
    local pos = P.positions[P.cwd:absolute()]
    local lines = vim.api.nvim_buf_line_count(0)

    if pos and lines and pos[1] > lines then
        pos[1] = lines - 1
    end

    if pos then
        vim.api.nvim_win_set_cursor(0, pos)
    end
end

P.refresh = function()
    if not P.buf then return end

    -- Enable buffer modifiability
    vim.api.nvim_buf_set_option(P.buf, "modifiable", true)
    vim.api.nvim_buf_set_lines(P.buf, 0, -1, true, {})

    P.list = ls.ls(P.cwd, P.show_hidden)

    local list = {}
    for _, entry in pairs(P.list) do
        local str = "  " .. entry.info .. " " .. entry.icon.str .. " " .. entry.name

        if entry.link then
            str = str .. " -> " .. entry.link
        end
        table.insert(list, str)
    end

    vim.api.nvim_buf_set_lines(P.buf, 0, -1, true, list)

    local i = 0
    for _, entry in pairs(P.list) do
        vim.api.nvim_buf_add_highlight(P.buf, -1, "Comment", i, 2, #entry.info + 2)
        if entry.is_dir then
            vim.api.nvim_buf_add_highlight(P.buf, -1, "Function", i, #entry.info + 6, -1)
        end

        vim.api.nvim_buf_add_highlight(P.buf, -1, entry.icon.hl, i, #entry.info + 3, #entry.info + 6)

        i = i + 1
    end

    --vim.api.nvim_buf_set_name(P.buf, "[nList]" .. P.cwd:absolute())

    P.restore_position()

    -- Disable buffer modifiability
    vim.api.nvim_buf_set_option(P.buf, "modifiable", false)
end

M.open = function(cwd)
    local current_path = cwd or vim.api.nvim_buf_get_name(0)

    if #current_path == 0 then
        current_path = vim.loop.cwd()
    end

    P.cwd = Path:new(current_path)

    if vim.fn.isdirectory(current_path) == 0 then
        P.cwd = P.cwd:parent()
    end

    P.buf = utils.get_or_create_buffer(P.buf or "nList")
    vim.api.nvim_buf_set_option(P.buf, "buftype", "nofile")

    P.refresh()
end

M.follow = function()
    P.save_position()

    local entry = P.get_selected_entry()

    if entry.is_dir and entry.name ~= "." then
        if entry.name == ".." then
            P.cwd = P.cwd:parent()
        else
            P.cwd = Path:new(entry.path)
        end

        P.refresh()
    elseif not entry.is_dir then
        utils.get_or_create_buffer(entry.path)
    end
end

M.parent = function()
    P.save_position()
    P.cwd = P.cwd:parent()
    P.refresh()
end

M.toggle_hidden = function()
    P.show_hidden = not P.show_hidden
    P.refresh()
end

M.create_file = function()
    vim.ui.input({ prompt = "Create file: " }, function(input)
        if input and #input > 0 then
            local file_path = P.cwd .. Path.path.sep .. input
            utils.get_or_create_buffer(file_path)
        end
    end)
end

M.create_dir = function()
    vim.ui.input({ prompt = "Create directory: " }, function(input)
        if input and #input > 0 then
            local dir_path = P.cwd .. Path.path.sep .. input
            Path:new(dir_path):mkdir()
            P.refresh()
        end
    end)
end

M.rename = function()
    local entry = P.get_selected_entry()
    vim.ui.input({ prompt = "Renaming: ", default = entry.path }, function(input)
        if input and input ~= entry.path then
            P.save_position()
            Path:new(entry.path):rename({ new_name = input })
            P.refresh()
        end
    end)
end

M.remove = function()
    local entry = P.get_selected_entry()
    vim.ui.input({ prompt = "Are you sure you want to remove " .. entry.path .. ": (y)es/(N)o/(r)ecursive " },
        function(input)
            local opts = {}

            if input == "r" then
                opts.recursive = true
                input = "y"
            end

            if input == "y" then
                Path:new(entry.path):rm(opts)
                P.refresh()
            end
        end)
end

return M
