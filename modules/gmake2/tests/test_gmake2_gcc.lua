--
-- test_gmake2_gcc.lua
-- Test gcc support in Makefiles.
-- (c) 2021 Jason Perkins, Blizzard Entertainment and the Premake project
--

local suite = test.declare("gmake2_gcc")

local p = premake
local gmake2 = p.modules.gmake2

--
-- Setup
--

local wks, prj

function suite.setup()
    wks = test.createWorkspace()
    toolset "gcc"
    prj = p.workspace.getproject(wks, 1)
end


--
-- Make sure that the correct compilers are used.
--

function suite.usesCorrectCompilers()
    gmake2.cpp.outputConfigurationSection(prj)
    test.capture [[
# Configurations
# #############################################

ifeq ($(origin CC), default)
  CC = gcc
endif
ifeq ($(origin CXX), default)
  CXX = g++
endif
ifeq ($(origin AR), default)
  AR = ar
endif
]]
end

