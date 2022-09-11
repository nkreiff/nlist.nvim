local mappings = require("nlist.mappings")

local ngit_augroup = vim.api.nvim_create_augroup("nList", { clear = true })

vim.api.nvim_create_autocmd("BufEnter", {
    group = ngit_augroup,
    pattern = "nList",
    callback = function()
        local buf = vim.api.nvim_get_current_buf()
        mappings.set_list_mappings(buf)
    end
})
