---
--- GCC toolset
---

local path = require('path')
local set = require('set')


local function notNil(value)
	return value ~= nil
end


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


local function getLinkerCommand(cfg)
	local kinds = {
		ConsoleApplication = '$(CXX)',
		StaticLibrary = '$(AR)'
	}
	
	local kind = cfg.kind or (cfg.project and cfg.project.kind or 'ConsoleApplication')
	return kinds[kind]
end


local function getLinkerArgs(cfg)
	local flags = {
		SharedLibrary = set.of('-shared', string.format('-Wl,-soname=lib%s.so', cfg.targetName))
	}
	
	local kind = cfg.kind or (cfg.project and cfg.project.kind or 'ConsoleApplication')
	local flags = flags[kind] or set.of()

	-- add rpath for shared libraries
	-- add flags for symbols

	return flags
end


local gcc = {}

gcc.flagTable = {
	rtti = {
		Off = "-fno-rtti"
	}
}


local function tryGetFlag(name, value)
	local supportedValues = gcc.flagTable[name]
	if not supportedValues then
		return nil
	end
	local mappedValue = supportedValues[value]
	if not mappedValue then
		return nil
	end
	return mappedValue
end


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
gcc.mapFlags = function (cfg)
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

	flags.cCompilerFlags = set.filter(set.of(), notNil)
	flags.cppCompilerFlags = set.filter(set.of('-MMD',
											'-MP',
											getArchitectureFlag(cfg)), notNil)
	flags.cxxCompilerFlags = set.filter(set.of(tryGetFlag('rtti', cfg.rtti)), notNil)

	flags.linkerExecutable = getLinkerCommand(cfg)

	flags.linkerFlags = set.filter(set.of(getArchitectureFlag(cfg),
										getLinkerArgs(cfg)), notNil) -- other linker flags here

	return flags
end


return gcc
