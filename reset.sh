#!/bin/bash

docker compose down

sleep 2

docker volume rm $(docker volume ls -q | grep replica)
