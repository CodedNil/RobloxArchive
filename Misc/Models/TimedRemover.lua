local RBXAnimator = require(game.ReplicatedStorage.Libraries.RBXAnimator)

game.Workspace.DescendantAdded:connect(function(Part)
	wait()
	if not Part:IsA("BasePart") then return end
	if Part.Name:sub(1, 11) == "TimedRemove" then
		local DelayTime = Part.Name:sub(12)
		local RemoveTime = 0.4
		if DelayTime:find(":") then
			RemoveTime = DelayTime:sub(DelayTime:find(":") + 1)
			DelayTime = DelayTime:sub(1, DelayTime:find(":") - 1)
		end
		delay(DelayTime, function()
			RBXAnimator.TweenAsync(Part, "Transparency", 1, "OutQuint", RemoveTime + 1 - 1)
			wait(RemoveTime)
			Part:Destroy()
		end)
	end
end)