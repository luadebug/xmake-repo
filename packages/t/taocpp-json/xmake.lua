package("taocpp-json")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/taocpp/json")
    set_description("C++ header-only JSON library")
    set_license("MIT")

    add_urls("https://github.com/taocpp/json.git", {submodules = false})
    add_versions("2025.03.11", "11a31e12eda35c1322f9cf6ebb4cca0653d579dc")

    add_deps("cmake")
    add_deps("pegtl")

    on_install(function (package)
        local configs = {
            "-DTAOCPP_JSON_BUILD_TESTS=OFF", "-DTAOCPP_JSON_BUILD_EXAMPLES=OFF", "-DTAOCPP_JSON_BUILD_PERFORMANCE=OFF", 
            "-DTAOCPP_JSON_INSTALL=ON"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <tao/json.hpp>
            #include <string>

            void test() {
                const std::string json_str = R"({
                    "app": "test",
                    "version": 1.2,
                    "features": ["fast", "header-only", "modern"],
                    "enabled": true,
                    "config": {
                        "timeout": 1000, "retries": 3
                    }
                })";
                const auto value = tao::json::from_string(json_str);
            }
        ]]}, { configs = { languages = "c++17" } }))
    end)
