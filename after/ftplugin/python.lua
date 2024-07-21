local on_attach = function(client, bufnr)
  if client.name == 'ruff_lsp' then
    print("FOOBAR")
    -- Disable hover in favor of Pyright
    client.server_capabilities.hoverProvider = false
  end
end

require('lspconfig').pyright.setup {
  settings = {
    pyright = {
      -- Using Ruff's import organizer
      disableOrganizeImports = true,
    },
    python = {
      analysis = {
        -- Ignore all files for analysis to exclusively use Ruff for linting
        ignore = { '*' },
      },
    },
  },
}

require('lspconfig').ruff_lsp.setup {
  on_attach = on_attach,
}

