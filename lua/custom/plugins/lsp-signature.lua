return {
  'ray-x/lsp_signature.nvim',
  event = 'InsertEnter',
  config = function(_, opts)
    require('lsp_signature').on_attach {
      hint_prefix = '',
    }
  end,
}
