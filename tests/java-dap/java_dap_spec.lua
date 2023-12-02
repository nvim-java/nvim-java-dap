local plugin = require('java-dap')

describe('setup', function()
	it('java-dap', function()
		assert('plugin module should be avaiable', plugin)
	end)
end)
