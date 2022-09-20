local actions_mark = require("nlist.mark")
local actions_ui = require("nlist.ui")
local utils = require("nlist.utils")

local M = {}

local default_mappings = {
    open_ui = "<leader>l",
    follow = "l",
    parent = "h",
    create_file = "f",
    create_dir = "d",
    remove = "x",
    rename = "r",
    toggle_hidden = ".",
    toggle_info = "i",
    toggle_mark = "m",
    toggle_mark_win = "t",
    paste_marked_files = "p",
    move_marked_files = "P"
}

local custom_mappings = default_mappings
local custom_commands = {}

M.set_custom_mappings = function(mappings)
    custom_mappings = utils.merge_tables(custom_mappings, mappings)
end

M.set_custom_commands = function(commands)
    custom_commands = commands
end

M.install_global_mappings = function()
    vim.keymap.set("n", custom_mappings.open_ui, actions_ui.open)
end

M.install_mappings = function(buf)
    vim.keymap.set("n", custom_mappings.follow, actions_ui.follow, { buffer = buf })
    vim.keymap.set("n", custom_mappings.parent, actions_ui.parent, { buffer = buf })
    vim.keymap.set("n", custom_mappings.create_file, actions_ui.create_file, { buffer = buf })
    vim.keymap.set("n", custom_mappings.create_dir, actions_ui.create_dir, { buffer = buf })
    vim.keymap.set("n", custom_mappings.remove, actions_ui.remove, { buffer = buf })
    vim.keymap.set("n", custom_mappings.rename, actions_ui.rename, { buffer = buf })
    vim.keymap.set("n", custom_mappings.toggle_hidden, actions_ui.toggle_hidden, { buffer = buf })
    vim.keymap.set("n", custom_mappings.toggle_info, actions_ui.toggle_info, { buffer = buf })
    vim.keymap.set("n", custom_mappings.toggle_mark, actions_ui.toggle_mark, { buffer = buf })
    vim.keymap.set("n", custom_mappings.toggle_mark_win, actions_mark.toggle_window, { buffer = buf })
    vim.keymap.set("n", custom_mappings.paste_marked_files, actions_ui.paste_marked_files, { buffer = buf })
    vim.keymap.set("n", custom_mappings.move_marked_files, actions_ui.move_marked_files, { buffer = buf })

    for _, custom_cmd in ipairs(custom_commands) do
        vim.keymap.set("n", custom_cmd.binding, actions_ui.custom_cmd(custom_cmd), { buffer = buf })
    end
end

return M
