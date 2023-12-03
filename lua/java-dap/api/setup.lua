local adapters = require('java-dap.data.adapters')

local log = require('java-core.utils.log')
local class = require('java-core.utils.class')

local JavaDebug = require('java-core.ls.clients.java-debug-client')

---@class java-dap.Setup
---@field private client LspClient
---@field private java_debug java-core.DebugClient
local Setup = class()

---@param client any
function Setup:_init(client)
	self.client = client

	self.java_debug = JavaDebug(client)
end

---@class java-dap.DapAdapter
---@field type string
---@field host string
---@field port integer

---Returns the dap adapter config
---@return java-dap.DapAdapter # dap adapter details
function Setup:get_dap_adapter()
	log.debug('creating dap adapter for java')

	local port = self.java_debug:start_debug_session()

	return {
		type = 'server',
		host = '127.0.0.1',
		port = port,
		enrich_config = function(config, callback)
			local updated_config = self:enrich_config(config)
			callback(updated_config)
		end,
	}
end

---Returns the launch config filled with required data if missing in the passed
--config
---@private
---@param config java-dap.DapLauncherConfigOverridable
---@return java-dap.DapLauncherConfigOverridable
function Setup:enrich_config(config)
	config = vim.deepcopy(config)

	local main = config.mainClass
	local project = config.projectName

	assert(main, 'To enrich the config, mainClass should already be present')
	assert(project, 'To enrich the config, projectName should already be present')

	if config.request == 'launch' then
		self.java_debug:build_workspace(main, project, nil, false)
	end

	if not config.classPaths or config.modulePaths then
		local paths = self.java_debug:resolve_classpath(main, project)

		if not config.modulePaths then
			config.modulePaths = paths[1]
		end

		if not config.classPaths then
			config.classPaths = paths[2]
		end
	end

	if not config.javaExec then
		local java_exec = self.java_debug:resolve_java_executable(main, project)
		config.javaExec = java_exec
	end

	return config
end

---Returns the dap configuration for the current project
---@return java-dap.DapLauncherConfig[] # dap configuration details
function Setup:get_dap_config()
	log.info('creating dap configuration for java')

	local mains = self.java_debug:resolve_main_class()
	local config = {}

	for _, main in ipairs(mains) do
		table.insert(config, adapters.main_to_dap_launch_config(main))
	end

	return config
end

return Setup

---@class java-dap.DapLauncherConfigOverridable
---@field name? string
---@field type? string
---@field request? string
---@field mainClass? string
---@field projectName? string
---@field cwd? string
---@field classPaths? string[]
---@field modulePaths? string[]
---@field vmArgs? string
---@field noDebug? boolean
---@field javaExec? string
---@field args? string
---@field env? { [string]: string; }
---@field envFile? string
---@field sourcePaths? string[]
---@field preLaunchTask? string
---@field postDebugTask? string

---@class java-dap.DapLauncherConfig
---@field name string
---@field type string
---@field request string
---@field mainClass string
---@field projectName string
---@field cwd string
---@field classPaths string[]
---@field modulePaths string[]
---@field vmArgs string
---@field noDebug boolean
---@field javaExec string
---@field args string
---@field env? { [string]: string; }
---@field envFile? string
---@field sourcePaths string[]
---@field preLaunchTask? string
---@field postDebugTask? string
