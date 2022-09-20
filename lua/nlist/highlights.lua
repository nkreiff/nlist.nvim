local M = {
    EntryInfo = "nListEntryInfo",
    Directory = "nListDirectory",
    MarkedEntry = "nListMarkedEntry"
}

local P = {
    ns = 0,
    nsName = "nList",
    match_ids = {}
}

M.setup = function()
    P.ns = vim.api.nvim_create_namespace(P.nsName)
    vim.api.nvim_set_hl_ns(P.ns)

    local styles = {
        { name = M.EntryInfo, value = { default = true, link = "Comment" } },
        { name = M.Directory, value = { default = true, link = "Function" } },
        { name = M.MarkedEntry, value = { default = true, link = "String" } }
    }

    for _, style in pairs(styles) do
        vim.api.nvim_set_hl(P.ns, style.name, style.value)
    end

    table.insert(P.match_ids, vim.fn.matchadd(M.MarkedEntry, "^[^\\s]\\s"))
end

M.add = function(buf, group, line, col_start, col_end)
    vim.api.nvim_buf_add_highlight(buf, P.ns, group, line, col_start, col_end)
end

M.clear = function(buf)
    vim.api.nvim_buf_clear_namespace(buf, P.ns, 0, -1)

    for _, id in pairs(P.match_ids) do
        vim.fn.matchdelete(id)
    end
    P.match_ids = {}
end

return M
