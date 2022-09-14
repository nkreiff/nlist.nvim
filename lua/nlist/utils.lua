local popup = require("plenary.popup")

local M = {}

local get_devicons = function()
    local has_devicons, devicons = pcall(require, "nvim-web-devicons")

    if not has_devicons then return nil end
    if not devicons.has_loaded() then devicons.setup() end

    return devicons
end

M.merge_tables = function(t1, t2)
    local merged_table = {}

    t1 = t1 or {}
    t2 = t2 or {}

    for k, v2 in pairs(t2) do
        local v1 = t1[k]

        if type(v2) == "table" then
            if type(v1) == "table" then
                merged_table[k] = M.merge_tables(v1, v2)
            else
                merged_table[k] = v2
            end
        elseif v2 ~= nil then
            merged_table[k] = v2
        else
            merged_table[k] = v1
        end
    end

    for k, v1 in pairs(t1) do
        local v2 = t2[k]

        if v2 == nil then
            merged_table[k] = v1
        end
    end

    return merged_table
end

M.get_or_create_buffer = function(filename)
    local buf_id = nil
    local buf_exists = vim.fn.bufexists(filename) ~= 0

    if buf_exists then
        buf_id = vim.fn.bufnr(filename)
    else
        buf_id = vim.fn.bufadd(filename)
    end

    vim.api.nvim_set_current_buf(buf_id)
    vim.api.nvim_buf_set_option(buf_id, "buflisted", true)

    return buf_id
end

M.string_to_array = function(str)
    local i = 1
    local lines = {}

    for l in str:gmatch("[^\r\n]+") do
        lines[i] = l
        i = i + 1
    end

    return lines
end

M.get_icon = function(filename)
    local devicons = get_devicons()
    if not devicons then return "", "#000000" end

    local fileext = filename:match("%.(.*)$")

    local icon, hl_group = devicons.get_icon(filename, fileext, { default = true })

    return icon, hl_group
end

M.get_icons = function()
    local devicons = get_devicons()
    if not devicons then return "", "#000000" end

    return devicons.get_icons()
end

return M
