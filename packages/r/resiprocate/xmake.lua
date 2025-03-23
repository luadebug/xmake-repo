package("resiprocate")
    set_homepage("https://www.resiprocate.org")
    set_description("C++ implementation of SIP, ICE, TURN and related protocols.")

    add_urls("https://github.com/resiprocate/resiprocate/archive/refs/tags/resiprocate-$(version).tar.gz",
             "https://github.com/resiprocate/resiprocate.git")

    add_versions("1.13.1", "df8d0cbf17793077d59c2863b23a6da8e9c77aba88327d1a494accaded1ef605")

    add_configs("with_ssl", {description = "Link against SSL libraries", default = true, type = "boolean"})
    add_configs("use_popt", {description = "Link against POPT libraries", default = false, type = "boolean"})
    add_configs("use_fmt", {description = "Link against fmt library", default = false, type = "boolean"})
    add_configs("use_mysql", {description = "Link against MySQL client libraries", default = false, type = "boolean"})
    add_configs("use_srtp", {description = "Link against srtp library", default = false, type = "boolean"})
    add_configs("use_kurento", {description = "Build Kurento client", default = false, type = "boolean"})
    add_configs("use_gstreamer", {description = "Link against gstreamer library", default = false, type = "boolean"})
    add_configs("with_cares", {description = "Link against libc-ares", default = true, type = "boolean"})

    add_configs("use_ipv6", {description = "Enable IPv6", default = true, type = "boolean"})
    add_configs("use_dtls", {description = "Enable DTLS", default = true, type = "boolean"})
    add_configs("pedantic_stack", {description = "Enable pedantic behavior (fully parse all messages)", default = false, type = "boolean"})

    add_deps("cmake")

    if is_plat("windows") then
        add_deps("pkgconf")
    else
        add_deps("pkg-config")
    end

    if is_plat("windows") then
        add_syslinks("crypt32", "ncrypt", "ws2_32", "winmm")
    elseif is_plat("linux", "bsd") then
        add_syslinks("m", "resolv", "rt", "pthread")
    elseif is_plat("macosx", "iphoneos") then
        add_syslinks("resolv")
        add_frameworks("CoreFoundation", "CoreServices", "Security", "SystemConfiguration")
    end

    on_load(function (package)
        if package:config("with_ssl") then
            package:add("deps", "openssl")
        end
        if package:config("use_popt") then
            package:add("deps", "popt")
        end
        if package:config("use_fmt") then
            package:add("deps", "fmt")
        end
        if package:config("use_mysql") then
            package:add("deps", "mysql")
        end
        if package:config("use_srtp") then
            package:add("deps", "srtp")
        end
        if package:config("use_kurento") then
            package:add("deps", "boost", {configs = {asio = true}})
            package:add("deps", "websocketpp")
        end
        if package:config("use_gstreamer") then
            package:add("deps", "gstreamer")
        end
        if package:config("with_cares") then
            package:add("deps", "c-ares")
        end
    end)

    on_install(function (package)
        -- Fix c-ares
        if package:config("with_cares") then
            io.replace("CMakeLists.txt", "pkg_check_modules(cares libcares REQUIRED IMPORTED_TARGET)", "find_package(c-ares CONFIG)", {plain = true})
            io.replace("CMakeLists.txt", "set(ARES_LIBRARIES PkgConfig::cares)", "set(ARES_LIBRARIES c-ares::cares)", {plain = true})
        end

        local configs = {"-DENABLE_LOG_REPOSITORY_DETAILS=OFF", "-DUSE_NUGET=OFF", "-DUSE_CONTRIB=OFF",
                         "-DBUILD_TESTING=OFF",
                         "-DBUILD_PYTHON=OFF", "-DUSE_MAXMIND_GEOIP=OFF", "-DBUILD_QPID_PROTON=OFF",
                         "-DBUILD_REPRO=OFF", "-DBUILD_RECON=OFF", "-DBUILD_REFLOW=OFF", "-DBUILD_RETURN=OFF", "-DBUILD_TFM=OFF", "-DBUILD_REND=OFF"}

        table.insert(configs, "-DUSE_POPT=" .. (package:config("use_popt") and "ON" or "OFF"))
        table.insert(configs, "-DUSE_FMT=" .. (package:config("use_fmt") and "ON" or "OFF"))
        table.insert(configs, "-DUSE_MYSQL=" .. (package:config("use_mysql") and "ON" or "OFF"))
        table.insert(configs, "-DUSE_SRTP=" .. (package:config("use_srtp") and "ON" or "OFF"))
        table.insert(configs, "-DUSE_KURENTO=" .. (package:config("use_kurento") and "ON" or "OFF"))
        table.insert(configs, "-DUSE_GSTREAMER=" .. (package:config("use_gstreamer") and "ON" or "OFF"))

        table.insert(configs, "-DWITH_C_ARES=" .. (package:config("with_cares") and "ON" or "OFF"))
        table.insert(configs, "-DWITH_SSL=" .. (package:config("with_ssl") and "ON" or "OFF"))

        table.insert(configs, "-DUSE_IPV6=" .. (package:config("use_ipv6") and "ON" or "OFF"))
        table.insert(configs, "-DUSE_DTLS=" .. (package:config("use_dtls") and "ON" or "OFF"))
        table.insert(configs, "-DPEDANTIC_STACK=" .. (package:config("pedantic_stack") and "ON" or "OFF"))

        table.insert(configs, "-DENABLE_ANDROID=" .. (package:is_plat("android") and "ON" or "OFF"))
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        
        import("package.tools.cmake").install(package, configs)

        for _, file in ipairs(os.files(path.join(package:installdir("include"), "**.hxx"))) do
            io.replace(file, "WIN32", "_WIN32", {plain = true})
        end
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <resip/stack/SipMessage.hxx>
            using namespace resip;
            void test() {
                const std::string sipRawData("foobar");
                SipMessage* msg = SipMessage::make(sipRawData.data(), true);
            }
        ]]}, {configs = {languages = "c++11"}}))
    end)
