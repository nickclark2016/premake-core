---
-- Toolsets represent a configurable value which can be specified via user
-- script and retrieved via queries. A toolset has a "kind", such as `string`
-- for a simple string value, or `list:string` for a list of strings.
---

local array = require('array')
local Callback = require('callback')
local Type = require('type')

local Toolset = Type.declare('Toolset')

local _registeredToolsets = {}

local _onToolsetAddedCallbacks = {}
local _onToolsetRemovedCallbacks = {}


---
-- Create and register a new toolset.
--
-- @param definition
--    A table describing the new toolset, with these keys:
--
--    - name     A unique string name for the toolset, to be used to identify
--               the toolset in future operations.
--    - value    The toolset object to associate with the given name.
--
-- @return
--    A populated toolset object. Or nil and an error message if the toolset could
--    not be registered.
---

function Toolset.register(definition)
	local toolset = Type.assign(Toolset, definition)
	Toolset.validate(toolset.value)

	_registeredToolsets[toolset.name] = toolset.value

	for i = 1, #_onToolsetAddedCallbacks do
		Callback.call(_onToolsetAddedCallbacks[i], toolset)
	end

	return toolset
end


---
-- Remove a previously registered toolset.
---

function Toolset.remove(self)
	if _registeredToolsets[self.name] ~= nil then
		for i = 1, #_onToolsetRemovedCallbacks do
			Callback.call(_onToolsetRemovedCallbacks[i], self)
		end
		_registeredToolsets[self.name] = nil
	end
end


---
-- Enumerate all available toolsets.
---

function Toolset.each()
	local iterator = pairs(_registeredToolsets)
	local name, toolset
	return function()
		name, toolset = iterator(_registeredToolsets, name)
		return toolset
	end
end


---
-- Return true if a toolset with the given name has been registered.
---

function Toolset.exists(toolsetName)
	return (_registeredToolsets[toolsetName] ~= nil)
end


---
-- Fetch a toolset by name. Raises an error if the toolset does not exist.
---

function Toolset.get(toolsetName)
	local toolset = _registeredToolsets[toolsetName]
	if not toolset then
		error(string.format('No such toolset `%s`', toolsetName), 2)
	end
	return toolset
end


---
-- Register a callback function to be notified when a new toolset is added.
---

function Toolset.onToolsetAdded(fn)
	table.insert(_onToolsetAddedCallbacks, Callback.new(fn))
end


---
-- Register a callback function to be notified when a toolset is removed.
---

function Toolset.onToolsetRemoved(fn)
	table.insert(_onToolsetRemovedCallbacks, Callback.new(fn))
end


---
-- Send new value(s) to a toolset.
--
-- For simple values, the new value will replace the old one. For collections, the
-- new values will be added to the collection. Incoming values may be filtered or
-- processed, depending on the toolset kind.
---

function Toolset.receiveValues(self, currentValue, newValues)
	return newValues
end


---
-- Merges one or more blocks containing key-value pairs of toolsets and their
-- corresponding values. Returns a new block with all toolset values merged.
---

function Toolset.receiveAllValues(...)
	local result = {}

	local n = select('#', ...)
	for i = 1, n do
		local block = select(i, ...) or _EMPTY
		for key, value in pairs(block) do
			local toolset

			if Type.typeName(key) == 'Toolset' then
				toolset = key
			elseif type(key) == 'string' then
				toolset = Toolset.tryGet(key)
			end

			if toolset ~= nil then
				result[toolset] = Toolset.receiveValues(toolset, result[toolset], value)
			end
		end
	end

	return result
end


---
-- Returns a toolset definition by name, or `nil` if no such toolset exists.
---

function Toolset.tryGet(toolsetName)
	return _registeredToolsets[toolsetName]
end


function Toolset.validate(toolset)
	local function requireField(toolset, name, t)
		local obj = toolset[name]
		local isNotNull = obj ~= nil
		
		if isNotNull == false then
			error(string.format('%s %s not found for %s.', t, name, toolset.name))
		end
	
		local actualType = type(obj)
		if actualType ~= t then
			error(string.format('Expected type %s for %s for toolset %s. Instead received %s.', t, name, toolset.name, actualType))
		end
	end

	requireField(toolset, 'mapFlags', 'function')
end

---
-- Custom tostring() formatter for toolsets.
---

function Toolset.__tostring(self)
	return 'Toolset: ' .. self.name
end


return Toolset
