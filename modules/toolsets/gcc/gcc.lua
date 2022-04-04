---
--- GCC toolset
---

local path = require('path')

local function getArchitectureFlag(cfg)
	local archs = {
		x86 = '-m32',
		x86_64 = '-m64'
	}

	local arch = cfg.platform or cfg.architecture -- Try to get the architecture from the platform then architecture
	return archs[arch]
end


function getProjectPath(cfg)
	if cfg.project == nil then
		return cfg.location
	else
		return cfg.project.location
	end
end


local function getSystemLibrariesDir(cfg)
	local archs = {
		default = '/usr/lib64',
		x86 = '/usr/lib',
		x86_64 = '/usr/lib64'
	}

	local arch = cfg.platform or cfg.architecture -- Try to get the architecture from the platform then architecture
	return archs[arch] or archs.default
end


local gcc = {
	---
	--- Maps a configuration or a project to a table of corresponding flags.
	---
	--- Guaranteed in result:
	---   * defines - A table of define flags
	---   * includes - A table of include flags
	---   * compilerFlags - A table of compiler flags that are not in any of the
	---				above flags
	---   * linkerFlags - A table of linker flags that are not in any of the above 
	---				flags
	---
	mapFlags = function (cfg)
		local flags = {}

		flags.includes = table.map(cfg.includeDirs or {}, function(_, dir)
			return '-I' .. path.getRelative(getProjectPath(cfg), dir)
		end)

		flags.defines = table.map(cfg.defines or {}, function(_, def)
			return '-D' .. def
		end)

		flags.linkDirs = table.map(cfg.linkDirs or {}, function(_, dir)
			return '-L' .. dir
		end)

		flags.systemLinkDirs = {
			'-L' .. getSystemLibrariesDir(cfg)
		}

		flags.compilerFlags = { getArchitectureFlag(cfg) } -- other compiler flags here
		flags.linkerFlags = { getArchitectureFlag(cfg) } -- other linker flags here

		return flags
	end,
}

return gcc
