#include <stdio.h>
#include <stdint.h>

#define MEM_DEPTH 512            
#define ADDER_SIZE 8             

static uint8_t mem[MEM_DEPTH];
static uint8_t wr_op = 0;
static uint8_t rd_op = 0;
static uint8_t dout = 0;
static uint8_t tx_valid = 0;
static uint8_t prev_clk = 0;
static int initialized = 0;


void ram_sim_immediate(int din, int clk, int rst_n, int rx_valid) {
   
    din = din & 0x3FF;
    if (clk) {
        if (!rst_n) {
            
            dout = 0;
            tx_valid = 0;
            wr_op = 0;
            rd_op = 0;
        } else if (rx_valid) {
        
            uint8_t op_code = (din >> 8) & 0x03;
            uint8_t data = din & 0xFF;
            
            switch (op_code) {
                case 0: 
                    wr_op = data;
                    tx_valid = 0;
                    break;
                    
                case 1: 
                    if (wr_op < MEM_DEPTH) {
                        mem[wr_op] = data;
                    }
                    tx_valid = 0;
                    break;
                    
                case 2: 
                    rd_op = data;
                    tx_valid = 0;
                    break;
                    
                case 3: 
                    if (rd_op < MEM_DEPTH) {
                        dout = mem[rd_op];
                    } else {
                        dout = 0;
                    }
                    tx_valid = 1;
                    break;
                    
                default:
                    break;
            }
        }
    }
}

int get_dout_int() {
    return (int)dout;
}

int get_tx_valid_int() {
    return (int)tx_valid;
}
