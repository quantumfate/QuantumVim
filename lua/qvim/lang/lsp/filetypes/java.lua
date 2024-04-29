---@diagnostic disable: assign-type-mismatch
---@class java
---@field setup function
local M = {}

local log = require("qvim.log").lsp
local dap_utils = require("qvim.lang.dap.utils")
local lang_utils = require("qvim.lang.utils")
local lsp_utils = require("qvim.lang.lsp.utils")
---Setup the jdtls for java
---@return boolean server_started whether the jdtls server started
function M.setup()
	local status, jdtls = pcall(require, "jdtls")
	if not status then
		return false
	end

	-- Setup Workspace
	local home = os.getenv("HOME")
	local java_home = os.getenv("JAVA_HOME")
	local jdk_home = os.getenv("JDK_HOME")

	if not java_home then
		log.error("Java home environment variable not set.")
	end

	if not jdk_home then
		log.error("JDK home environment variable not set.")
	end

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
	vim.list_extend(
		bundles,
		vim.split(
			vim.fn.glob(
				mason_path .. "packages/java-test/extension/server/*.jar"
			),
			"\n"
		)
	)
	vim.list_extend(
		bundles,
		vim.split(
			vim.fn.glob(
				mason_path
					.. "packages/java-debug-adapter/extension/server/com.microsoft.java.debug.plugin-*.jar"
			),
			"\n"
		)
	)
	local java_17_debian_path = "/usr/lib/jvm/java-17-openjdk-amd64"
	local java_20_debian_path = "/usr/lib/jvm/java-20-openjdk-amd64"
	local java_17_arch_path = "/usr/lib/jvm/java-17-openjdk"
	local java_20_arch_path = "/usr/lib/jvm/java-20-openjdk"

	local is_java_17_debian = java_home == java_17_debian_path
	local is_java_20_debian = java_home == java_20_debian_path
	local is_java_17_arch = java_home == java_17_arch_path
	local is_java_20_arch = java_home == java_20_arch_path

	local runtimes = {
		[java_17_debian_path] = {
			name = "JavaSE-17",
			path = "/usr/lib/jvm/java-17-openjdk-amd64",
			javadoc = "/usr/lib/jvm/java-17-openjdk-amd64/docs/api",
			sources = "/usr/lib/jvm/java-17-openjdk-amd64/lib/src.zip",
			default = is_java_17_debian,
		},
		[java_20_debian_path] = {
			name = "JavaSE-20",
			path = "/usr/lib/jvm/java-20-openjdk-amd64",
			javadoc = "/usr/lib/jvm/java-20-openjdk-amd64/docs/api",
			sources = "/usr/lib/jvm/java-20-openjdk-amd64/lib/src.zip",
			default = is_java_20_debian,
		},
		--Arch
		[java_17_arch_path] = {
			name = "JavaSE-17",
			path = "/usr/lib/jvm/java-17-openjdk",
			javadoc = "/usr/share/doc/java17-openjdk/api",
			sources = "/usr/lib/jvm/java-17-openjdk/lib/src.zip",
			default = is_java_17_arch,
		},
		[java_20_arch_path] = {
			name = "JavaSE-20",
			path = "/usr/lib/jvm/java-20-openjdk",
			javadoc = "/usr/share/doc/java20-openjdk/api",
			sources = "/usr/lib/jvm/java-20-openjdk/lib/src.zip",
			default = is_java_20_arch,
		},
	}

	local runtime
	if is_java_17_debian then
		runtime = runtimes[java_17_debian_path]
	elseif is_java_20_debian then
		runtime = runtimes[java_20_debian_path]
	elseif is_java_17_arch then
		runtime = runtimes[java_17_arch_path]
	elseif is_java_20_arch then
		runtime = runtimes[java_20_arch_path]
	else
		log.error("Java runtime not found.")
	end

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
			"-javaagent:"
				.. get_qvim_data_dir()
				.. "/mason/packages/jdtls/lombok.jar",
			"-jar",
			vim.fn.glob(
				get_qvim_data_dir()
					.. "/mason/packages/jdtls/plugins/org.eclipse.equinox.launcher_*.jar"
			),
			"-configuration",
			get_qvim_data_dir() .. "/mason/packages/jdtls/config_" .. os_config,
			"-data",
			workspace_dir,
		},
		root_dir = require("jdtls.setup").find_root({
			".git",
			"mvnw",
			"gradlew",
			"pom.xml",
			"build.gradle",
			".mvn",
		}),
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
						runtime,
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

	---@type Package
	local pkg_jdtls = lsp_utils.get_mason_package("jdtls")
	---@diagnostic disable-next-line: param-type-mismatch
	lang_utils.try_install_and_setup_mason_package(
		pkg_jdtls,
		"jdtls",
		function() end,
		{}
	)
	---@type Package
	local pkg_java_test = dap_utils.resolve_test_package_from_mason("java")
	---@diagnostic disable-next-line: param-type-mismatch
	lang_utils.try_install_and_setup_mason_package(
		pkg_java_test,
		"java-test",
		function() end,
		{}
	)
	---@type Package
	local pkg_java_debug_adapter =
		dap_utils.resolve_dap_package_from_mason("java")
	---@diagnostic disable-next-line: param-type-mismatch
	lang_utils.try_install_and_setup_mason_package(
		pkg_java_debug_adapter,
		"java-debug-adapter",
		function() end,
		{}
	)
	require("jdtls").start_or_attach(config)

	local wk = require("which-key")
	wk.register({
		{
			C = {
				name = "+Java",
				o = {
					"<Cmd>lua require'jdtls'.organize_imports()<CR>",
					"Organize Imports",
				},
				m = {
					"<Esc><Cmd>lua require('jdtls').extract_method(true)<CR>",
					"Extract Method",
					mode = "v",
				},
				v = {
					"<Cmd>lua require('jdtls').extract_variable()<CR>",
					"Extract Variable",
					mode = { "n", "v" },
				},
				c = {
					"<Cmd>lua require('jdtls').extract_constant()<CR>",
					"Extract Constant",
					mode = { "n", "v" },
				},
				t = {
					"<Cmd>lua require'jdtls'.test_nearest_method()<CR>",
					"Test Method",
				},
				T = {
					"<Cmd>lua require'jdtls'.test_class()<CR>",
					"Test Class",
				},
				u = { "<Cmd>JdtUpdateConfig<CR>", "Update Config" },
			},
			options = {
				prefix = "<leader>",
			},
		},
	})

	return true
end

return M
