# Buffon

![GitHub Workflow Status](http://img.shields.io/github/actions/workflow/status/francescarpi/buffon.nvim/default.yml?branch=main&style=for-the-badge)
![Lua](https://img.shields.io/badge/Made%20with%20Lua-blueviolet.svg?style=for-the-badge&logo=lua)

<div align="center">
    <img alt="buffon.nvim logo" height="200" src="./imgs/logo.png" />
</div>



*Buffon* is yet another plugin for navigating between buffers in [Neovim](https://neovim.io/). The name *Buffon* comes from the combination of *Buffer* and *Navigation*, creating the amusing word *buffon*, referencing the medieval jester who entertained the king.

This plugin is inspired by [harpoon](https://github.com/ThePrimeagen/harpoon) and [tide](https://github.com/jackMort/tide.nvim). Both are fantastic, but they didn't quite fit my workflow.

Things I like and dislike about these plugins:

**Harpoon**

| `Likes`               | `Dislikes` |
|----                  |----       |
| * Data persistence    | * Having to select which buffers to work with |
| * Buffers can be sorted | * Constantly having to open and close the window to see which buffers are selected, change the order, delete them, etc. |
| * Good API | |
| * Tests | |

**Tide**

| `Likes`               | `Dislikes` |
|----                  |----       |
| * Pleasant and beautiful interface | * Having to select which buffers to work with |
| * Shortcuts to access a buffer directly | * Buffers cannot be sorted |
| * Always having the buffer list visible | * No persistence |

Based on this, I created *Buffon* with the best of both plugins, perfectly adapting to my way of working.

## What Buffon offers

* Simple and minimalist interface
* Always visible interface
* Data persistence, storing the cursor position
* Works with **all** open buffers
* Buffers can be:
  * Sorted: Move one position up/down, send to the beginning or end of the list
  * Closed: You can close one buffer, all, those above, those below, or the "others"
  * Navigate between previous and next buffer
  * Access a specific buffer
  * Toggle between the last used buffer
  * Reopen closed buffer
  * Shows modified buffer indicator
  * Organize buffers into pages
* Help window to see the shortcuts

> [!NOTE]
> If you like all these features and the plugin also adapts to your needs, I would greatly appreciate it if you **click on the star**.

## Installation

> [!NOTE]
> require neovim 0.10.0+

### Using [lazy](https://github.com/folke/lazy.nvim):

```lua
return {
  {
    "francescarpi/buffon.nvim",
    opts = {
      --- Add your config here
    },
    dependencies = {
      "nvim-tree/nvim-web-devicons",
      "nvim-lua/plenary.nvim",
    },
  },
}
```

## Default Configuration

Below you can see the default configuration, which you can adjust to your liking in the setup. For example:

```lua
return {
  {
    "francescarpi/buffon.nvim",
    opts = {
      cyclic_navigation = true,
    },
    dependencies = {
      "nvim-tree/nvim-web-devicons",
      "nvim-lua/plenary.nvim",
    },
  },
}
```

Default configuration:

Take a look at the default shortcuts for navigating between buffers, changing their order, or closing them:


```lua
{
  cyclic_navigation = true,
  --- possible values:
  ---   "start": buffers are added at the begginning of the buffers list
  ---   "end": buffers are added at the end of the list
  ---   "after": are added after the active buffer
  new_buffer_position = "end",
  num_pages = 2,
  open = {
    by_default = true,
    ignore_ft = {
      "gitcommit",
      "gitrebase",
    },
  },
  keybindings = {
    goto_next_buffer = "<s-j>",
    goto_previous_buffer = "<s-k>",
    move_buffer_up = "<s-l>",
    move_buffer_down = "<s-h>",
    move_buffer_top = "<s-t>",
    move_buffer_bottom = "<s-b>",
    toggle_buffon_window = ";n",
    switch_previous_used_buffer = ";;",
    close_buffer = ";d",
    close_buffers_above = ";v",
    close_buffers_below = ";b",
    close_all_buffers = ";cc",
    close_others = ";cd",
    reopen_recent_closed_buffer = ";t",
    buffer_mapping = {
      mapping_chars = "qweryuiop",
      leader_key = ";",
    },
    show_help = ";h",
    previous_page = "<s-tab>",
    next_page = "<tab>",
    move_to_previous_page = ";a",
    move_to_next_page = ";s",
  },
}
```
> [!TIP]
> If you use `nvim-lspconfig`, the `s-k` shortcut (goto previous) may collide with the `lsp` one to view the documentation. In my case, I have this shortcut remapped to:
>
> ```lua
> vim.keymap.set("n", "c-l", vim.lsp.buf.hover)
> ````

## Screenshots

Buffon window, showing the buffer list:

![Basic](./imgs/basic.png)

Showing the help window:

![With help](./imgs/withhelp.png)

## API

All the code has been developed using objects (OOP), facilitating maintenance, debugging, and readability. In the [Project Structure](./?tab=readme-ov-file#project-structure) section, the functionality of each file is detailed. If you want to start analyzing the code, start with `init.lua`, which is where the plugin is configured and the different objects are instantiated, and continue with `maincontroller.lua`, which is responsible for orchestrating user actions and neovim events with the plugin logic.

## Contribution

You are welcome to propose improvements, report bugs, or send pull requests. Keep in mind that for a PR to be accepted, it must pass the various CI checks, such as tests or the linter.

To run the tests locally, it is necessary to follow these steps:

```bash
cd buffon.nvim
mkdir packages
git clone https://github.com/nvim-lua/plenary.nvim.git packages/plenary.nvim
git clone https://github.com/nvim-tree/nvim-web-devicons.git packages/nvim-web-devicons
make test
```

### Project Structure

I have tried to organize the code in the best way I knew how, although it can surely be improved. Below I explain how it is structured:

* buffer.lua: Buffer object, where the properties of each buffer shown in the list are stored.
* bufferslist.lua: Manages the buffer list
* config.lua: Manages the configuration
* init.lua: Configures and starts the plugin.
* log.lua: Manages the logs (uses [plenary](https://github.com/nvim-lua/plenary.nvim))
* maincontroller.lua: Orchestrates user actions and events with the plugin logic
* page.lua: Manages a page
* pagecontroller.lua: Manages all pages
* storage.lua: Manages data persistence
* ui
  * mainwindow.lua: Buffon's main window
  * help.lua: Help window
  * window.lua: Object to display windows
* utils.lua: Various utilities

The `tests` folder includes the entire battery of tests for the plugin.

### Development branch

The integration branch will always be **develop**. All pull requests should be directed to this branch. When the code is stable, the repository owner will merge the changes from *develop* to *main* to release a new version.

> [!NOTE]
> I don't know the impact this plugin will have, but if it grows a lot or there is a lot of movement, I will be unable to maintain it and will need help from one or two maintainers.

**I hope you like it and enjoy it!**

