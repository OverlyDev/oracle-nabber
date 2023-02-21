#!/bin/bash

cd "/storage" || exit 1

if [ -f ".env" ]; then
    set -a; source ".env"; set +a
fi

if [ "${HELPER}" = true ] || [ "${HELPER}" = "True" ]; then
    echo "Running helper"
    /tmp/helper.sh || exit 1
else
    /tmp/setup.sh || exit 1
    /tmp/run.sh
    
fi

