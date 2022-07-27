local typedefs = require "kong.db.schema.typedefs"

local PLUGIN_NAME = "auth-plugin"

local schema = {
  name = PLUGIN_NAME,
  fields = {
    { consumer = typedefs.no_consumer }, { protocols = typedefs.protocols_http },
    { config = {
      type = "record",
      fields = {
        { introspection_endpoint = typedefs.url({ required = true }) },
        { authorization_endpoint = typedefs.url({ required = true }) },
        { token_header = {
          type = "string",
          default = "Authorization",
          required = true
        },
        },
      }
    },
    },
  },
}

return schema
