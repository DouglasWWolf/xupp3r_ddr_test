//====================================================================================
//                        ------->  Revision History  <------
//====================================================================================
//
//   Date     Who   Ver  Changes
//====================================================================================
// 02-Mar-24  DWW     1  Initial creation
//====================================================================================

/*
    Reads back a block of RAM
*/

module fill_ram #
(
    parameter       DW         = 512,
    parameter[3:0]  CHANNEL    = 0
)
(
    (* X_INTERFACE_INFO      = "xilinx.com:signal:clock:1.0 clk CLK"            *)
    (* X_INTERFACE_PARAMETER = "ASSOCIATED_BUSIF M_AXI, ASSOCIATED_RESET reset" *)
    input             clk,
    input             reset,
    output  reg[63:0] elapsed,
    output  reg       idle,

    output  reg[DW-1:0] rdata,

    // When this is asserted, we'll start reading data
    input             start_async,

    //=================   This is the AXI4 output interface   ==================

    // "Specify write address"              -- Master --    -- Slave --
    output     [63:0]                        M_AXI_AWADDR,
    output     [7:0]                         M_AXI_AWLEN,
    output     [2:0]                         M_AXI_AWSIZE,
    output     [3:0]                         M_AXI_AWID,
    output     [1:0]                         M_AXI_AWBURST,
    output                                   M_AXI_AWLOCK,
    output     [3:0]                         M_AXI_AWCACHE,
    output     [3:0]                         M_AXI_AWQOS,
    output     [2:0]                         M_AXI_AWPROT,
    output                                   M_AXI_AWVALID,
    input                                                   M_AXI_AWREADY,

    // "Write Data"                         -- Master --    -- Slave --
    output    [DW-1:0]                      M_AXI_WDATA,
    output    [(DW/8)-1:0]                  M_AXI_WSTRB,
    output                                  M_AXI_WVALID,
    output                                  M_AXI_WLAST,
    input                                                   M_AXI_WREADY,

    // "Send Write Response"                -- Master --    -- Slave --
    input[1:0]                                              M_AXI_BRESP,
    input                                                   M_AXI_BVALID,
    output                                  M_AXI_BREADY,

    // "Specify read address"               -- Master --    -- Slave --
    output[63:0]                            M_AXI_ARADDR,
    output                                  M_AXI_ARVALID,
    output[2:0]                             M_AXI_ARPROT,
    output                                  M_AXI_ARLOCK,
    output[3:0]                             M_AXI_ARID,
    output[2:0]                             M_AXI_ARSIZE,
    output[7:0]                             M_AXI_ARLEN,
    output[1:0]                             M_AXI_ARBURST,
    output[3:0]                             M_AXI_ARCACHE,
    output[3:0]                             M_AXI_ARQOS,
    input                                                   M_AXI_ARREADY,

    // "Read data back to master"           -- Master --    -- Slave --
    input[DW-1:0]                                           M_AXI_RDATA,
    input                                                   M_AXI_RVALID,
    input[1:0]                                              M_AXI_RRESP,
    input                                                   M_AXI_RLAST,
    output                                  M_AXI_RREADY
    //==========================================================================

);

// Include size definitions that descibe our hardware
`include "geometry.vh"

// Determine the base address of our bank of RAM
//localparam[63:0] BASE_ADDR = (CHANNEL==0) ? BANK0_BASE_ADDR : BANK1_BASE_ADDR;
localparam[63:0] BASE_ADDR = 0;

// State machine state 
reg  arsm_state;

// Synchronize "start_async" into "start"
wire start;
cdc_single cdc0(start_async, clk, start);



// Setup unused channels
assign M_AXI_AWVALID = 0;
assign M_AXI_WVALID  = 0;
assign M_AXI_BREADY  = 0;


assign M_AXI_ARID    = 0;
assign M_AXI_ARLOCK  = 0;
assign M_AXI_ARQOS   = 0;
assign M_AXI_ARSIZE  = $clog2(DW/8);
assign M_AXI_ARCACHE = 2; /* Modifiable */
assign M_AXI_ARPROT  = 2; /* Privileged */
assign M_AXI_ARBURST = 1; /* Incr Burst */
assign M_AXI_ARLEN   = CYCLES_PER_RAM_BLOCK - 1;
assign M_AXI_ARSIZE  = $clog2(DW/8);
assign M_AXI_ARVALID = (reset == 0 && arsm_state == 1);


//=============================================================================
// This block sends the neccessary number of read-requests on the AR channel
//=============================================================================

reg[31:0] ar_block_count;
//-----------------------------------------------------------------------------
always @(posedge clk) begin
    if (reset) begin
        arsm_state    <= 0;
    end else case (arsm_state)

        0:  if (start) begin
                ar_block_count <= 1;
                M_AXI_ARADDR   <= BASE_ADDR;
                awsm_state     <= awsm_state + 1;
            end

        1:  if (M_AXI_ARVALID & M_AXI_ARREADY) begin
                if (ar_block_count == RAM_BLOCKS_PER_BANK) begin
                    arsm_state    <= 0;
                end else begin
                    ar_block_count <= ar_block_count + 1;
                    M_AXI_ARADDR   <= M_AXI_ARADDR + RAM_BLOCK_SIZE;
                end
            end

    endcase

end
//=============================================================================



//=============================================================================
assign M_AXI_RREADY = 1;
always @(posedge clk) begin
    if (M_AXI_RVALID & M_AXI_RREADY)
        rdata <= M_AXI_RDATA;
end
//=============================================================================




endmodule