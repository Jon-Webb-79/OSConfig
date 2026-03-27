
return {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    config = function()
        require("tokyonight").setup({
            style = "storm",
            transparent = false,
            terminal_colors = true,
            styles = {
                comments = { italic = true },
                keywords = { italic = true },
                functions = {},
                variables = {},
                sidebars = "dark",
                floats = "dark",
            },
            sidebars = { "qf", "help", "NvimTree", "terminal" },
            hide_inactive_statusline = false,
            dim_inactive = false,
            lualine_bold = true,
        })

        vim.cmd.colorscheme("tokyonight")
    end,
}
