local gmake = require('gmake')
local proj = gmake.proj

local GmakeProjLinkCmdTests = test.declare('GmakeProjLinkCmdTests', 'gmake-proj', 'gmake')


---
-- Tests the default linker command output.
---
function GmakeProjLinkCmdTests.DefaultCmd()
	workspace('MyWorkspace', function ()
		configurations({ 'Debug' })

		project('MyProject', function ()
		end)
	end)

	local prj = gmake.buildDom().workspaces['MyWorkspace'].projects['MyProject']

	proj.linkCmd(prj)

	test.capture [[
LINKCMD = $(CXX) -o "$@" $(OBJECTS) $(RESOURCES) $(ALL_LDFLAGS) $(LIBS)
	]]
end


---
-- Tests the linker command output for static libraries.
---
function GmakeProjLinkCmdTests.StaticLibrary()
	workspace('MyWorkspace', function ()
		configurations({ 'Debug' })

		project('MyProject', function ()
			kind 'StaticLibrary'
		end)
	end)

	local prj = gmake.buildDom().workspaces['MyWorkspace'].projects['MyProject']

	proj.linkCmd(prj)

	test.capture [[
LINKCMD = $(AR) -rcs "$@" $(OBJECTS)
	]]
end