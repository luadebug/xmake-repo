package("cpp-mcp")
    set_homepage("https://github.com/hkr04/cpp-mcp")
    set_description("Lightweight C++ MCP (Model Context Protocol) SDK")
    set_license("MIT")

    add_urls("https://github.com/hkr04/cpp-mcp.git")
    add_versions("2025.05.24", "86856a2fcc038e05675f0649e51cd4f9d3692263")

    add_deps("cmake")

    on_install(function (package)
        os.cp("include", package:installdir())
        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include "mcp_server.h"
            void test() {
                mcp::server server("localhost", 8080);
                server.set_server_info("MCP Example Server", "0.1.0");
            }
        ]]}, {configs = {languages = "c++17"}}))
    end)
