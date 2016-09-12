#!/bin/bash

while true; do
  inotifywait --exclude \..*\.sw. -re modify .
  clear
  mix test --include integrated
  env MIX_ENV=prod mix escript.build
done
