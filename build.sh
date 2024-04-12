#!/bin/bash

# Run the Python script to flatten cart
python3 flatten_cart.py moonquest.p8 moonquest_compact.p8 4

# Delete build folder and remake it
rm -rf build/
mkdir build

# Move the compacted cart to the build directory
mv moonquest_compact.p8 build/

