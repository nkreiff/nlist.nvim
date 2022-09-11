local utils = require("nlist.utils")

local M = {}

local P = {
    ns = 0,
    nsName = "nList"
}

M.setup = function()
    P.ns = vim.api.nvim_create_namespace(P.nsName)
    vim.api.nvim_set_hl_ns(P.ns)
end

M.add = function(buf, group, line, col_start, col_end)
    vim.api.nvim_buf_add_highlight(buf, P.ns, group, line, col_start, col_end)
end

return M
