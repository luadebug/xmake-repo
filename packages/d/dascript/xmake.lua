package("dascript")
    set_homepage("https://daslang.io")
    set_description("daslang - high-performance statically strong typed scripting language")
    set_license("BSD-3-Clause")

    add_urls("https://github.com/GaijinEntertainment/daScript.git")
    add_versions("2026.01.13", "583458a234ee5d767d1910e1a4e14c29065b6e70")

    add_deps("cmake")
    add_deps("flex", "bison")

    on_install(function (package)
        io.replace("CMakeLists.txt", [[${EXECUTABLE_OUTPUT_PATH}]], [[bin]], {plain = true})
        io.replace("CMakeLists.txt", [[${PROJECT_SOURCE_DIR}/lib]], [[lib]], {plain = true})
        local configs = {
            "DAS_PROFILE_DISABLED=ON",
            "DAS_TUTORIAL_DISABLED=ON",
            "DAS_TESTS_DISABLED=ON"
        }
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DDAS_ENABLE_DLL=" .. (package:config("shared") and "1" or "0"))
        import("package.tools.cmake").install(package, configs)
    end)

    -- on_test(function (package)
    --     assert(package:has_cfuncs("foo", {includes = "foo.h"}))
    -- end)
