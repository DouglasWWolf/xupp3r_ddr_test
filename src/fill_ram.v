//====================================================================================
//                        ------->  Revision History  <------
//====================================================================================
//
//   Date     Who   Ver  Changes
//====================================================================================
// 02-Mar-24  DWW     1  Initial creation
//====================================================================================

/*
    This fills a block of RAM with a constant byte value
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
    output  reg[31:0] read_duration,

    // When this is asserted, we'll start filling RAM
    input             start_write_async,

    // When this is asserted, we'll start reading  RAM
    input             start_read_async,


    //=================   This is the AXI4 output interface   ==================

    // "Specify write address"              -- Master --    -- Slave --
    output reg [63:0]                        M_AXI_AWADDR,
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
    output reg                              M_AXI_WVALID,
    output                                  M_AXI_WLAST,
    input                                                   M_AXI_WREADY,

    // "Send Write Response"                -- Master --    -- Slave --
    input[1:0]                                              M_AXI_BRESP,
    input                                                   M_AXI_BVALID,
    output                                  M_AXI_BREADY,

    // "Specify read address"               -- Master --    -- Slave --
    output reg [63:0]                       M_AXI_ARADDR,
    output                                  M_AXI_ARVALID,
    output    [2:0]                         M_AXI_ARPROT,
    output                                  M_AXI_ARLOCK,
    output    [3:0]                         M_AXI_ARID,
    output    [7:0]                         M_AXI_ARLEN,
    output    [1:0]                         M_AXI_ARBURST,
    output    [3:0]                         M_AXI_ARCACHE,
    output    [3:0]                         M_AXI_ARQOS,
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

// State machine states 
reg  awsm_state, arsm_state;


// Synchronize "start_write_async" into "start_write"
wire start_write;
cdc_single i_start_write(start_write_async, clk, start_write);


// Synchronize "start_read_async" into "start_read"
wire start_read;
cdc_single i_start_read(start_read_async, clk, start_read);




//=============================================================================
// This block counts the number of AXI-write acknowledgements we receive
//=============================================================================
reg[63:0] write_ack_count;
//-----------------------------------------------------------------------------
assign M_AXI_BREADY = 1;

always @(posedge clk) begin
    if (reset | start_write) 
        write_ack_count <= 0;
    else if (M_AXI_BREADY & M_AXI_BVALID)
        write_ack_count <= write_ack_count + 1;
end
//=============================================================================


// Setup the constant values for the AW channel
assign M_AXI_AWID    = 0;
assign M_AXI_AWLOCK  = 0;
assign M_AXI_AWQOS   = 0;
assign M_AXI_AWSIZE  = $clog2(DW/8);
assign M_AXI_AWCACHE = 2; /* Modifiable */
assign M_AXI_AWPROT  = 2; /* Privileged */
assign M_AXI_AWBURST = 1; /* Incr Burst */
assign M_AXI_AWLEN   = CYCLES_PER_RAM_BLOCK - 1;
assign M_AXI_AWSIZE  = $clog2(DW/8);
assign M_AXI_AWVALID = (reset == 0 && awsm_state == 1);


//=============================================================================
// This block sends the neccessary number of write-requests on the AW channel
//=============================================================================

reg[31:0] aw_block_count;
//-----------------------------------------------------------------------------
always @(posedge clk) begin
    if (reset) begin
        awsm_state    <= 0;
    end else case (awsm_state)

        0:  if (start_write) begin
                aw_block_count <= 1;
                M_AXI_AWADDR   <= BASE_ADDR;
                awsm_state     <= awsm_state + 1;
            end

        1:  if (M_AXI_AWVALID & M_AXI_AWREADY) begin
                if (aw_block_count == RAM_BLOCKS_PER_BANK) begin
                    awsm_state    <= 0;
                end else begin
                    aw_block_count <= aw_block_count + 1;
                    M_AXI_AWADDR   <= M_AXI_AWADDR + RAM_BLOCK_SIZE;
                end
            end

    endcase

end
//=============================================================================


//=============================================================================
// This sends the correct number of AXI bursts to the W-channel
//=============================================================================
reg[ 1:0] wsm_state;
reg[31:0] w_block_count;
reg[ 7:0] cycle_count;
reg[27:0] data;

assign M_AXI_WDATA = {(DW/32){CHANNEL, data}};
assign M_AXI_WSTRB = -1;
assign M_AXI_WLAST = (cycle_count == CYCLES_PER_RAM_BLOCK);

always @(posedge clk) begin

    // Count the number of clock cycles it takes to completely
    // fill our bank of RAM with a constant    
    if (~idle) elapsed <= elapsed + 1;
    
    if (reset) begin
        wsm_state    <= 0;
        M_AXI_WVALID <= 0;
        idle         <= 1;
    end else case (wsm_state)

        // Here we wait for someone to say "go!"
        0:  if (start_write) begin
                idle          <= 0;
                w_block_count <= 1;
                M_AXI_WVALID  <= 1;
                cycle_count   <= 1;
                elapsed       <= 0;
                data          <= 0;
                wsm_state     <= wsm_state + 1;
            end

        1:  if (M_AXI_WVALID & M_AXI_WREADY) begin
                data        <= data + 1;
                cycle_count <= cycle_count + 1;
                if (M_AXI_WLAST) begin
                    if (w_block_count == RAM_BLOCKS_PER_BANK) begin
                        M_AXI_WVALID <= 0;
                        wsm_state    <= wsm_state + 1;
                    end else begin
                        cycle_count   <= 1;
                        w_block_count <= w_block_count + 1;
                    end
                end
            end

        // Here we wait for all of the write-acknowledgements to arrive
        2:  if (write_ack_count == RAM_BLOCKS_PER_BANK) begin
                idle      <= 1;
                wsm_state <= 0;            
            end

    endcase

end
//=============================================================================





// Setup the constant values for the AW channel
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
// This block sends the neccessary number of read-requests on the AW channel
//=============================================================================

reg[31:0] ar_block_count;
//-----------------------------------------------------------------------------
always @(posedge clk) begin
    if (reset) begin
        arsm_state    <= 0;
    end else case (arsm_state)

        0:  if (start_read) begin
                ar_block_count <= 1;
                M_AXI_ARADDR   <= BASE_ADDR;
                arsm_state     <= arsm_state + 1;
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
//  Reads data from M_AXI
//=============================================================================
assign M_AXI_RREADY = (reset == 0);
reg rsm_state;
reg[31:0] r_block_count;


always @(posedge clk) begin

    if (rsm_state) read_duration <= read_duration + 1;

    if (reset) begin
        rsm_state <= 0;
    end
    
    else case(rsm_state)

        0:  if (start_read) begin
                read_duration <= 0;
                r_block_count <= 1;
                rsm_state     <= 1;
            end

        1:  if (M_AXI_RREADY & M_AXI_RVALID & M_AXI_RLAST) begin
                if (r_block_count == RAM_BLOCKS_PER_BANK)
                    rsm_state <= 0;
                else
                    r_block_count <= r_block_count + 1;
            end
    endcase

end
//=============================================================================

endmodule