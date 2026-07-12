local M = {}

function M.setup()
	local colors = {
		base00 = "{{colors.surface.default.hex}}",
		base01 = "{{colors.surface_container.default.hex}}",
		base02 = "{{colors.surface_container_high.default.hex}}",
		base03 = "{{colors.outline.default.hex}}",
		base04 = "{{colors.on_surface_variant.default.hex}}",
		base05 = "{{colors.on_surface.default.hex}}",
		base06 = "{{colors.on_surface.default.hex}}",
		base07 = "{{colors.on_background.default.hex}}",
		base08 = "{{colors.error.default.hex}}",
		base09 = "{{colors.tertiary.default.hex}}",
		base0A = "{{colors.secondary.default.hex}}",
		base0B = "{{colors.primary.default.hex}}",
		base0C = "{{colors.tertiary_fixed_dim.default.hex}}",
		base0D = "{{colors.primary_fixed_dim.default.hex}}",
		base0E = "{{colors.secondary_fixed_dim.default.hex}}",
		base0F = "{{colors.error_container.default.hex}}",
	}

	require("base16-colorscheme").setup(colors)

	local lualine_theme = {
		normal = {
			a = { bg = colors.base0D, fg = colors.base00, gui = "bold" },
			b = { bg = colors.base02, fg = colors.base05 },
			c = { bg = colors.base01, fg = colors.base05 },
		},
		insert = {
			a = { bg = colors.base0B, fg = colors.base00, gui = "bold" },
		},
		visual = {
			a = { bg = colors.base0E, fg = colors.base00, gui = "bold" },
		},
		replace = {
			a = { bg = colors.base08, fg = colors.base00, gui = "bold" },
		},
		command = {
			a = { bg = colors.base0A, fg = colors.base00, gui = "bold" },
		},
		inactive = {
			a = { bg = colors.base01, fg = colors.base03 },
			b = { bg = colors.base01, fg = colors.base03 },
			c = { bg = colors.base01, fg = colors.base03 },
		},
	}

	require("lualine").setup({
		options = {
			theme = lualine_theme,
			globalstatus = true,
		},
	})
end

-- Register a signal handler for SIGUSR1 (matugen updates)
local signal = vim.uv.new_signal()
signal:start(
	"sigusr1",
	vim.schedule_wrap(function()
		package.loaded["matugen"] = nil
		require("matugen").setup()
	end)
)

return M
