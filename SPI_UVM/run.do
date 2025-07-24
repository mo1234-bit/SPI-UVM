vlib work
vlog -f src_files.list +cover -covercells
vsim -sv_lib ./libram -voptargs=+acc work.top1 -classdebug -uvmcontrol=all -cover
add wave -position insertpoint  \
sim:/top1/ramif/clk \
sim:/top1/ramif/din \
sim:/top1/ramif/rst_n \
sim:/top1/ramif/rx_valid \
sim:/top1/ramif/dout \
sim:/top1/ramif/tx_valid \
sim:/top1/ramif/dout_ref \
sim:/top1/ramif/tx_valid_ref
run -all

# quit -sim
# vcover report FIFO.ucdb -details -annotate -all -output Coverage_rpt.txt