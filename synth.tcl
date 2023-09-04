# Set the working directory to the location of your project
cd /Users/jasonliang/fpu

# Set your project name
set project_name "fpu"

# Create a new project
project_new $project_name -overwrite

# Add Verilog design files to the project
set design_files [list \
    /Users/jasonliang/fpu/multiplier/multiplier.sv \
]

add_file $design_files

set top_module "multiplier"

# Set the top-level module
set_global_assignment -name TOP_LEVEL_ENTITY $top_module

# Set the target FPGA device and family
set_global_assignment -name FAMILY "Cyclone IV E"
set_global_assignment -name DEVICE EP4CE22F17C6

# Run synthesis
execute_flow -compile

# Save and close the project
project_close

# Exit Quartus
exit
