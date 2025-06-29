package("coin-or-osi")
    set_homepage("https://github.com/coin-or/Osi")
    set_description("Open Solver Interface")

    add_urls("https://github.com/coin-or/Osi/archive/refs/tags/releases/$(version).tar.gz",
             "https://github.com/coin-or/Osi.git")

    add_versions("0.108.11", "1063b6a057e80222e2ede3ef0c73c0c54697e0fee1d913e2bef530310c13a670")

    add_includedirs("include", "include/coin-or")

    add_deps("coin-or-coinutils")

    on_install(function (package)
        os.cp(path.join(package:scriptdir(), "port", "xmake.lua"), "xmake.lua")
        import("package.tools.xmake").install(package)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <coin-or/CoinPackedVector.hpp>
            void test() {
                const int ne = 4;
                const int inx[ne] =   {  1,   4,  0,   2 };
                const double el[ne] = { 10., 40., 1., 50. };
                CoinPackedVector r(ne, inx, el);
                r.sortIncrElement();
                r.sortOriginalOrder();
            }
        ]]}, {configs = {languages = "c++11"}}))
    end)
