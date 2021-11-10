// SPDX-FileCopyrightText: 2021 embelon
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
// SPDX-License-Identifier: Apache-2.0

`default_nettype none

module wb_ram_bus_mux
(
`ifdef USE_POWER_PINS
    inout vccd1,	// User area 1 1.8V supply
    inout vssd1,	// User area 1 digital ground
`endif

    // Wishbone UFP (Upward Facing Port)
    input           wb_clk_i,
    input           wb_rst_i,
    input           wbs_ufp_stb_i,
    input           wbs_ufp_cyc_i,
    input           wbs_ufp_we_i,
    input   [3:0]   wbs_ufp_sel_i,
    input   [31:0]  wbs_ufp_dat_i,
    input   [31:0]  wbs_ufp_adr_i,
    output          wbs_ufp_ack_o,
    output  [31:0]  wbs_ufp_dat_o,

    // Wishbone HR (Downward Facing Port) - HyperRAM driver
    output          wbs_hr_stb_o,
    output          wbs_hr_cyc_o,
    output          wbs_hr_we_o,
    output  [3:0]   wbs_hr_sel_o,
    input   [31:0]  wbs_hr_dat_i,
//    output   [31:0]  wbs_or_adr_i,	// address connected directly from UFP
    input           wbs_hr_ack_i,
    output  [31:0]  wbs_hr_dat_o,


    // Wishbone OR (Downward Facing Port) - OpenRAM
    output          wbs_or_stb_o,
    output          wbs_or_cyc_o,
    output          wbs_or_we_o,
    output  [3:0]   wbs_or_sel_o,
    input   [31:0]  wbs_or_dat_i,
//    input   [31:0]  wbs_or_adr_i,	// address connected directly from UFP
    input           wbs_or_ack_i,
    output  [31:0]  wbs_or_dat_o

);

parameter HB_RAM_ADDR_HI_MASK = 16'hff80;
parameter HB_RAM_ADDR_HI = 16'h3000;
parameter HB_REG_CSR_ADDR_HI_MASK = 16'hfffe;
parameter HB_REG_CSR_ADDR_HI = 16'h3080;

parameter OR_ADDR_HI_MASK = 16'hffff;
parameter OR_ADDR_HI = 16'h30c0;

wire [15:0] ufp_adr_hi;
assign ufp_adr_hi = wbs_ufp_adr_i[31:16];

wire hr_select;
assign hr_select = ((ufp_adr_hi & HB_RAM_ADDR_HI_MASK) == HB_RAM_ADDR_HI) || ((ufp_adr_hi & HB_REG_CSR_ADDR_HI_MASK) == HB_REG_CSR_ADDR_HI);

wire or_select;
assign or_select = ((ufp_adr_hi & OR_ADDR_HI_MASK) == OR_ADDR_HI) && !hr_select;

// UFP -> HyperRAM
assign wbs_hr_stb_o = wbs_ufp_stb_i & hr_select;
assign wbs_hr_cyc_o = wbs_ufp_cyc_i;
assign wbs_hr_we_o = wbs_ufp_we_i & hr_select;
assign wbs_hr_sel_o = wbs_ufp_sel_i & {4{hr_select}};
assign wbs_hr_dat_o = wbs_ufp_dat_i & {32{hr_select}};

// UFP -> OpenRAM
assign wbs_or_stb_o = wbs_ufp_stb_i & or_select;
assign wbs_or_cyc_o = wbs_ufp_cyc_i;
assign wbs_or_we_o = wbs_ufp_we_i & or_select;
assign wbs_or_sel_o = wbs_ufp_sel_i & {4{or_select}};
assign wbs_or_dat_o = wbs_ufp_dat_i & {32{or_select}};

// HyperRAM or OpenRAM -> UFP
assign wbs_ufp_ack_o = (wbs_hr_ack_i & hr_select) | (wbs_or_ack_i & or_select);
assign wbs_ufp_dat_o = (wbs_hr_dat_i & {32{hr_select}}) | (wbs_or_dat_i & {32{or_select}});

endmodule	// wb_ram_bus_mux

`default_nettype wire
