#!/bin/bash

if [ -z $1 ]; then
    MAX=10
else
    MAX=${1}
fi
for ((i = 1; i <= ${MAX}; i++ ));
do
    echo "Run ${i}"
    rm -rf build/
    # QEMUARCH=aarch64 make -j 40 clean
    QEMUARCH=aarch64 make -j
    if [ $? -ne 0 ]; then
        echo "Race condition found ${i}"
        exit 1
    fi
done
echo "Success"
