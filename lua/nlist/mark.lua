local popup = require("plenary.popup")
local Path = require("plenary.path")

local data_path = vim.fn.stdpath("data")
local marks_path = string.format("%s/nlist_marks.txt", data_path)

local M = {}

local P = {
    win = nil,
    buf = nil,
}

P.create_window = function()
    local width = 80
    local height = 16
    local borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" }

    local buf = vim.api.nvim_create_buf(false, false)

    local nlist_win_id, win = popup.create(buf, {
        title = "Marked Files",
        highlight = "nListWindow",
        line = math.floor(((vim.o.lines - height) / 2) - 1),
        col = math.floor((vim.o.columns - width) / 2),
        minwidth = width,
        minheight = height,
        borderchars = borderchars,
    })

    vim.api.nvim_win_set_option(
        win.border.win_id,
        "winhl",
        "Normal:nListBorder"
    )

    return {
        win = nlist_win_id,
        buf = buf,
    }
end

M.toggle_window = function()
    if P.win then
        M.close_window()
        return
    end

    local win_info = P.create_window()

    vim.api.nvim_win_set_option(win_info.win, "number", true)

    local marks = M.get_marked_files()

    vim.api.nvim_buf_set_lines(win_info.buf, 0, #marks, false, marks)
    vim.api.nvim_buf_set_name(win_info.buf, marks_path)
    vim.api.nvim_buf_set_option(win_info.buf, "filetype", "nlist")
    vim.api.nvim_buf_set_option(win_info.buf, "buftype", "acwrite")
    vim.api.nvim_buf_set_option(win_info.buf, "bufhidden", "delete")

    vim.api.nvim_buf_set_keymap(win_info.buf, "n", "q", "<Cmd>lua require('nlist.mark').toggle_window()<CR>", {
        silent = true
    })
    vim.api.nvim_buf_set_keymap(win_info.buf, "n", "<ESC>", "<Cmd>lua require('nlist.mark').toggle_window()<CR>", {
        silent = true
    })

    vim.cmd(string.format(
        "autocmd BufWriteCmd <buffer=%s> lua require('nlist.mark').save_buffer()",
        win_info.buf
    ))
    vim.cmd(string.format(
        "autocmd BufModifiedSet <buffer=%s> set nomodified",
        win_info.buf
    ))

    vim.cmd(
        "autocmd BufLeave <buffer> ++nested ++once silent lua require('nlist.mark').toggle_window()"
    )

    P.win = win_info.win
    P.buf = win_info.buf
end

M.close_window = function()
    if not P.win then return end

    vim.api.nvim_win_close(P.win, true)

    P.win = nil
    P.buf = nil
end

M.get_marked_files = function()
    local marks = {}
    local p = Path:new(marks_path)

    if p:exists() then
        marks = p:readlines()
    end

    return marks
end

M.is_marked = function(path)
    local marks = M.get_marked_files()

    for _, mark in ipairs(marks) do
        if mark == path then
            return true
        end
    end

    return false
end

M.toggle_path = function(path)
    local marks = M.get_marked_files()

    local removeIndex = -1
    for i, mark in ipairs(marks) do
        if mark == path then
            removeIndex = i
            break
        end
    end

    if removeIndex > 0 then
        table.remove(marks, removeIndex)
    else
        table.insert(marks, path)
    end

    Path:new(marks_path):write(table.concat(marks, "\n"), "w")
end

M.save_buffer = function()
    local marks = vim.api.nvim_buf_get_lines(P.buf, 0, -1, true)
    Path:new(marks_path):write(table.concat(marks, "\n"), "w")
end

M.clear = function()
    Path:new(marks_path):write("", "w")
end

return M
