local mappings = require("nlist.mappings")
local utils = require("nlist.utils")
local ui = require("nlist.ui")

local M = {}

local default_config = {
    hijack_netrw_enabled = true,
    show_information = true,
    show_hidden_files = true,
}

local hijack_netrw = function()
    vim.g.loaded_netrw = 1
    vim.g.loaded_netrwPlugin = 1

    local netrw_bufname
    vim.api.nvim_create_augroup("FileExplorer", { clear = true })
    vim.api.nvim_create_autocmd("BufEnter", {
        group = "FileExplorer",
        pattern = "*",
        callback = function()
            vim.schedule(function()
                local bufname = vim.api.nvim_buf_get_name(0)
                if vim.fn.isdirectory(bufname) == 0 then
                    netrw_bufname = vim.fn.expand "#:p:h"
                    return
                end

                -- prevents reopening of file-browser if exiting without selecting a file
                if netrw_bufname == bufname then
                    netrw_bufname = nil
                    return
                else
                    netrw_bufname = bufname
                end

                -- ensure no buffers remain with the directory name
                vim.api.nvim_buf_set_option(0, "bufhidden", "wipe")

                require("nlist.ui").open(vim.fn.expand("%:p:h"))
            end)
        end,
        desc = "Telescope file-browser replacement for netrw",
    })
end

M.setup = function(config)
    config = utils.merge_tables(default_config, config)

    if config.hijack_netrw_enabled then
        hijack_netrw()
    end

    mappings.set_custom_mappings(config.custom_mappings)
    mappings.install_global_mappings()

    ui.set_show_information(config.show_information)
    ui.set_show_hidden_files(config.show_hidden_files)
end

return M
