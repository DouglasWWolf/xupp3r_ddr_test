
//================================================================================================
//    Date      Vers   Who  Changes
// -----------------------------------------------------------------------------------------------
// 04-Jun-2024  1.0.1  DWW  Initial creation
// 08-Jun-2024  1.1.0  DWW  Added run-time configurability of RS-FEC and TX pre-emphasis
// 15-Jun-2024  1.2.0  DWW  Now controlling CMAC gt_txdiffctrl
// 16-Jun-2024  1.3.0  DWW  txpost and txdiff are now programmable
// 30-Jun-2024  1.3.1  DWW  Set SYSTEM_JITTER to 300ps to tighten up timing
//================================================================================================
localparam VERSION_MAJOR = 1;
localparam VERSION_MINOR = 3;
localparam VERSION_BUILD = 1;
localparam VERSION_RCAND = 0;

localparam VERSION_DAY   = 30;
localparam VERSION_MONTH = 6;
localparam VERSION_YEAR  = 2024;

localparam RTL_TYPE      = 642024;
localparam RTL_SUBTYPE   = 0;
