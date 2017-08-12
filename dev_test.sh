#!/bin/bash

while true; do
  inotifywait --exclude \..*\.sw. -re modify .
  clear
  mix test --include integrated &&
    MIX_ENV=test mix dialyzer --halt-exit-status

  MIX_ENV=prod mix escript.build
done
