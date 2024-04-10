# importing modules
import os
import re
import sys

# Check for correct number of provided arguments
if len(sys.argv) < 3:
    print('usage: `python build.py INPUT_CART.p8 OUTPUT_CART.p8 [optionally TAB_SIZE, default is 1]`')
    exit()

# Get input and output file names
input = sys.argv[1]
output = sys.argv[2]

# Setup tab string for find and replace
tab = ' '       # default tab string
tab_size = 1    # default tab size

# If optional argument included, adjust tab and tab_size variables
if len(sys.argv) == 4:
    tab_size = int(sys.argv[3])
    tab = ''
    for i in range(tab_size):
        tab = tab + ' '

# Logging progress along the way
print('input file = ' + input)
print('output file = ' + output)

# Open files
print(f'opening {input}...')
with open(input, 'r') as file:
    print(f'opening {output}...')
    with open(output, 'w') as result:

        # Go through lines of input file
        for line in file:
            line = line.strip()

            # If the line starts with '#include' then we have a file include
            if line.startswith('#include'):

                # Get the file path written in the include
                include_path = line.split(' ', 1)[1]
                include_path = include_path.strip()
                print(f'found include {include_path}...')

                # Make sure that the file exists
                if os.path.exists(include_path):

                    # Open the included file
                    print(f'opening {include_path}...')
                    with open(include_path, 'r') as include_file:
                        print('writing include to output file...')

                        # The following line puts each file into a tab in the output cart
                        result.write(f'-->8\n--{include_path}\n')
                        for include_line in include_file:

                            # Replace tabs with single spaces and write to file
                            modified_line = re.sub(f'{tab}', ' ', include_line)
                            result.write(modified_line)

                        print('done writing to ouptut.')

                else:
                    print(f'[ERROR] File not found: {include_path}')
                    print('aborting program.')
                    sys.exit(1)
            else:
                result.write(line)
                result.write('\n')
print('process complete. exiting script')
