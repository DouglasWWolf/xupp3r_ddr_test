//Copyright 1986-2021 Xilinx, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2021.1 (lin64) Build 3247384 Thu Jun 10 19:36:07 MDT 2021
//Date        : Wed Jul 24 16:31:46 2024
//Host        : simtool-5 running 64-bit Ubuntu 20.04.6 LTS
//Command     : generate_target top_level_wrapper.bd
//Design      : top_level_wrapper
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

module top_level_wrapper
   (m0_ddr4_act_n,
    m0_ddr4_adr,
    m0_ddr4_ba,
    m0_ddr4_bg,
    m0_ddr4_ck_c,
    m0_ddr4_ck_t,
    m0_ddr4_cke,
    m0_ddr4_clk_clk_n,
    m0_ddr4_clk_clk_p,
    m0_ddr4_cs_n,
    m0_ddr4_dq,
    m0_ddr4_dqs_c,
    m0_ddr4_dqs_t,
    m0_ddr4_odt,
    m0_ddr4_par,
    m0_ddr4_reset_n,
    pcie_mgt_rxn,
    pcie_mgt_rxp,
    pcie_mgt_txn,
    pcie_mgt_txp,
    pcie_refclk_clk_n,
    pcie_refclk_clk_p);
  output m0_ddr4_act_n;
  output [16:0]m0_ddr4_adr;
  output [1:0]m0_ddr4_ba;
  output [1:0]m0_ddr4_bg;
  output [0:0]m0_ddr4_ck_c;
  output [0:0]m0_ddr4_ck_t;
  output [0:0]m0_ddr4_cke;
  input m0_ddr4_clk_clk_n;
  input m0_ddr4_clk_clk_p;
  output [0:0]m0_ddr4_cs_n;
  inout [71:0]m0_ddr4_dq;
  inout [17:0]m0_ddr4_dqs_c;
  inout [17:0]m0_ddr4_dqs_t;
  output [0:0]m0_ddr4_odt;
  output m0_ddr4_par;
  output m0_ddr4_reset_n;
  input [15:0]pcie_mgt_rxn;
  input [15:0]pcie_mgt_rxp;
  output [15:0]pcie_mgt_txn;
  output [15:0]pcie_mgt_txp;
  input [0:0]pcie_refclk_clk_n;
  input [0:0]pcie_refclk_clk_p;

  wire m0_ddr4_act_n;
  wire [16:0]m0_ddr4_adr;
  wire [1:0]m0_ddr4_ba;
  wire [1:0]m0_ddr4_bg;
  wire [0:0]m0_ddr4_ck_c;
  wire [0:0]m0_ddr4_ck_t;
  wire [0:0]m0_ddr4_cke;
  wire m0_ddr4_clk_clk_n;
  wire m0_ddr4_clk_clk_p;
  wire [0:0]m0_ddr4_cs_n;
  wire [71:0]m0_ddr4_dq;
  wire [17:0]m0_ddr4_dqs_c;
  wire [17:0]m0_ddr4_dqs_t;
  wire [0:0]m0_ddr4_odt;
  wire m0_ddr4_par;
  wire m0_ddr4_reset_n;
  wire [15:0]pcie_mgt_rxn;
  wire [15:0]pcie_mgt_rxp;
  wire [15:0]pcie_mgt_txn;
  wire [15:0]pcie_mgt_txp;
  wire [0:0]pcie_refclk_clk_n;
  wire [0:0]pcie_refclk_clk_p;

  top_level top_level_i
       (.m0_ddr4_act_n(m0_ddr4_act_n),
        .m0_ddr4_adr(m0_ddr4_adr),
        .m0_ddr4_ba(m0_ddr4_ba),
        .m0_ddr4_bg(m0_ddr4_bg),
        .m0_ddr4_ck_c(m0_ddr4_ck_c),
        .m0_ddr4_ck_t(m0_ddr4_ck_t),
        .m0_ddr4_cke(m0_ddr4_cke),
        .m0_ddr4_clk_clk_n(m0_ddr4_clk_clk_n),
        .m0_ddr4_clk_clk_p(m0_ddr4_clk_clk_p),
        .m0_ddr4_cs_n(m0_ddr4_cs_n),
        .m0_ddr4_dq(m0_ddr4_dq),
        .m0_ddr4_dqs_c(m0_ddr4_dqs_c),
        .m0_ddr4_dqs_t(m0_ddr4_dqs_t),
        .m0_ddr4_odt(m0_ddr4_odt),
        .m0_ddr4_par(m0_ddr4_par),
        .m0_ddr4_reset_n(m0_ddr4_reset_n),
        .pcie_mgt_rxn(pcie_mgt_rxn),
        .pcie_mgt_rxp(pcie_mgt_rxp),
        .pcie_mgt_txn(pcie_mgt_txn),
        .pcie_mgt_txp(pcie_mgt_txp),
        .pcie_refclk_clk_n(pcie_refclk_clk_n),
        .pcie_refclk_clk_p(pcie_refclk_clk_p));
endmodule
