package("dascript")
    set_homepage("https://daslang.io")
    set_description("daslang - high-performance statically strong typed scripting language")
    set_license("BSD-3-Clause")

    add_urls("https://github.com/GaijinEntertainment/daScript.git")
    add_versions("2026.01.13", "583458a234ee5d767d1910e1a4e14c29065b6e70")

    add_deps("cmake")
    add_deps("flex", "bison")

    on_install(function (package)
        io.replace("CMakeLists.txt", [[set(DAS_INSTALL_BINDIR bin]], [[set(DAS_INSTALL_BINDIR "${CMAKE_INSTALL_BINDIR}"]], {plain = true})
        io.replace("CMakeLists.txt", [[set(DAS_INSTALL_LIBDIR lib]], [[set(DAS_INSTALL_LIBDIR "${CMAKE_INSTALL_LIBDIR}"]], {plain = true})
        io.replace("CMakeLists.txt", [[set(DAS_INSTALL_DOCDIR .]], [[set(DAS_INSTALL_DOCDIR "doc"]], {plain = true})
        local configs = {
            "-DDAS_PROFILE_DISABLED=ON",
            "-DDAS_TUTORIAL_DISABLED=ON",
            "-DDAS_TESTS_DISABLED=ON",
            "-DDAS_AOT_EXAMPLES_DISABLED=OFF"
        }
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DDAS_ENABLE_DLL=" .. (package:config("shared") and "1" or "0"))
        import("package.tools.cmake").install(package, configs)
        os.cp("include", package:installdir())
        os.trycp("**.a", package:installdir("lib"))
        os.trycp("**.so", package:installdir("lib"))
        os.trycp("**.dylib", package:installdir("lib"))
        os.trycp("**.dll", package:installdir("bin"))
        os.trycp("**.lib", package:installdir("lib"))
        if package:config("shared") then
            os.trycp("**.pdb", package:installdir("bin"))
        else
            os.trycp("**.pdb", package:installdir("lib"))
        end
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <daScript/daScript.h>
            void test() {
                das_initialize();
                auto printer = das_text_make_printer();
                auto writer = das_text_make_writer();
            }
        ]]}, {configs = {languages = "c++17"}}))
    end)
