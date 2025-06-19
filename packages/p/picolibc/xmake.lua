package("picolibc")
    set_homepage("https://keithp.com/picolibc")
    set_description("picolibc - a C library designed for embedded 32- and 64- bit systems.")
    set_license("GPL-2.0")

    add_urls("https://github.com/picolibc/picolibc/archive/refs/tags/$(version).tar.gz",
             "https://github.com/picolibc/picolibc.git")

    add_versions("1.8.10", "d1fc2a20f217472f8d9da084a519a25678e8d91852a41c7f3f1840d3508f7163")

    add_deps("cmake")

    on_install("!windows", function (package)
        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    -- on_test(function (package)
    --     assert(package:has_cfuncs("foo", {includes = "foo.h"}))
    -- end)
