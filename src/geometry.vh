localparam[63:0] RAM_BANK_SIZE        = 64'h04_0000_0000;
localparam[63:0] BANK0_BASE_ADDR      = 64'h00_0000_0000;
localparam[63:0] BANK1_BASE_ADDR      = 64'h10_0000_0000;

// Clock frequency of the units that our timestamps are reported in
localparam       RAM_CLOCK_FREQ = 300000000;

// AXI-MM interfaces prefer 4K writes for maximum efficiency
localparam       RAM_BLOCK_SIZE       = 32'h1000;

// Number of data-cycles in a single block of RAM
localparam       CYCLES_PER_RAM_BLOCK = RAM_BLOCK_SIZE / 64;

// The number of "blocks" in a single bank of RAM
localparam       RAM_BLOCKS_PER_BANK  = RAM_BANK_SIZE / RAM_BLOCK_SIZE;
