require('plenary.filetype').add_file 'fsd'
require('plenary.filetype').add_file 'dotnet'
require('plenary.filetype').add_file 'templ'

vim.filetype.add {
  extension = {
    fsd = 'fsd',
    templ = 'templ',
  },
  filename = {
    ['argus.config'] = 'xml',
    ['Directory.Build.props'] = 'xml',
    ['Directory.Build.targets'] = 'xml',
  },
}
