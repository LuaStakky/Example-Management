#!/bin/bash
clear 
python3 -m LuaStakky
if [[ $1 == "up" ]]; then
    # runs "docker-compose up" and then "docker-compose down"
    docker-compose -f docker-compose.default.yaml up "${@:2}"; docker-compose down
elif [[ $1 == "run" ]]; then
    # "d-c run" automatically adds the --rm flag
    docker-compose run --rm "${@:2}"
else
    # any other d-c command runs docker-compose normally
    docker-compose "${@:1}"
fi
