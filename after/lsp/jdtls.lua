-- Configuration for the Java language server (jdtls).
--
-- The version of jdtls installed by Mason requires Java 25, but the system only
-- has Java 21, so the server used to exit on startup and never published any
-- diagnostics. A local JDK 25 installed under ~/.local/share/jdk-25/jdk-25 is
-- used instead, without changing the system-wide Java installation.

local java_executable = vim.fn.expand('~/.local/share/jdk-25/jdk-25/bin/java')
local jdtls_executable = vim.fn.stdpath('data') .. '/mason/bin/jdtls'
local workspace_dir = vim.fn.stdpath('cache') .. '/jdtls/workspace'

return {
  -- Use one data directory per project so diagnostics from different projects
  -- do not get mixed in the same jdtls session.
  cmd = function(dispatchers, config)
    local data_dir = workspace_dir
    if config.root_dir then
      data_dir = data_dir .. '/' .. vim.fn.fnamemodify(config.root_dir, ':p:h:t')
    end
    return vim.lsp.rpc.start({
      jdtls_executable,
      '--java-executable', java_executable,
      '-data', data_dir,
    }, dispatchers, {
      cwd = config.cmd_cwd,
      env = config.cmd_env,
      detached = config.detached,
    })
  end,
  filetypes = { 'java' },
  root_markers = { 'pom.xml', 'build.gradle', 'build.gradle.kts', '.git' },
  single_file_support = true,
  settings = {
    java = {
      -- Reload automatically when pom.xml / build.gradle changes.
      configuration = { updateBuildConfiguration = 'automatic' },
      -- Don't flag an incomplete classpath in standalone files (IntelliJ also
      -- skips this when no project is open).
      errors = { incompleteClasspath = { severity = 'ignore' } },
    },
  },
}
