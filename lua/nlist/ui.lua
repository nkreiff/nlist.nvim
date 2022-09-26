local cmd = require("nlist.cmd")
local utils = require("nlist.utils")
local marks = require("nlist.mark")
local highlights = require("nlist.highlights")
local Path = require("plenary.path")

local M = {}

local P = {
    show_hidden = true,
    show_info = true,
    mark_char = ">",
    positions = {},
    list = {}
}

P.filename = function(file)
    return string.match(file, string.format(".*%s([^%s]*)$", Path.path.sep, Path.path.sep))
end

P.get_selected_entry = function()
    local line, _ = unpack(vim.api.nvim_win_get_cursor(0))
    return P.list[line]
end

P.save_position = function(delta)
    delta = delta or 0
    local pos = vim.api.nvim_win_get_cursor(0)
    P.positions[P.cwd:absolute()] = { pos[1] + delta, 0 }
end

P.restore_position = function()
    local pos = P.positions[P.cwd:absolute()]
    local lines = vim.api.nvim_buf_line_count(0)

    if pos and lines and pos[1] > lines then
        pos[1] = lines
    end

    if pos then
        vim.api.nvim_win_set_cursor(0, pos)
    end
end

P.entry_string = function(entry)
    local str = "  "

    if marks.is_marked(entry.path) then
        str = P.mark_char .. " "
    end

    if P.show_info then
        str = str .. entry.info .. " "
    end

    str = str .. entry.icon.str .. " " .. entry.name

    if entry.link then
        str = str .. " -> " .. entry.link
    end

    return str
end

P.refresh = function()
    if not P.buf then return end

    -- Enable buffer modifiability
    vim.api.nvim_buf_set_option(P.buf, "modifiable", true)
    vim.api.nvim_buf_set_lines(P.buf, 0, -1, true, {})

    P.list = cmd.ls(P.cwd, P.show_hidden)

    local list = {}
    local info_length = 0
    for _, entry in pairs(P.list) do
        local str = P.entry_string(entry)

        if P.show_info then
            info_length = #entry.info
        end

        table.insert(list, str)
    end

    vim.api.nvim_buf_set_lines(P.buf, 0, -1, true, list)

    local i = 0

    for _, entry in pairs(P.list) do
        highlights.add(P.buf, highlights.EntryInfo, i, 2, info_length + 2)
        if entry.is_dir then
            highlights.add(P.buf, highlights.Directory, i, info_length + 6, -1)
        end

        highlights.add(P.buf, entry.icon.hl, i, info_length + 3, info_length + 6)

        i = i + 1
    end

    --vim.api.nvim_buf_set_name(P.buf, "[nList]" .. P.cwd:absolute())

    P.restore_position()

    -- Disable buffer modifiability
    vim.api.nvim_buf_set_option(P.buf, "modifiable", false)
end

M.set_show_information = function(b)
    P.show_info = b
    P.refresh()
end

M.set_show_hidden_files = function(b)
    P.show_hidden = b
    P.refresh()
end

M.set_mark_character = function(c)
    if c and #c == 1 then
        P.mark_char = c
    else
        P.mark_char = "*"
    end
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

M.toggle_info = function()
    P.show_info = not P.show_info
    P.refresh()
end

M.toggle_mark = function()
    P.save_position(1)

    local entry = P.get_selected_entry()
    marks.toggle_path(entry.path)

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

M.paste_marked_files = function()
    P.save_position()

    local marked_files = marks.get_marked_files()
    for _, marked_file in ipairs(marked_files) do
        local marked_path = Path:new(marked_file)

        if marked_path:exists() then
            local filename = P.filename(marked_file)
            local destination = P.cwd:joinpath(filename)

            marked_path:copy({
                recursive = true,
                interactive = true,
                destination = destination,
            })
        end
    end

    marks.clear()
    P.refresh()
end

M.move_marked_files = function()
    P.save_position()

    local marked_files = marks.get_marked_files()
    for _, marked_file in ipairs(marked_files) do
        if #marked_file > 0 then
            local marked_path = Path:new(marked_file)

            if marked_path:exists() then
                local filename = P.filename(marked_file)
                local destination = P.cwd:joinpath(filename)

                cmd.mv(marked_path:absolute(), destination:absolute())
            end
        end
    end

    marks.clear()
    P.refresh()
end

M.custom_cmd = function(custom_cmd)
    return function()
        local entry = P.get_selected_entry()

        local final_args = {}
        for _, arg in ipairs(custom_cmd.args) do
            local final_arg = arg:gsub("%%entry", entry.name)
            table.insert(final_args, final_arg)
        end

        local exit, _, stderr = cmd.cmd(custom_cmd.command, final_args, P.cwd:absolute())

        if exit ~= 0 then
            error(stderr)
        end

        P.save_position()
        P.refresh()
    end
end

return M
