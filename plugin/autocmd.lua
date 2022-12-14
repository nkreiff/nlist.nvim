local mappings = require("nlist.mappings")

local nlist_augroup = vim.api.nvim_create_augroup("nList", { clear = true })

vim.api.nvim_create_autocmd("BufEnter", {
    group = nlist_augroup,
    pattern = "nList",
    callback = function()
        local buf = vim.api.nvim_get_current_buf()
        mappings.install_mappings(buf)
    end
})
