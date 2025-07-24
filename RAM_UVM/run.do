vlib work
vlog -f src_files.list +cover -covercells
vsim -sv_lib ./libram -voptargs=+acc work.top -classdebug -uvmcontrol=all -cover
add wave -position insertpoint  \
sim:/top/clk
add wave -position insertpoint  \
sim:/top/dut/MEM_DEPTH \
sim:/top/dut/ADDER_SIZE \
sim:/top/dut/din \
sim:/top/dut/clk \
sim:/top/dut/rst_n \
sim:/top/dut/rx_valid \
sim:/top/dut/dout \
sim:/top/dut/tx_valid \
sim:/top/dut/mem \
sim:/top/dut/wr_op \
sim:/top/dut/rd_op
run -all
coverage exclude -src RAM.sv -line 36 -code b
coverage exclude -src RAM.sv -line 37 -code s
# quit -sim
# vcover report FIFO.ucdb -details -annotate -all -output Coverage_rpt.txt