local M = {}

---Returns the dap config record
---@param main java-dap.JavaDebugResolveMainClassRecord
---@return java-dap.DapLauncherConfig
function M.main_to_dap_launch_config(main)
	local project_name = main.projectName
	local main_class = main.mainClass

	return {
		request = 'launch',
		type = 'java',
		name = string.format('%s -> %s', project_name, main_class),
		projectName = project_name,
		mainClass = main_class,
	}
end

return M
