package("sclalertview")
    set_homepage("https://github.com/dogo/SCLAlertView")
    set_description("Beautiful animated Alert View. Written in Objective-C")
    set_license("MIT")

    add_urls("https://github.com/dogo/SCLAlertView/archive/refs/tags/$(version).tar.gz",
             "https://github.com/dogo/SCLAlertView.git")

    add_versions("1.4.2", "49da568c42aca32473622a0e398a3910c2d6f939d9c539634e22a046425c8e42")

    on_install("macosx", "iphoneos", function (package)
        local conf = package:is_debug() and "Debug" or "Release"
        local sdk = package:is_plat("iphoneos") and "iphoneos" or "macosx"

        os.vrunv("xcodebuild", {
            "-list",
            "-project", "SCLAlertView.xcodeproj"
        })

        os.vrunv("xcodebuild", {
            "build",
            "-quiet",
            "-project", "SCLAlertView.xcodeproj",
            "-scheme", "SCLAlertView",
            "-configuration", conf,
            "-sdk", sdk,
            "CODE_SIGN_IDENTITY=\"\"",
            "CODE_SIGNING_REQUIRED=NO",
            "CODE_SIGNING_ALLOWED=NO",
        })

        os.vrunv("find", {
            "."})
        
        -- os.mv(path.join(moltenvk_rootdir, "include"), package:installdir())
        -- os.mv(path.join(moltenvk_rootdir, "dylib", plat, "*"), package:installdir("lib"))
        -- os.mv(path.join(moltenvk_rootdir, "MoltenVK.xcframework", plat:lower() .. "-*", "*.a"), package:installdir("lib"))
        
        -- if package:config("shared") then
        --     os.mv(path.join(moltenvk_rootdir, "dynamic", "dylib", plat, "*.dylib"), package:installdir("lib"))
        -- else
        --     os.mv(path.join(moltenvk_rootdir, "static", "MoltenVK.xcframework", plat:lower() .. "-*", "*.a"), package:installdir("lib"))
        -- end
        
        -- os.mv(path.join(moltenvk_shader_rootdir, "Tools", "*"), package:installdir("bin"))
        -- os.mv(path.join(moltenvk_shader_rootdir, "MoltenVKShaderConverter.xcframework", plat:lower() .. "-*", "*.a"), package:installdir("lib"))
        -- os.mv(path.join(moltenvk_shader_rootdir, "include", "*.h"), package:installdir("include"))
        -- package:addenv("PATH", "bin")
    end)

    on_test(function (package)
        assert(package:has_cfuncs("vkGetDeviceProcAddr", {includes = "vulkan/vulkan_core.h"}))
    end)
