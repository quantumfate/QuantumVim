---@class java ai
---@field setup function
local M = {}

---Setup the jdtls for java
---@return boolean server_started whether the jdtls server started
function M.setup()
	local status, jdtls = pcall(require, "jdtls")
	if not status then
		return false
	end

	-- Setup Workspace
	local home = os.getenv("HOME")
	local workspace_path = home .. "/.local/share/quantumvim/jdtls-workspace/"
	local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:t")
	local workspace_dir = workspace_path .. project_name

	-- Determine OS
	local os_config = "linux"
	if vim.fn.has("mac") == 1 then
		os_config = "mac"
	end

	-- Setup Capabilities
	-- for completions
	local cmp_nvim_lsp = require("cmp_nvim_lsp")
	local client_capabilities = vim.lsp.protocol.make_client_capabilities()
	local capabilities = cmp_nvim_lsp.default_capabilities(client_capabilities)
	local extendedClientCapabilities = jdtls.extendedClientCapabilities
	extendedClientCapabilities.resolveAdditionalTextEditsSupport = true

	-- Setup Testing and Debugging
	local bundles = {}
	local mason_path = vim.fn.glob(vim.fn.stdpath("data") .. "/mason/")
	vim.list_extend(bundles, vim.split(vim.fn.glob(mason_path .. "packages/java-test/extension/server/*.jar"), "\n"))
	vim.list_extend(
		bundles,
		vim.split(
			vim.fn.glob(
				mason_path .. "packages/java-debug-adapter/extension/server/com.microsoft.java.debug.plugin-*.jar"
			),
			"\n"
		)
	)

	local config = {
		cmd = {
			"java",
			"-Declipse.application=org.eclipse.jdt.ls.core.id1",
			"-Dosgi.bundles.defaultStartLevel=4",
			"-Declipse.product=org.eclipse.jdt.ls.core.product",
			"-Dlog.protocol=true",
			"-Dlog.level=ALL",
			"-Xms1g",
			"--add-modules=ALL-SYSTEM",
			"--add-opens",
			"java.base/java.util=ALL-UNNAMED",
			"--add-opens",
			"java.base/java.lang=ALL-UNNAMED",
			"-javaagent:" .. home .. "/.local/share/nvim/mason/packages/jdtls/lombok.jar",
			"-jar",
			vim.fn.glob(home .. "/.local/share/nvim/mason/packages/jdtls/plugins/org.eclipse.equinox.launcher_*.jar"),
			"-configuration",
			home .. "/.local/share/nvim/mason/packages/jdtls/config_" .. os_config,
			"-data",
			workspace_dir,
		},
		root_dir = require("jdtls.setup").find_root({ ".git", "mvnw", "gradlew", "pom.xml", "build.gradle", ".mvn" }),
		capabilities = vim.tbl_extend("keep", capabilities, {
			workspace = {
				configuration = true,
			},
			textDocument = {
				completion = {
					completionItem = {
						snippetSupport = true,
					},
				},
			},
		}),

		settings = {
			java = {
				eclipse = {
					downloadSources = true,
				},
				configuration = {
					updateBuildConfiguration = "automatic",
					maven = {
						userSettings = home .. "/.m2/settings.xml",
						globalSettings = home .. "/.m2/settings.xml",
					},
					runtimes = {
						{
							name = "JavaSE-17",
							path = "/usr/lib/jvm/java-17-openjdk-amd64",
							javadoc = "/usr/lib/jvm/java-17-openjdk-amd64/docs/api",
							sources = "/usr/lib/jvm/java-17-openjdk-amd64/lib/src.zip",
						},
						--{
						--	name = "Java 20 SepMachine",
						--	path = "~/.sdkman/candidates/java/20.0.1-sem",
						--},
						--{
						--	name = "Java 17 SepMachine",
						--	path = "~/.sdkman/candidates/java/17.0.7-sem",
						--},
						--{
						--	name = "Java 11 SepMachine",
						--	path = "~/.sdkman/candidates/java/11.0.19-sem",
						--},
						--{
						--	name = "Java 8 SepMachine",
						--	path = "~/.sdkman/candidates/java/8.0.372-sem",
						--},
					},
				},
				includeSourceMethodDeclarations = true,
				jdt = {
					ls = {
						androidSupport = true,
						lombokSupport = true,
						protofBufSupport = true,
					},
				},
				maven = {
					downloadSources = true,
				},
				implementationsCodeLens = {
					enabled = true,
				},
				signatureHelp = {
					true,
				},
				referencesCodeLens = {
					enabled = true,
				},
				references = {
					includeDecompiledSources = true,
				},
				inlayHints = {
					parameterNames = {
						enabled = "all", -- literals, all, none
					},
				},
				format = {
					enabled = false,
				},
			},
			extendedClientCapabilities = extendedClientCapabilities,
		},
		init_options = {
			bundles = bundles,
		},
	}

	config["on_attach"] = function(client, bufnr)
		local _, _ = pcall(vim.lsp.codelens.refresh)
		require("jdtls").setup_dap({ hotcodereplace = "auto" })
		require("qvim.lang.lsp").common_on_attach(client, bufnr)
		local status_ok, jdtls_dap = pcall(require, "jdtls.dap")
		if status_ok then
			jdtls_dap.setup_dap_main_class_configs()
		end
	end

	vim.api.nvim_create_autocmd({ "BufWritePost" }, {
		pattern = { "*.java" },
		callback = function()
			local _, _ = pcall(vim.lsp.codelens.refresh)
		end,
	})

	require("jdtls").start_or_attach(config)

	local keymaps = require("qvim.keymaps")

	keymaps:register(nil, {
		{
			binding_group = "C",
			name = "+Java",
			bindings = {
				o = { "<Cmd>lua require'jdtls'.organize_imports()<CR>", "Organize Imports" },
				v = { "<Cmd>lua require('jdtls').extract_variable()<CR>", "Extract Variable" },
				c = { "<Cmd>lua require('jdtls').extract_constant()<CR>", "Extract Constant" },
				t = { "<Cmd>lua require'jdtls'.test_nearest_method()<CR>", "Test Method" },
				T = { "<Cmd>lua require'jdtls'.test_class()<CR>", "Test Class" },
				u = { "<Cmd>JdtUpdateConfig<CR>", "Update Config" },
			},
			options = {
				prefix = "<leader>",
			},
		},
	})

	keymaps:register(nil, {
		{
			binding_group = "C",
			name = "+Java",
			bindings = {
				v = { "<Esc><Cmd>lua require('jdtls').extract_variable(true)<CR>", "Extract Variable" },
				c = { "<Esc><Cmd>lua require('jdtls').extract_constant(true)<CR>", "Extract Constant" },
				m = { "<Esc><Cmd>lua require('jdtls').extract_method(true)<CR>", "Extract Method" },
			},
			options = {
				prefix = "<leader>",
				mode = "v",
			},
		},
	})

	vim.cmd(":set ft=java") -- weird hack ik for seme reason java filetype doesn't load after opening the first file
	return true
end

return M
