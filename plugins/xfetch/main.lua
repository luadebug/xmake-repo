--!A cross-platform build utility based on Lua
--
-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--
-- Copyright (C) 2015-present, Xmake Open Source Community.
--
-- @author      ruki
-- @file        main.lua
--

import("core.base.global")

function _format_gib(size_mb)
    local gib10 = math.floor(size_mb / 1024 * 10 + 0.5)
    return string.format("%d.%d GiB", math.floor(gib10 / 10), gib10 % 10)
end

function _host_os()
    local host = os.host()
    local name = host
    local version
    if host == "linux" then
        name = try {function () return linuxos.name() end} or host
        version = try {function () return linuxos.version() end}
    elseif host == "macosx" then
        name = "macOS"
        version = try {function () return macos.version() end}
    elseif host == "windows" then
        name = "Windows"
        version = try {function () return winos.version() end}
    end
    return name .. (version and (" " .. tostring(version)) or "") .. " " .. os.arch()
end

function _memory()
    local meminfo = os.meminfo()
    if meminfo.totalsize and meminfo.availsize then
        return _format_gib(meminfo.totalsize - meminfo.availsize) .. " / " .. _format_gib(meminfo.totalsize)
    end
end

function main()
    local cpuinfo = os.cpuinfo()
    local infos = {
        {"OS", _host_os()},
        {"CPU", (cpuinfo.model_name or cpuinfo.vendor or "unknown") .. " (" .. (cpuinfo.ncpu or 1) .. ")"},
        {"Memory", _memory()},
        {"Shell", os.shell()},
        {"Terminal", os.term()},
        {"Xmake", "v" .. xmake.version()},
        {"Theme", global.get("theme") or "default"}
    }
    if is_host("linux") then
        table.insert(infos, 2, {"Kernel", try {function () return tostring(linuxos.kernelver()) end}})
    end

    print("")
    cprint("${bright cyan}xmake${clear}")
    cprint("${dim}-----${clear}")
    for _, info in ipairs(infos) do
        if info[2] then
            cprint("${bright}%s${clear}: %s", info[1], info[2])
        end
    end
    print("")
end
