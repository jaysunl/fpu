# Set the working directory to the location of your design and testbench
cd /Users/jasonliang/fpu

# Compile your Verilog design files
vlog /Users/jasonliang/fpu/multiplier/multiplier.sv

# Compile your Verilog testbench file
vlog /Users/jasonliang/fpu/multiplier/multiplier_tb.sv

# Elaborate the top module of testbench
vsim -c multiplier_tb

# Run the simulation
vsim -c -do "run -all" multiplier_tb

# Generate waveform and exit
vcd file /Users/jasonliang/fpu/multiplier/waveform.vcd
vcd add -r /*
vcd on
run -all
vcd off
quit
