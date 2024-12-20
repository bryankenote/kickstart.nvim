-- debug.lua
--
-- Shows how to use the DAP plugin to debug your code.
--
-- Primarily focused on configuring the debugger for Go, but can
-- be extended to other languages as well. That's why it's called
-- kickstart.nvim and not kitchen-sink.nvim ;)

return {
  -- NOTE: Yes, you can install new plugins here!
  'mfussenegger/nvim-dap',
  -- NOTE: And you can specify dependencies as well
  dependencies = {
    -- Creates a beautiful debugger UI
    'rcarriga/nvim-dap-ui',

    -- Installs the debug adapters for you
    'williamboman/mason.nvim',
    'jay-babu/mason-nvim-dap.nvim',

    'nvim-telescope/telescope-dap.nvim',

    -- Add your own debuggers here
    'leoluz/nvim-dap-go',
    -- Install the vscode-js-debug adapter
    {
      'microsoft/vscode-js-debug',
      -- After install, build it and rename the dist directory to out
      build = 'npm install --legacy-peer-deps --no-save && npx gulp vsDebugServerBundle && rm -rf out && mv dist out',
      version = '1.*',
    },
    {
      'mxsdev/nvim-dap-vscode-js',
      config = function()
        ---@diagnostic disable-next-line: missing-fields
        require('dap-vscode-js').setup {
          -- Path of node executable. Defaults to $NODE_PATH, and then "node"
          -- node_path = "node",

          -- Path to vscode-js-debug installation.
          debugger_path = vim.fn.resolve(vim.fn.stdpath 'data' .. '/lazy/vscode-js-debug'),

          -- Command to use to launch the debug server. Takes precedence over "node_path" and "debugger_path"
          -- debugger_cmd = { "js-debug-adapter" },

          -- which adapters to register in nvim-dap
          adapters = {
            'chrome',
            'pwa-node',
            'pwa-chrome',
            'pwa-msedge',
            'pwa-extensionHost',
            'node-terminal',
            'node',
          },

          -- Path for file logging
          -- log_file_path = "(stdpath cache)/dap_vscode_js.log",

          -- Logging level for output to file. Set to false to disable logging.
          -- log_file_level = false,

          -- Logging level for output to console. Set to false to disable console output.
          -- log_console_level = vim.log.levels.ERROR,
        }
      end,
    },
    {
      'Joakker/lua-json5',
      build = './install.sh',
    },
  },
  config = function()
    local dap = require 'dap'
    local dapui = require 'dapui'

    require('mason-nvim-dap').setup {
      -- Makes a best effort to setup the various debuggers with
      -- reasonable debug configurations
      automatic_setup = true,

      -- You can provide additional configuration to the handlers,
      -- see mason-nvim-dap README for more information
      handlers = {},

      -- You'll need to check that you have the required things installed
      -- online, please don't ask me how to install them :)
      ensure_installed = {
        -- Update this to ensure that you have the debuggers for the langs you want
        'delve',
        'netcoredbg',
      },
    }

    local js_based_languages = {
      'typescript',
      'javascript',
      'typescriptreact',
      'javascriptreact',
      'vue',
    }

    -- Basic debugging keymaps, feel free to change to your liking!
    -- vim.keymap.set('n', '<leader>dr', dap.continue, { desc = 'Run (Start/Continue)' })
    vim.keymap.set('n', '<leader>dr', function()
      if vim.fn.filereadable '.vscode/launch.json' then
        local dap_vscode = require 'dap.ext.vscode'
        dap_vscode.load_launchjs(nil, {
          ['pwa-node'] = js_based_languages,
          ['node'] = js_based_languages,
          ['chrome'] = js_based_languages,
          ['pwa-chrome'] = js_based_languages,
        })
      end
      dap.continue()
    end, { desc = 'Run (Start/Continue)' })
    vim.keymap.set('n', '<leader>di', dap.step_into, { desc = 'Step Into' })
    vim.keymap.set('n', '<leader>dv', dap.step_over, { desc = 'Step Over' })
    vim.keymap.set('n', '<leader>do', dap.step_out, { desc = 'Step Out' })
    vim.keymap.set('n', '<leader>dT', dap.terminate, { desc = 'Terminate' })
    vim.keymap.set('n', '<leader>du', dapui.toggle, { desc = 'Toggle UI' })
    vim.keymap.set('n', '<leader>dl', '<cmd>Telescope dap list_breakpoints<cr>', { desc = 'List Breakpoints' })
    vim.keymap.set('n', '<leader>dc', dap.run_to_cursor, { desc = 'Run to cursor' })
    vim.keymap.set('n', '<leader>db', dap.toggle_breakpoint, { desc = 'Toggle Breakpoint' })
    vim.keymap.set('n', '<leader>dB', function()
      dap.set_breakpoint(vim.fn.input 'Breakpoint condition: ')
    end, { desc = 'Conditional Breakpoint' })

    -- Dap adapter setup
    dap.adapters.netcoredbg = {
      type = 'executable',
      command = '/usr/local/netcoredbg',
      args = { '--interpreter=vscode' },
    }

    -- Dap configuration setup
    dap.configurations.cs = {
      -- Used with test runner
      {
        type = 'netcoredbg',
        name = 'netcoredbg',
        request = 'attach',
      },
      -- Used to attach to process
      {
        type = 'netcoredbg',
        name = 'netcoredbg - pick',
        request = 'attach',
        processId = function()
          return require('dap.utils').pick_process { filter = 'Faithlife' }
        end,
      },
    }

    for _, language in ipairs(js_based_languages) do
      dap.configurations[language] = {
        -- Debug single nodejs files
        {
          type = 'pwa-node',
          request = 'launch',
          name = 'Launch file',
          program = '${file}',
          cwd = vim.fn.getcwd(),
          sourceMaps = true,
        },
        -- Debug nodejs processes (make sure to add --inspect when you run the process)
        {
          type = 'pwa-node',
          request = 'attach',
          name = 'Attach',
          processId = require('dap.utils').pick_process,
          cwd = vim.fn.getcwd(),
          sourceMaps = true,
        },
        -- Debug web applications (client side)
        {
          type = 'pwa-chrome',
          request = 'launch',
          name = 'Launch & Debug Chrome',
          url = function()
            local co = coroutine.running()
            return coroutine.create(function()
              vim.ui.input({
                prompt = 'Enter URL: ',
                default = 'http://localhost:3000',
              }, function(url)
                if url == nil or url == '' then
                  return
                else
                  coroutine.resume(co, url)
                end
              end)
            end)
          end,
          webRoot = vim.fn.getcwd(),
          protocol = 'inspector',
          sourceMaps = true,
          userDataDir = false,
        },
        -- Divider for the launch.json derived configs
        {
          name = '----- ↓ launch.json configs ↓ -----',
          type = '',
          request = 'launch',
        },
      }
    end

    -- Dap UI setup
    -- For more information, see |:help nvim-dap-ui|
    dapui.setup {
      -- Set icons to characters that are more likely to work in every terminal.
      --    Feel free to remove or use ones that you like more! :)
      --    Don't feel like these are good choices.
      icons = {
        expanded = '▾',
        collapsed = '▸',
        current_frame = '*',
      },
      controls = {
        icons = {
          pause = '⏸',
          play = '▶',
          step_into = '⏎',
          step_over = '⏭',
          step_out = '⏮',
          step_back = 'b',
          run_last = '▶▶',
          terminate = '⏹',
          disconnect = '⏏',
        },
      },
    }

    local icons = require 'icons'
    vim.fn.sign_define('DapBreakpoint', { text = icons.ui.Circle, texthl = 'DiagnosticSignError', linehl = '', numhl = '' })
    vim.fn.sign_define('DapBreakpointRejected', { text = icons.ui.Circle, texthl = 'DiagnosticSignError', linehl = '', numhl = '' })
    vim.fn.sign_define('DapBreakpointStopped', { text = icons.BoldArrowRight, texthl = 'DiagnosticSignWarn', linehl = '', numhl = '' })
    -- Toggle to see last session result. Without this, you can't see session output in case of unhandled exception.
    vim.keymap.set('n', '<F7>', dapui.toggle, { desc = 'Debug: See last session result.' })

    dap.listeners.after.event_initialized['dapui_config'] = dapui.open
    dap.listeners.before.event_terminated['dapui_config'] = dapui.close
    dap.listeners.before.event_exited['dapui_config'] = dapui.close

    -- Install golang specific config
    require('dap-go').setup()
  end,
}
