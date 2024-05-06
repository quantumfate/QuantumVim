local a = require("plenary.async_lib.tests")

a.describe("log", function()
	local log = require("qvim.log")
	before_each(function()
		vim.cmd([[
	    let v:errmsg = ""
      let v:errors = []
    ]])
	end)
	after_each(function()
		local errmsg = vim.fn.eval("v:errmsg")
		local exception = vim.fn.eval("v:exception")
		local errors = vim.fn.eval("v:errors")
		assert.equal("", errmsg)
		assert.equal("", exception)
		assert.True(vim.tbl_isempty(errors))
	end)

	a.it("Structlog should be able to write to LSP pipeline.", function()
		log.lsp.info("Test lsp")
	end)
	a.it("Structlog should be able to write to qvim pipeline.", function()
		log.qvim.info("Test Qvim")
	end)
	a.it("Structlog should be able to write to userconf pipeline.", function()
		log.userconf.info("Test userconf")
	end)
	a.it("Structlog should be able to write to dap pipeline.", function()
		log.dap.info("Test dap")
	end)
	a.it("Structlog should be able to write to none_ls pipeline.", function()
		log.none_ls.info("Test none_ls")
	end)
end)
