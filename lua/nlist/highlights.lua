local M = {
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

    vim.api.nvim_set_hl(P.ns, M.MarkedEntry, { bg = "#FF0000", ctermbg = "red" })
    table.insert(P.match_ids, vim.fn.matchadd(M.MarkedEntry, "^%*%s.*"))
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
