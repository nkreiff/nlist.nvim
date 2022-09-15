local utils = require("nlist.utils")
local Path = require("plenary.path")
local Job = require("plenary.job")

local M = {}

local P = {}

P.cmd = function(command, args)
    local stderr = {}
    local stdout, exit = Job:new({
        command = command,
        args = args,
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

P.map = function(list, showHidden, base_path)
    local result = {}

    local info_length = 0
    for _, entry in pairs(list) do
        if entry:match(".*(%s%.)$") then
            info_length = #entry - 1
            break
        end
    end

    for _, entry in pairs(list) do
        local name = entry:sub(info_length + 1, -1)

        if showHidden or name:sub(1, 1) ~= "." then
            local link = nil
            if name:match(".*%s->%s.*") then
                link = name:match(".*%s->%s(.*)")
                name = name:match("^(.*)%s->%s.*")
            end

            local path = base_path .. Path.path.sep .. name
            local info = entry:sub(1, info_length - 1)
            local is_dir = vim.fn.isdirectory(path) == 1
            local icon, icon_hl = utils.get_icon(name)

            if is_dir then
                if name ~= "." and name ~= ".." then
                    icon, icon_hl = "▷", "Function"
                else
                    icon, icon_hl = " ", "Function"
                end
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
    end

    return result
end

M.ls = function(dir, showHidden)
    local params = "-lhaL"

    local exit, stdout, stderr = P.cmd("ls", { params, dir:absolute() })

    if exit ~= 0 then
        return stderr
    end

    return P.sort(P.map(P.filter(stdout), showHidden, dir))
end

M.mv = function(path1, path2)
    local exit, _, _ = P.cmd("mv", { path1, path2 })

    return exit
end

return M