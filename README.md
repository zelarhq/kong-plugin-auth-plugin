# Plugin Creation Steps

## Install Pongo CLI

```
PATH=$PATH:~/.local/bin
git clone https://github.com/Kong/kong-pongo.git
mkdir -p ~/.local/bin
ln -s $(realpath kong-pongo/pongo.sh) ~/.local/bin/pongo
```
## Clone the template plugin from Kong GITHUB

```
git clone https://github.com/Kong/kong-plugin.git kong-api-version-plugin

pongo run
 - To initialise the docker images for postgres, cassandra and kong library`
```

## Create a new folder with only the basic files of plugin

- kong / plugins / auth-plugin
  - handler.lua
  - schema.lua
  - access.lua
- spec / auth-plugin
  - 01-api_spec.lua
- kong-plugin-auth-plugin-0.1.0-1.rockspec
- README.md

## Run the new plugin shell with kong and pongo

- pongo up
- pongo shell

- kong version
- kong migrations bootstrap --force
- kong start

# Assessment Steps

### Use a default kong service in docker
```
docker run --name custom-auth -d -it -p 8080:8080 xudegui/authservice
```

```
http://192.168.1.118:8080/auth/validate/token

http://192.168.1.118:8080/auth/validate/customer
```

### Test endpoints of the service
```
http post http://192.168.1.118:8080/auth/validate/token Authorization:'Bearer YYYY'
```
`access denied error`

```
http post http://192.168.1.118:8080/auth/validate/customer Authorization:'Bearer XXXXX' custId="xudegui"
```
`success`

### List plugins

```
curl http://localhost:8001/plugins
```

## Adding services and routes to kong

```
http post localhost:8001/services name=httpbin url=http://httpbin.org/anything
```
```
http post localhost:8001/services/httpbin/routes paths:='["/httpbin"]'
```

### Verify endpoint
```
http :8000/httpbin
```

## Add our auth plugin to the service

```
http post localhost:8001/services/httpbin/plugins name=auth-plugin config:='{ "authorization_endpoint":"http://192.168.1.118:8080/auth/validate/customer", "introspection_endpoint":"http://192.168.1.118:8080/auth/validate/token" }'
```

## Testing new plugin
```
http localhost:8000/httpbin/xudegui Authorization:'Bearer XXXXX'
```
`success`

```
http localhost:8000/httpbin/xudegui Authorization:'Bearer YYYYY'
```
`error`
```
http localhost:8000/httpbin/taka Authorization:'Bearer XXXXX'
```
`error`
```
http localhost:8000/httpbin/taka Authorization:'Bearer YYYYY'
```
`error`
