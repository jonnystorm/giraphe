#!/bin/bash

while true; do
  inotifywait --exclude \..*\.sw. -re modify .
  clear
  env MIX_ENV=prod mix escript.build
  mix test --include integrated
done
