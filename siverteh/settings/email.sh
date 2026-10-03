#!/usr/bin/env bash

if command -v evolution >/dev/null 2>&1; then
    exec evolution
fi

exec google-chrome-stable --app="https://mail.google.com/"
