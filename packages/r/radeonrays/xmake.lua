package("radeonrays")
    set_homepage("https://github.com/GPUOpen-LibrariesAndSDKs/RadeonRays_SDK")
    set_description("Radeon Rays is ray intersection acceleration library for hardware and software multiplatforms using CPU and GPU")
    set_license("MIT")

    add_urls("https://github.com/GPUOpen-LibrariesAndSDKs/RadeonRays_SDK/archive/refs/tags/$(version).tar.gz",
             "https://github.com/GPUOpen-LibrariesAndSDKs/RadeonRays_SDK.git")

    add_versions("4.1", "96ea69b8942d2b0d58295723aa82ef19517193a09a137d0f7c6bcd44a8ae0368")

    add_deps("cmake")
    add_deps("spdlog <1.13.0", {configs = {header_only = false, noexcept = true}})

    on_install(function (package)
        io.replace("src/core/include/radeonrays.h", "#ifdef _WIN32", "#if defined(_WIN32) || defined(WIN32) || defined(__MINGW32__)", {plain = true})
        --io.replace("src/core/src/radeonrays.cpp", "RRError rrCreateContext", "RR_API RRError rrCreateContext", {plain = true})
        if not package:config("shared") then
            io.replace("src/core/CMakeLists.txt", "target_compile_definitions(radeonrays PRIVATE RR_EXPORT_API)", "", {plain = true})
        end
        io.replace("CMakeLists.txt", "add_subdirectory(fuzz_test)", "", {plain = true})
        io.replace("CMakeLists.txt", "add_subdirectory(bvh_analyzer)", "", {plain = true})
        io.replace("src/core/CMakeLists.txt", "target_link_libraries(radeonrays PRIVATE project_options project_warnings spdlog::spdlog)", "target_link_libraries(radeonrays PRIVATE spdlog::spdlog)", {plain = true})
        local configs = {"-DENABLE_TESTING=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        os.cp(path.join("src", "core", "include"), package:installdir())
        local file = io.open("src/core/CMakeLists.txt", "a")
        file:write([[

install(TARGETS radeonrays LIBRARY DESTINATION "lib" ARCHIVE DESTINATION "lib" RUNTIME DESTINATION "bin")
]])
        file:close()
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cxxfuncs("rrCreateContext", {includes = "radeonrays.h"}))
    end)
