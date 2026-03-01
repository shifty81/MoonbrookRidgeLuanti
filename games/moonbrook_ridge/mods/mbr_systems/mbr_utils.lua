-- MoonBrook Ridge: Shared Utilities
-- Common helper functions used across multiple MBR systems.

mbr = mbr or {}
mbr.utils = {}

--- Clamp a value between a minimum and maximum.
-- @param val   number to clamp
-- @param min_v lower bound
-- @param max_v upper bound
-- @return clamped value
function mbr.utils.clamp(val, min_v, max_v)
	if val < min_v then return min_v end
	if val > max_v then return max_v end
	return val
end

--- Build a heart display string (filled ♥ and empty ♡).
-- @param hearts  current heart count (fractional values are floored)
-- @param max     optional max hearts (default 10)
-- @return string of filled and empty heart characters
function mbr.utils.format_hearts(hearts, max)
	max = max or 10
	local filled = math.floor(hearts)
	local parts = {}
	for i = 1, max do
		parts[i] = i <= filled and "\xe2\x99\xa5" or "\xe2\x99\xa1"
	end
	return table.concat(parts)
end
