# Example for advanced build system in tarantool

This examle writed for [LuaStakky](https://github.com/LuaStakky/LuaStakky) project



## For deploy use:

`./prod-run.sh up --build`

*or*

`./dev-run.sh up --build`

## for ssl:

1. Write CERTIFICATE and PRIVATE KEY into Certificates file
2. Rewrite security section in like this stakky.yaml

    security:
      allow_http: false
      allow_https: true
      ssl_certificates_file: Certificates
      ssl_session_cache: 10 
      
## default user:

root:toor

for cofigurate see `TarantoolApp\Users\_private\init.lua`