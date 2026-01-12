return {
  {
    "shaunsingh/nord.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      -- Optional customization
      vim.g.nord_contrast = true -- Make sidebars and popup menus contrast
      vim.g.nord_borders = false -- Enable borders between splits
      vim.g.nord_disable_background = false -- Set to true for transparency
      vim.g.nord_italic = false -- Disable italics
      vim.g.nord_uniform_diff_background = true -- Enable uniform diff backgrounds
      vim.g.nord_bold = false -- Disable bold
      
      require('nord').set()
    end,
  },
}
