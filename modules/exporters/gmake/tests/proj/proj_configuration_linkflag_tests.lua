local gmake = require('gmake')
local proj = gmake.proj

local GmakeProjConfigurationLinkFlagTests = test.declare('GmakeProjConfigurationLinkFlagTests', 'gmake-proj', 'gmake')


---
-- Tests the default linker flags output.
---
function GmakeProjConfigurationLinkFlagTests.DefaultTarget()
	workspace('MyWorkspace', function ()
		configurations({ 'Debug' })

		project('MyProject', function ()
		end)
	end)

	local cfg = gmake.buildDom().workspaces['MyWorkspace'].projects['MyProject'].configs['Debug']

	proj.linkFlags(cfg)

	test.capture [[
ALL_LDFLAGS = $(LDFLAGS) -m64
	]]
end


---
-- Tests the default linker flags output for console applications.
---
function GmakeProjConfigurationLinkFlagTests.ConsoleApplication()
	workspace('MyWorkspace', function ()
		configurations({ 'Debug' })

		project('MyProject', function ()
			kind 'ConsoleApplication'
		end)
	end)

	local cfg = gmake.buildDom().workspaces['MyWorkspace'].projects['MyProject'].configs['Debug']

	proj.linkFlags(cfg)

	test.capture [[
ALL_LDFLAGS = $(LDFLAGS) -m64
	]]
end


---
-- Tests the default linker flags output for static libraries.
---
function GmakeProjConfigurationLinkFlagTests.StaticLibrary()
	workspace('MyWorkspace', function ()
		configurations({ 'Debug' })

		project('MyProject', function ()
			kind 'StaticLibrary'
		end)
	end)

	local cfg = gmake.buildDom().workspaces['MyWorkspace'].projects['MyProject'].configs['Debug']

	proj.linkFlags(cfg)

	test.capture [[
ALL_LDFLAGS = $(LDFLAGS) -m64
	]]
end


---
-- Tests the default linker flags output for shared libraries.
---
function GmakeProjConfigurationLinkFlagTests.SharedLibrary()
	workspace('MyWorkspace', function ()
		configurations({ 'Debug' })

		project('MyProject', function ()
			kind 'SharedLibrary'
		end)
	end)

	local cfg = gmake.buildDom().workspaces['MyWorkspace'].projects['MyProject'].configs['Debug']

	proj.linkFlags(cfg)

	test.capture [[
ALL_LDFLAGS = $(LDFLAGS) -m64 -shared -Wl,-soname=libMyProject.so
	]]
end