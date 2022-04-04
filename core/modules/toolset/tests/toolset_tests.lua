local Toolset = require('toolset')

local ToolsetTests = test.declare('ToolsetTests', 'toolset')

local testTs = {
    mapFlags = function(cfg)
    
    end
}

local testTsToolset

function ToolsetTests.setup()
	testTsToolset = Toolset.register({
		name = 'testTs',
        value = testTs
	})
end

function ToolsetTests.teardown()
	Toolset.remove(testTsToolset)
end


function ToolsetTests.testNotNil()
    test.isNotNil(testTsToolset)
end