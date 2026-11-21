local get_target = ya.sync(function()
	local h = cx.active.current.hovered
	if h and h.link_to then
		return tostring(h.link_to)
	end
	return nil
end)

return {
	entry = function()
		local target = get_target()
		if target then
			ya.notify({ title = "Symlink points to:", content = target, timeout = 5, level = "info" })
		else
			ya.notify({ title = "Symlink", content = "This file is not a symlink.", timeout = 3, level = "warn" })
		end
	end,
}
