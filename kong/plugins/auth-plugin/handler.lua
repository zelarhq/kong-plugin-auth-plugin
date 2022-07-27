local access = require "kong.plugins.auth-plugin.access"

local plugin = {
  PRIORITY = 1000,
  VERSION = "0.1"
}

function plugin:init_worker()
  kong.log.debug("'init_worker' handler started")
end

function plugin:access(plugin_conf)
  kong.log.inspect(plugin_conf)
  access.run(plugin_conf)
end

return plugin
