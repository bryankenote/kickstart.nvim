require('plenary.filetype').add_file 'fsd'
require('plenary.filetype').add_file 'dotnet'

vim.filetype.add {
  extension = {
    fsd = 'fsd',
  },
  filename = {
    ['argus.config'] = 'xml',
    ['Directory.Build.props'] = 'xml',
    ['Directory.Build.targets'] = 'xml',
  },
}
