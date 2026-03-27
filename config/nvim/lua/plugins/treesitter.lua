return {
    "nvim-treesitter/nvim-treesitter",
    branch = "master",
    build = ":TSUpdate",
    event = { "BufReadPost", "BufNewFile" },
    config = function()
        require("nvim-treesitter.configs").setup({
            ensure_installed = {
                "bash",
                "c",
                "cpp",
                "lua",
                "python",
                "vim",
                "vimdoc",
                "query",
                "markdown",
                "markdown_inline",
            },
            auto_install = false,
            highlight = {
                enable = true,
            },
            indent = {
                enable = true,
            },
        })
    end,
}
