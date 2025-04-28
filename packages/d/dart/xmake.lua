package("dart")
    set_kind("binary")
    set_homepage("https://dart.dev")
    set_description("The Dart SDK, including the VM, JS and Wasm compilers, analysis, core libraries, and more.")
    set_license("BSD-3-Clause")

    add_urls("https://github.com/dart-lang/sdk.git")
    add_versions("2025.04.28", "42e3a7a8fd4550bc31e36a7456fa2eecc35aee16")

    add_deps("depot_tools")

    on_install("linux", "macosx", "windows", function (package)
        -- import("core.base.global")
        -- local proxy = global.get("proxy")
        -- if proxy then
            -- envs.HTTP_PROXY = proxy
            -- envs.HTTPS_PROXY = proxy
            -- envs.ALL_PROXY = proxy
        -- end
        local envs = {}
        -- 1. Configure .gclient properly
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
        os.rm("sdk/.git")  -- Remove existing git metadata
        -- 2. Windows-specific setup
        if package:is_plat("windows") then
            envs.DEPOT_TOOLS_WIN_TOOLCHAIN = "0"
            envs.GYP_MSVS_VERSION = "2022"
        end
        -- 3. Configure Git identity
        os.vrunv("git", {"config", "user.email", "dummy@dummy.com"})
        os.vrunv("git", {"config", "user.name", "Dummy Dummy"})
        if package:is_plat("windows") then
            os.vrunv("git", {"config", "--local", "core.longpaths", "true"})
        end
        -- 4. Sync dependencies with retries
        local gclient = package:is_plat("windows") and "gclient.bat" or "gclient"
        os.vrunv(gclient, {"sync", "--verbose", "--reset"}, {envs = envs})
        -- 5. Build configuration
        local mode = package:is_debug() and "debug" or "release"
        local target_cpu = ({
            x86 = "ia32",
            x64 = "x64",
            arm64 = "arm64"
        })[package:arch()] or "x64"
        -- 6. Execute build command properly
        local python = package:is_plat("windows") and "python" or "python3"
        os.vrunv(python, {"tools/build.py", "--mode", mode, "--arch", target_cpu, "create_sdk"})
        os.cp("out/*/dart-sdk/**", package:installdir("bin"))
        package:addenv("PATH", "bin")
    end)

    on_test(function (package)
        os.vrun("dart --version")
    end)
