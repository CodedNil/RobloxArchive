local function IsArray(t)
	local i = 0
	for _ in pairs(t) do
		i = i + 1
		if t[i] == nil then
			return false
		end
	end
	return true
end

local function PrintTable(Table, Indent)
	local Numerical = IsArray(Table)
	local String = ""
	Indent = Indent or 1
	
	local TableLen = 0
	for i, v in pairs(Table) do
		TableLen = TableLen + 1
	end
	
	local N = 0
	for i, v in pairs(Table) do
		N = N + 1
		if type(v) == "table" then
			local Len = 0
			for i, v in pairs(v) do
				Len = Len + 1
			end
			
			if Len == 0 then
				String = String .. (string.rep("	", Indent) .. i .. " = " .. "{}" .. (N == TableLen and "" or ",")) .. "\n"
			else
				String = String .. (string.rep("	", Indent) .. i .. " = " .. "{") .. "\n"
				String = String .. PrintTable(v, Indent + 1)
				String = String .. (string.rep("	", Indent) .. "}" .. (N == TableLen and "" or ",")) .. "\n"
			end
		else
			if Numerical then
				String = String .. (string.rep("	", Indent) .. tostring(v) .. (N == TableLen and "" or ",")) .. "\n"
			else
				String = String .. (string.rep("	", Indent) .. i .. " = " .. tostring(v) .. (N == TableLen and "" or ",")) .. "\n"
			end
		end
	end
	
	return String
end

return PrintTable