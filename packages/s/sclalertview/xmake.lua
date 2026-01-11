package("sclalertview")
    set_homepage("https://github.com/dogo/SCLAlertView")
    set_description("Beautiful animated Alert View. Written in Objective-C")
    set_license("MIT")

    add_urls("https://github.com/dogo/SCLAlertView/archive/refs/tags/$(version).tar.gz",
             "https://github.com/dogo/SCLAlertView.git")

    add_versions("1.4.2", "49da568c42aca32473622a0e398a3910c2d6f939d9c539634e22a046425c8e42")

    if is_plat("iphoneos") then
        add_includedirs("lib/SCLAlertViewFramework.framework/Headers")
        add_linkdirs("lib/SCLAlertViewFramework.framework")
        add_frameworkdirs("lib/SCLAlertViewFramework.framework")
        add_frameworks("SCLAlertViewFramework")
    end

    on_install("iphoneos", function (package)
        local conf = package:is_debug() and "Debug" or "Release"
        local sdk = "iphoneos"

        print("=== 查看项目 targets ===")
        os.vrunv("xcodebuild", {
            "-list",
            "-project", "SCLAlertView.xcodeproj"
        })
        
        print("=== 查看项目构建设置 ===")
        os.vrunv("xcodebuild", {
            "-showBuildSettings",
            "-project", "SCLAlertView.xcodeproj",
            "-target", "SCLAlertView"
        })

        print("=== 尝试构建框架 ===")
        os.vrunv("xcodebuild", {
            "build",
            "-project", "SCLAlertView.xcodeproj",
            "-target", "SCLAlertViewFramework",
            "-configuration", conf,
            "-sdk", sdk,
            "CODE_SIGN_IDENTITY=\"\"",
            "CODE_SIGNING_REQUIRED=NO",
            "CODE_SIGNING_ALLOWED=NO"
        })

        os.vrunv("find", {"."})
        local build_dir = path.join("build", conf .. "-" .. sdk)
        local framework_path = path.join(build_dir, "SCLAlertViewFramework.framework")
        os.cp(framework_path, package:installdir("lib"))
    end)

    on_test(function (package)
        assert(package:has_cfuncs("SCLAlertView.cornerRadius", {includes = "SCLAlertView/SCLAlertView.h"}))
    end)
