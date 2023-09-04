# Define the clock period constraint
create_clock -name {clk} -period 10 [get_ports {clk}]

# Specify false paths or multicycle paths (if needed)
# set_false_path -from [get_cells {source_cell}] -to [get_cells {destination_cell}]
# set_multicycle_path -from [get_cells {source_cell}] -to [get_cells {destination_cell}] -setup -end 2