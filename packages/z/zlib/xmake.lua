package("zlib")
    set_homepage("http://www.zlib.net")
    set_description("A Massively Spiffy Yet Delicately Unobtrusive Compression Library")
    set_license("zlib")

    add_urls("https://github.com/OSDVF/zlib-win-x64/archive/refs/heads/main.zip")

    add_versions("v1.2.3", "38be31d39243283905f5a1ad8490e01408097a6d928c2d76545dd6dd2024d55b")

    on_install("windows", function (package)
        if package:config("shared") then
            package:add("defines", "ZLIB_DLL")
            os.rm("zlib.lib")
            os.mv("zdll.lib", "zlib.lib")
            os.cp("zlib.lib", package:installdir("lib"))
            os.mv("zlib1.dll", "zlib.dll")
            os.cp("zlib.dll", package:installdir("bin"))
        else
            os.cp("zlib.lib", package:installdir("lib"))
        end
        os.cp("include", package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:has_cfuncs("inflate", {includes = "zlib.h"}))
    end)
