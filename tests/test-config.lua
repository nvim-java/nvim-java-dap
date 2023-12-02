---@diagnostic disable: assign-type-mismatch
---@param dev_path string
---@param plug_path string
---@return string|nil
local function local_plug(dev_path, plug_path)
	return (vim.fn.isdirectory(dev_path) == 1) and dev_path or plug_path
end

local plug_path = './.test_plugins'

vim.opt.rtp:append(plug_path .. '/plenary.nvim')
vim.opt.rtp:append(
	local_plug('~/Workspace/nvim-java-core', plug_path .. '/nvim-java-core')
)
