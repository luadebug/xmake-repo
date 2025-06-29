add_rules("mode.debug", "mode.release")

add_requires("coin-or-osi")
set_languages("c++11")

target("Osi")
    set_kind("$(kind)")
    add_files(
        "src/Osi/OsiAuxInfo.cpp",
        "src/Osi/OsiBranchingObject.cpp",
        "src/Osi/OsiChooseVariable.cpp",
        "src/Osi/OsiColCut.cpp",
        "src/Osi/OsiCut.cpp",
        "src/Osi/OsiCuts.cpp",
        "src/Osi/OsiNames.cpp",
        "src/Osi/OsiPresolve.cpp",
        "src/Osi/OsiRowCut.cpp",
        "src/Osi/OsiRowCutDebugger.cpp",
        "src/Osi/OsiSolverBranch.cpp",
        "src/Osi/OsiSolverInterface.cpp",
        "src/Osi/OsiFeatures.cpp"
    )
    add_headerfiles("src/Osi/*.hpp", {prefixdir = "coin-or"})
    if is_plat("windows") and is_kind("shared") then
        add_rules("utils.symbols.export_all", {export_classes = true})
    end
    add_packages("coin-or-utils")
