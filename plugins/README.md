# Plugins

This directory contains Xmake task plugins distributed with `xmake-repo`.

## Layout

Each plugin is a task directory:

```text
plugins/
  plugin-name/
    xmake.lua
    main.lua
```

`xmake.lua` defines the task using `task("plugin-name")`; `main.lua` contains its implementation. The task name must match the directory name.

## Usage

Fetch or refresh the repository, then invoke the task directly:

```bash
xrepo update-repo
xmake xfetch
```

The fetched repository is loaded from `~/.xmake/repositories/xmake-repo/plugins`. During local development, point Xmake at a checkout instead:

```bash
XMAKE_MAIN_REPO=/path/to/xmake-repo xmake xfetch
```

## Design

Repository plugins are loaded directly from the repository checkout. They are not packages: do not use `package()`, `set_kind("plugin")`, package versions, URLs, `add_requires`, or `xrepo install -k plugin`. Updating the repository updates the available plugins; no copy into the package installation directory is needed.

## Testing

From the repository root:

```bash
XMAKE_MAIN_REPO=$PWD xmake l scripts/test_plugins.lua
```
