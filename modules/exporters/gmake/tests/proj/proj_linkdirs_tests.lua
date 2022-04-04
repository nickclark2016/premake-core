local gmake = require('gmake')
local proj = gmake.proj

local GmakeProjLinkDirsTests = test.declare('GmakeProjLinkDirsTests', 'gmake-proj', 'gmake')


---
-- Tests the default linker directory output.
---
function GmakeProjLinkDirsTests.DefaultCmd()
	workspace('MyWorkspace', function ()
		configurations({ 'Debug' })

		project('MyProject', function ()
		end)
	end)

	local prj = gmake.buildDom().workspaces['MyWorkspace'].projects['MyProject']

	proj.linkDirectories(prj)

	test.capture [[
ifneq ($(system), osx)
	ALL_LDFLAGS += -L/usr/lib64
endif
	]]
end


---
-- Tests the linker directories for x86.
---
function GmakeProjLinkDirsTests.x86Cmd()
	workspace('MyWorkspace', function ()
		configurations({ 'Debug' })

		project('MyProject', function ()
			architecture('x86')
		end)
	end)

	local prj = gmake.buildDom().workspaces['MyWorkspace'].projects['MyProject']

	proj.linkDirectories(prj)

	test.capture [[
ifneq ($(system), osx)
	ALL_LDFLAGS += -L/usr/lib
endif
	]]
end


---
-- Tests the link directories for x86_64.
---
function GmakeProjLinkDirsTests.x86_64Cmd()
	workspace('MyWorkspace', function ()
		configurations({ 'Debug' })

		project('MyProject', function ()
			architecture('x86_64')
		end)
	end)

	local prj = gmake.buildDom().workspaces['MyWorkspace'].projects['MyProject']

	proj.linkDirectories(prj)

	test.capture [[
ifneq ($(system), osx)
	ALL_LDFLAGS += -L/usr/lib64
endif
	]]
end