function _check_plugin(name, plugindir)
    assert(name:match("^[%w][%w_-]*$"), "Error: invalid plugin name '" .. name .. "'!")

    local taskfile = path.join(plugindir, "xmake.lua")
    local mainfile = path.join(plugindir, "main.lua")
    assert(os.isfile(taskfile), "Error: " .. taskfile .. " not found!")
    assert(os.isfile(mainfile), "Error: " .. mainfile .. " not found!")

    local content = io.readfile(taskfile)
    local pattern = string.format([[task%%s*%%(%%s*['"]%s['"]%%s*%%)]], name)
    assert(content:find(pattern), "Error: " .. taskfile .. " must define task(\"" .. name .. "\")!")

    os.vrunv(os.programfile(), {name, "--help"}, {envs = {XMAKE_MAIN_REPO = path.directory(os.scriptdir())}})
end

function main()
    local plugins = os.dirs(path.join("plugins", "*"))
    if #plugins == 0 then
        return
    end

    print("checking plugins ...")
    for _, plugindir in ipairs(plugins) do
        local name = path.filename(plugindir)
        print("  > " .. name)
        _check_plugin(name, plugindir)
    end
    print("All plugins passed!")
end

return main
