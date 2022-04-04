local Field = require('field')
local Toolset = require('toolset')

local toolset = Toolset.register({
    name = 'gcc',
    value = require('gcc')
})

local toolsetField = Field.get('toolset')
-- TODO: Add 'gcc' to allowed values