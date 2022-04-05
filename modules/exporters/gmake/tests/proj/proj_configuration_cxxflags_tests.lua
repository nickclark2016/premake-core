local gmake = require('gmake')
local proj = gmake.proj

local GmakeProjConfigurationCxxflagsTests = test.declare('GmakeProjConfigurationCxxflagsTests', 'gmake-proj', 'gmake')


---
-- Tests the CXXFLAGS output with the default GCC flags.
---
function GmakeProjConfigurationCxxflagsTests.DefaultCxxFlags()
	workspace('MyWorkspace', function ()
		configurations({ 'Debug' })

		project('MyProject', function ()
		end)
	end)

	local prj = gmake.buildDom().workspaces['MyWorkspace'].projects['MyProject']
	local cfg = prj.configs['Debug']

	proj.cxxFlags(cfg)

	test.capture [[
	]]
end


---
-- Tests the CXXFLAGS output with RTTI off.
---
function GmakeProjConfigurationCxxflagsTests.RttiOff()
	workspace('MyWorkspace', function ()
		configurations({ 'Debug' })

		project('MyProject', function ()
			when({ 'configurations:Debug' }, function()
				rtti 'Off'
			end)
		end)
	end)

	local prj = gmake.buildDom().workspaces['MyWorkspace'].projects['MyProject']
	local cfg = prj.configs['Debug']

	proj.cxxFlags(cfg)

	test.capture [[
ALL_CXXFLAGS = $(CXXFLAGS) $(ALL_CPPFLAGS) -fno-rtti
	]]
end