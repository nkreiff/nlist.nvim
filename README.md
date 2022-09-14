<div align="center">

# nList.nvim
emacs dired inspired file manager for neovim

[![Lua](https://img.shields.io/badge/Lua-blue.svg?style=for-the-badge&logo=lua)](http://www.lua.org)
[![Neovim](https://img.shields.io/badge/Neovim%200.5+-green.svg?style=for-the-badge&logo=neovim)](https://neovim.io)
</div>

## ⇨ WIP
This plugin was created primarily for personal use and is constantly being updated. If you decide to give it a try and experience any issues or see any improvements that you think would be awesome, or just have any feedback, please create an issue!

## ⇨ Why another file manager?
Before coming to Neovim I was working daily for more than a year on *eMacs*. One of the packages I personally value most from eMacs is *Dired*, a super snappy, fast, easy-to-use, full-featured file manager.

In my transition to *nvim* I found myself very comfortable in general, but missing *Dired* a lot in my day to day life.

That's why I decide to write my own plugin inspired by this wonderful package of *eMacs*.

## ⇨ Installation

This plugin requires `Neovim 0.5.0+`

Install using your favorite plugin manager:
- Using `vim-plug`
```vim
Plug 'nvim-lua/plenary.nvim' " don't forget to add this one if you don't have it yet!
Plug 'nkreiff/nlist.nvim'
```
- Using `packer.nvim`
```lua
use 'nvim-lua/plenary.nvim' -- don't forget to add this one if you don't have it yet!
use 'nkreiff/nlist.nvim'
```

## ⇨ Default Bindings

This plugin automatically configures itself with a set of default key bindings. The default bindings are listed and described below:

| Binding Name       | Key Mapping | Description                                                        |
|--------------------|-------------|--------------------------------------------------------------------|
| open_ui            | <leader>l   | Open UI                                                            |
| follow             | l           | Visit current file or directory                                    |
| parent             | h           | Move to parent directory                                           |
| create_file        | f           | Create a new file                                                  |
| create_dir         | d           | Create a new subdirectory                                          |
| remove             | x           | Delete file or directory                                           |
| rename             | r           | Rename file or directory                                           |
| toggle_hidden      | .           | Toggle hidden files                                                |
| toggle_info        | i           | Toggle information                                                 |
| toggle_mark        | m           | Mark a file or directory for later commands                        |
| toggle_mark_win    | t           | Toggle marks window                                                |
| paste_marked_files | p           | Paste marked files or directories to the current working directory |
| move_marked_files  | P           | Move marked files or directories to the current working directory  |

## ⇨ Setup

```lua
require('nlist').setup({
    show_information = true,
    show_hidden_files = true,
    hijack_netrw_enabled = true,
    
    custom_mappings = {
        -- Binding Name = "new mapping"
        -- open_ui = "<leader>d"
        -- parent = "<BS>"
    }
})
```

