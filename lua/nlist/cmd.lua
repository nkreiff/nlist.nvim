local utils = require("nlist.utils")
local ScanDir = require("plenary.scandir")
local Path = require("plenary.path")
local Job = require("plenary.job")

local M = {}

local P = {}

M.cmd = function(command, args, cwd)
    local stderr = {}
    local stdout, exit = Job:new({
        command = command,
        args = args,
        cwd = cwd,
        on_stderr = function(_, data)
            table.insert(stderr, data)
        end,
    }):sync()

    return exit, stdout, stderr
end

P.filter = function(list)
    local filteredList = {}
    for _, entry in pairs(list) do
        if string.sub(entry, 1, 5) ~= "total" then
            table.insert(filteredList, entry)
        end
    end
    return filteredList
end

P.sort = function(list)
    table.sort(list, function(a, b)
        if a.is_dir and b.is_dir then
            return a.name < b.name
        elseif not a.is_dir and not b.is_dir then
            return a.name < b.name
        elseif a.is_dir and not b.is_dir then
            return true
        elseif not a.is_dir and b.is_dir then
            return false
        end

        return false
    end)
    return list
end

P.map = function(list, base_path)
    local result = {}

    for _, entry in pairs(list) do
        local _, _, name = string.find(entry, ".*%S+%s+%d+:?%d+%s+(.*)$")
        local info = entry:sub(1, #entry - #name - 2)

        local link = nil
        if name:match(".*%s->%s.*") then
            local _, _, n, l = name:find("(.*)%s+->%s+(.*)")
            name, link = n, l
        end

        local path = base_path .. Path.path.sep .. name
        local is_dir = vim.fn.isdirectory(path) == 1
        local icon, icon_hl = utils.get_icon(name)

        if is_dir then
            icon, icon_hl = "▷", "Function"
        end

        table.insert(result, {
            name = name,
            link = link,
            info = info,
            path = path,
            is_dir = is_dir,
            icon = {
                str = icon or " ",
                hl = icon_hl
            }
        })
    end

    return result
end

M.mv = function(path1, path2)
    local exit, _, _ = M.cmd("mv", { path1, path2 })

    return exit
end

M.ls = function(dir, showHidden)
    local list = ScanDir.ls(dir:absolute(), {
        hidden = showHidden,
        add_dirs = true,
        depth = 1,
        group_directories_first = true,
    })

    return P.sort(P.map(list, dir))
end

return M
