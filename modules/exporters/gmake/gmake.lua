---
-- GNU Makefile exporter.
---

local dom = require('dom')
local path = require('path')
local premake = require('premake')
local State = require('state')
local Toolset = require('toolset')

local gmake = {}

gmake.wks = doFile('./src/wks.lua', gmake)
gmake.proj = doFile('./src/proj.lua', gmake)

---
-- Temporary variable until toolsets are implemented.
---
local _ARCHITECTURES = {
	x86 = 'x86',
	x86_64 = 'x86_64',
	arm = 'ARM',
	arm64 = 'ARM64'
}

---
-- Exports the GNU makefile for all workspaces.
---
function gmake.export()
	printf('Configuring...')
	local root = gmake.buildDom()

	for _, wks in ipairs(root.workspaces) do
		printf('Exporting %s...', wks.name)
		gmake.exportWorkspace(wks)
	end
	print('Done.')
end

---
-- Query and build a DOM hierarchy from the contents of the user project script.
--
-- @returns
--	A `dom.Root` object
---
function gmake.buildDom()
	local root = dom.Root.new({
		action = 'gmake'
	})

	root.workspaces = root:fetchWorkspaces(gmake.fetchWorkspace)

	for _, wks in ipairs(root.workspaces) do
		for _, prj in ipairs(wks.projects) do
			prj.exportPath = gmake.getMakefileName(prj, true, root)
		end
	end

	return root
end

---
-- Fetch the settings for a specific workspace by name, adding values required by
-- the Visual Studio exporter methods. Also fetches the projects and configurations
-- used by the workspace.
--
-- @param root
--	A `dom.Root` representing the current root state.
-- @param name
--	The name of the workspace to fetch.
-- @returns
--	A `dom.Workspace`, with additional Visual Studio specific values.
---
function gmake.fetchWorkspace(root, name)
	local wks = dom.Workspace.new(root
		:select({ workspaces = name })
		:withInheritance()
	)

	wks.root = root

	wks.exportPath = gmake.wks.filename(wks)

	wks.configs = wks:fetchConfigs(gmake.fetchWorkspaceConfig)
	wks.projects = wks:fetchProjects(gmake.fetchProject)

	return wks
end


---
-- Fetch the settings for a specific project by name, adding values required by
-- the Visual Studio exporter methods. Also fetches the configurations used by
-- the project.
--
-- @param wks
--	The `dom.Workspace` instance which contains the target project.
-- @param name
--	The name of the project to fetch.
-- @returns
--	A `dom.Project`, with additional Visual Studio specific values.
---
function gmake.fetchProject(wks, name)
	local prj = dom.Project.new(wks
		:select({ projects = name })
		:fromScopes(wks.root)
		:withInheritance()
	)

	local toolsetName = prj.toolset or 'gcc'
	local tools = Toolset.get(toolsetName)

	prj.root = wks.root
	prj.workspace = wks
	prj.uuid = prj.uuid or os.uuid(prj.name)

	prj.architecture = prj.architecture or 'x86_64'
	prj.platform = prj.platform or prj.architecture

	prj.targetName = prj.targetName or prj.name
	prj.generatedFlags = tools.mapFlags(prj)

	prj.configs = prj:fetchConfigs(gmake.fetchProjectConfig)

	return prj
end


---
-- Fetch the settings for a specific workspace-level configuration.
--
-- @param wks
--	The `dom.Workspace` instance which contains the target configuration.
-- @param build
--	The target build configuration name, eg. 'Debug'
-- @param platform
--	The target platform name.
-- @returns
--	A `dom.Config`, with additional Visual Studio specific values.
---
function gmake.fetchWorkspaceConfig(wks, build, platform)
	local cfg = gmake.fetchConfig(wks
		:selectAny({ configurations = build, platforms = platform })
		:fromScopes(wks.root)
	)

	cfg.root = wks.root
	cfg.workspace = wks

	return cfg
end


---
-- Fetch the settings for a specific project-level configuration.
--
-- @param wks
--	The `dom.Project` instance which contains the target configuration.
-- @param build
--	The target build configuration name, eg. 'Debug'
-- @param platform
--	The target platform name.
-- @returns
--	A `dom.Config`, with additional Visual Studio specific values.
---
function gmake.fetchProjectConfig(prj, build, platform)
	local cfg = gmake.fetchConfig(prj
		:selectAny({ configurations = build, platforms = platform })
		:fromScopes(prj.root, prj.workspace)
		:withInheritance()
	)

	local toolsetName = prj.toolset or 'gcc'
	local tools = Toolset.get(toolsetName)

	cfg.root = prj.root
	cfg.workspace = prj.workspace
	cfg.project = prj

	-- TODO: Compiler/Linker from DOM
	cfg.targetName = cfg.targetName or prj.targetName
	cfg.generatedFlags = tools.mapFlags(cfg)

	return cfg
end


---
-- Fetch the settings for a specific file-level configuration.
--
-- @param cfg
--	The `dom.Config` instance which contains the target file settings. May be a
--	workspace or project configuration.
-- @param file
--	The path of the file for which settings should be fetched.
-- @returns
--	A `dom.Config`, with additional Visual Studio specific values.
---
function gmake.fetchFileConfig(cfg, file)
	local fileCfg = dom.Config.new(cfg
		:select({ files = file })
		:fromScopes(cfg.root, cfg.workspace, cfg.project)
	)

	fileCfg.file = file
	fileCfg.cfg = cfg

	return fileCfg
end


---
-- Helper for `gmake.fetchWorkspaceConfig()` and `gmake.fetchProjectConfig()`.
-- Computes common Visual Studio specific values required by the exporter.
---
function gmake.fetchConfig(state)
	local cfg = dom.Config.new(state)

	-- translate the incoming architecture
	cfg.architecture = cfg.architecture or 'x86_64'
	cfg.platform = cfg.platform or cfg.architecture

	return cfg
end


---
-- Export a GNU makefile workspace (`Makefile`) to the file system.
---
function gmake.exportWorkspace(wks)
	premake.export(wks, wks.exportPath, gmake.wks.export)
	for i = 1, #wks.projects do
		gmake.exportProject(wks.projects[i])
	end
end


---
-- Export a GNU makefile
---
function gmake.exportProject(prj)
	gmake.proj.export(prj)
end


---
-- Determines the name of the makefile.
--
-- @param this
--  Workspace or project to get makefile name of
-- @param searchprjs
--  Should this search projects for makefile names in addition to workspaces
-- @returns
--  Makefile if this project or workspace is unique to the folder, else .make
---
function gmake.getMakefileName(this, searchprjs, domroot)
	local count = 0
	local root = domroot or gmake.buildDom()
	for _, wks in ipairs(root.workspaces) do
		if wks.location == this.location then
			count = count + 1
		end

		if searchprjs then
			for _, prj in ipairs(wks.projects) do
				if prj.location == this.location then
					count = count + 1
				end
			end
		end
	end

	if count == 1 then
		return path.join(this.location, 'Makefile')
	else
		return path.join(this.location, this.name .. '.mak')
	end
end


return gmake