# Contributing

If you are interested in contributing to the development of Buffon, this document explains points to keep in mind. It is important that you read it carefully.

## 🌱 Development branch

The integration branch will always be **develop**. All pull requests should be directed to this branch.

Once the code is stable, the repository owner will merge the changes from *develop* to *main* to release a new version.

## 📝 Commits

Regarding commit messages, this project follows the [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/) convention. This means that commit messages must follow a specific structure to facilitate understanding of the project's history.

On the other hand, try to keep PRs as small as possible and with the fewest number of commits possible.

## 📚 API

All the code has been developed using objects (OOP), facilitating maintenance, debugging, and readability. In the [Project Structure](./?tab=readme-ov-file#project-structure) section, the functionality of each file is detailed. If you want to start analyzing the code, start with `init.lua`, which is where the plugin is configured and the different objects are instantiated, and continue with `maincontroller.lua`, which is responsible for orchestrating user actions and neovim events with the plugin logic.

## ✅ Tests & Linter

You are welcome to propose improvements, report bugs, or send pull requests. Keep in mind that for a PR to be accepted, it must pass the various CI checks, such as tests or the linter.

To run the tests locally, it is necessary to follow these steps:

```bash
cd buffon.nvim
mkdir packages
git clone https://github.com/nvim-lua/plenary.nvim.git packages/plenary.nvim
git clone https://github.com/nvim-tree/nvim-web-devicons.git packages/nvim-web-devicons
make test
```

And to run the linter:

```bash
make lint
```

## 🏗️ Project Structure

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

## 🛠️ We Use Tabs

Yes, we are using tabs instead of spaces. This allows everyone to use their desired tab configuration.

This configuration is defined in the `.editorconfig` file.

-----

> [!NOTE]
> I don't know the impact this plugin will have, but if it grows a lot or there is a lot of movement, I will be unable to maintain it and will need help from one or two maintainers.
