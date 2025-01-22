package("lastools")
    set_homepage("https://github.com/LAStools/LAStools")
    set_description("efficient tools for LiDAR processing")

    add_urls("https://github.com/LAStools/LAStools/archive/refs/tags/$(version).tar.gz",
             "https://github.com/LAStools/LAStools.git")

    add_versions("v2.0.3", "b6c6ac33835ead2c69d05e282febc266048ba071a71dae6fdad321d532dfcf78")

    add_deps("cmake")

    on_install(function (package)
        io.replace("LASlib/CMakeLists.txt", "add_subdirectory(LASlib/example)", "", {plain = true})
        io.replace("LASlib/src/CMakeLists.txt", "DESTINATION lib/LASlib", "DESTINATION lib", {plain = true})
        io.replace("CMakeLists.txt", 
        [[set(CMAKE_INSTALL_RPATH "${CMAKE_INSTALL_PREFIX}/lib/LASlib")]], 
        [[set(CMAKE_INSTALL_RPATH "${CMAKE_INSTALL_PREFIX}/lib")]], {plain = true})
        io.replace("CMakeLists.txt", "add_subdirectory(src)", "", {plain = true})
        local configs = {}
        table.insert(configs, "-DLASZIP_BUILD_STATIC=" .. (package:config("shared") and "OFF" or "ON"))
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cxxfuncs("IS_LITTLE_ENDIAN", {languages = "c++17", includes = "LASlib/mydefs.hpp"}))
    end)
