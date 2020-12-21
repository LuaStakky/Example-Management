# Example for advanced build system in tarantool

This examle writed for [LuaStakky](https://github.com/LuaStakky/LuaStakky) project.

GUI for it you can find [here](https://github.com/LuaStakky/Example-Management-DesktopGUI).

Import InsomniaAPIRef.json into Insomnia to see API Ref of project and test it.

## What can do this project?

* It can connect to an Redmine instances and create report about workers payment.
* It use info about hourly payment, stored in tarantool.
* It automaticaly save reports in tarantool.
* It save currency for each worker and automaticaly convert it.

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

email: examlpe@examlpe.com
password: toor

for cofigurate see `TarantoolApp\Users\_private\init.lua`