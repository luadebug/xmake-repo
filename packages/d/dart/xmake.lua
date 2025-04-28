package("dart")
    set_kind("binary")
    set_homepage("https://dart.dev")
    set_description("The Dart SDK, including the VM, JS and Wasm compilers, analysis, core libraries, and more.")
    set_license("BSD-3-Clause")

    add_urls("https://github.com/dart-lang/sdk.git")
    add_versions("2025.04.28", "42e3a7a8fd4550bc31e36a7456fa2eecc35aee16")

    add_deps("depot_tools")

    on_install("linux", "macosx", "windows", function (package)
        import("core.base.global")
        local envs = {}
        local proxy = global.get("proxy")
        if proxy then
            envs.HTTP_PROXY = proxy
            envs.HTTPS_PROXY = proxy
            envs.ALL_PROXY = proxy
        end
        io.writefile(".gclient", [=[solutions = [
            {
              "name": ".",
              "url": "https://github.com/dart-lang/sdk.git",
              "deps_file": "DEPS",
              "managed": False,
              "custom_deps": {},
              "custom_vars": {
                  "download_emscripten": True,
                },
            }]]=])
        if package:is_plat("windows") then
            envs.DEPOT_TOOLS_WIN_TOOLCHAIN = "0"
            envs.GYP_MSVS_VERSION = "2022"
        end
        local gclient = is_host("windows") and "gclient.bat" or "gclient"
        -- A Git account needs to be configured
        os.vrunv("git", {"config", "user.email", "dummy@dummy.com"})
        os.vrunv("git", {"config", "user.name", "Dummy Dummy"})
        -- Prevent long path issue on Windows
        os.vrunv("git", {"config", "--local", "core.longpaths", "true"})
        -- Update repository and dependencies
        -- Clean any local changes to apply patches
        os.vrunv(gclient, {"sync", "-v"}, {envs = envs})
        local target_cpu = "x86"
        local mode = "release"
        if package:is_debug() then
            mode = "debug"
        end
        if package:is_arch("x86") then
            target_cpu    = "ia32"
        elseif package:is_arch("x64") then
            target_cpu    = "x64"
        elseif package:is_arch("arm64") then
            target_cpu    = "arm64"
        end
        local python_exe = package:is_plat("windows") and "python" or "python3"
        os.cd("sdk")
        os.vrun(python_exe .. " tools/build.py --mode " .. mode .. " --arch " .. target_cpu .. " create_sdk")
        os.cp("out/*/dart-sdk/**", package:installdir("bin"))
        package:addenv("PATH", "bin")
    end)

    on_test(function (package)
        os.vrun("dart --version")
    end)
