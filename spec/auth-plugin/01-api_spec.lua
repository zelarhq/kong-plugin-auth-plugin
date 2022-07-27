local helpers = require "spec.helpers"
local cjson   = require "cjson"

local PLUGIN_NAME = "auth-plugin"

for _, strategy in helpers.all_strategies() do

  describe(PLUGIN_NAME .. ": (access) [#" .. strategy .. "]", function()
    local client

    lazy_setup(function()

      local bp = helpers.get_db_utils(strategy == "off" and "postgres" or strategy, nil, { PLUGIN_NAME })

      -- Inject a test route. No need to create a service, there is a default
      -- service which will echo the request.
      local route1 = bp.routes:insert({
        hosts = { "localhost:8001" },
        -- paths = { "/httpbin/routes" },
        service = bp.services:insert { name = "httpbin", url = "http://httpbin.org/anything" }
      })
      -- add the plugin to test to the route we created
      bp.plugins:insert {
        name = PLUGIN_NAME,
        route = { id = route1.id },
        config = {
          introspection_endpoint = "http://192.168.1.118:8080/auth/validate/token",
          authorization_endpoint = "http://192.168.1.118:8080/auth/validate/customer"
        },
      }

      -- start kong
      assert(helpers.start_kong({
        -- set the strategy
        database           = strategy,
        -- use the custom test template to create a local mock server
        nginx_conf         = "spec/fixtures/custom_nginx.template",
        -- make sure our plugin gets loaded
        plugins            = "bundled," .. PLUGIN_NAME,
        -- write & load declarative config, only if 'strategy=off'
        declarative_config = strategy == "off" and helpers.make_yaml_file() or nil,
      }))
    end)

    lazy_teardown(function()
      helpers.stop_kong(nil, true)
    end)

    before_each(function()
      client = helpers.proxy_client()
    end)

    after_each(function()
      if client then client:close() end
    end)

    describe("success request", function()
      it("success request with valid customer ID and valid authorization header", function()

        local res = assert(client:send {
          method  = "GET",
          path    = "/httpbin/xudegui",
          headers = {
            ["Authorization"] = "Bearer XXXXX",
          }
        })
        local body = assert.res_status(200, res)
        local json = cjson.decode(body)

        kong.log.debug(json)
      end)
    end)

    -- describe("wrong authorization header", function()
    --   it("error request with valid customer ID and in-valid authorization header", function()
    --     local res = assert(client:send {
    --       method = "GET",
    --       path = "http://localhost:8000/httpbin/xudegui",
    --       headers = {
    --         ["Authorization"] = "Bearer YYYYY"
    --       }
    --     })

    --     assert.response(res).has.status(200)
    --   end)
    -- end)

    -- describe("wrong authorization user", function()
    --   it("error request with in-valid customer ID and valid authorization header", function()
    --     local res = assert(client:send {
    --       method = "GET",
    --       path = "http://localhost:8000/httpbin/taka",
    --       headers = {
    --         ["Authorization"] = "Bearer XXXXX"
    --       }
    --     })

    --     assert.response(res).has.status(200)
    --   end)
    -- end)

  end)
end
