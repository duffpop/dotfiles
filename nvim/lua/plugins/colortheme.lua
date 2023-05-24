return {
  "maxmx03/dracula.nvim",
  config = function()
    local dracula = require("dracula")
    local draculapro = require("draculapro")

    draculapro.setup({
      theme = "pro",
    })

    dracula.setup({
      dracula_pro = draculapro,
      colors = draculapro.colors,
    })

    vim.cmd.colorscheme("dracula")
  end,
  dependencies = {
    "duffpop/draculapro",
  },
}
