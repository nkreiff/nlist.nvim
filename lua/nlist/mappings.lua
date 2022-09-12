local actions_mark = require("nlist.mark")
local actions_ui = require("nlist.ui")

local M = {}

local default_mappings = {
    list = {
        ["l"] = actions_ui.follow,
        ["h"] = actions_ui.parent,
        ["f"] = actions_ui.create_file,
        ["d"] = actions_ui.create_dir,
        ["x"] = actions_ui.remove,
        ["r"] = actions_ui.rename,
        ["."] = actions_ui.toggle_hidden,
        ["i"] = actions_ui.toggle_info,
        ["m"] = actions_ui.mark_file,
        ["t"] = actions_mark.toggle_window,
        ["p"] = actions_ui.paste_marked_files,
    }
}

local custom_mappings = {}

M.set_list_mappings = function(buf)
    for key_bind, key_func in pairs(default_mappings.list) do
        vim.keymap.set("n", key_bind, key_func, { buffer = buf --[[silent = true]] })
    end
end

return M
