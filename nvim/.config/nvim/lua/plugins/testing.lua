return {
  {
    "folke/todo-comments.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {
      signs = false,
    },
    keys = {
      {
        "]t",
        function()
          require("todo-comments").jump_next()
        end,
        desc = "Next TODO",
      },
      {
        "[t",
        function()
          require("todo-comments").jump_prev()
        end,
        desc = "Previous TODO",
      },
      {
        "<leader>ft",
        function()
          require("todo-comments.fzf").todo({ prompt = "TODOs> " })
        end,
        desc = "Find TODOs in project",
      },
    },
  },
  -- { "lewis6991/gitsigns.nvim" },
  -- { "kdheepak/lazygit.nvim" },
  -- { "folke/trouble.nvim" },
  -- { "mbbill/undotree" },
  -- { "coder/claudecode.nvim" },
  -- { "nvim-pack/nvim-spectre" },
  -- { "folke/flash.nvim" },
  -- { "akinsho/git-conflict.nvim" },
  -- { "sindrets/diffview.nvim" },
  -- { "linux-cultist/venv-selector.nvim" },
  -- { "milanglacier/minuet-ai.nvim" },  -- some free api for this / ollama model for inline code suggestions
  -- {
  --   "smjonas/inc-rename.nvim",
  --   cmd = "IncRename",
  --   config = true,
  -- },
  -- {
  --   "Wansmer/treesj",
  --   keys = {
  --     { "<leader>m", function() require("treesj").toggle() end, desc = "Toggle Split/Join Code Block" },
  --   },
  --   dependencies = { "nvim-treesitter/nvim-treesitter" },
  --   opts = {
  --     use_default_keymaps = false,
  --     max_join_length = 120,
  --   },
  -- },
}
