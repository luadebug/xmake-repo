package("concord")
    set_homepage("https://cogmasters.github.io/concord/")
    set_description("A Discord API wrapper library made in C")
    set_license("MIT")

    add_urls("https://github.com/Cogmasters/concord/archive/refs/tags/$(version).tar.gz",
             "https://github.com/Cogmasters/concord.git", {submodules = false})

    add_versions("v2.4.0", "03b5213ee47ba03843747141dc61442cc3cec5cd86a58e53305a2fa19f232e92")

    if is_plat("linux", "bsd") then
        add_syslinks("pthread")
    end

    add_deps("curl")

    on_install("!windows and !mingw", function (package)
        local configs = {}
        io.writefile("xmake.lua", [[
            add_rules("mode.release", "mode.debug")
            add_requires("curl")
            target("concord")
                set_languages("c99")
                set_kind("$(kind)")
                add_files("src/*.c")
                add_headerfiles("include/(*.h)")
                add_defines("_XOPEN_SOURCE=600", "LOG_USE_COLOR=1")
                if is_plat("linux", "bsd") then
                    add_syslinks("pthread")
                end
                add_packages("curl")
        ]])
        import("package.tools.xmake").install(package)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("foo", {includes = "foo.h"}))
    end)
