// (c) Copyright 1995-2020 Xilinx, Inc. All rights reserved.
// 
// This file contains confidential and proprietary information
// of Xilinx, Inc. and is protected under U.S. and
// international copyright and other intellectual property
// laws.
// 
// DISCLAIMER
// This disclaimer is not a license and does not grant any
// rights to the materials distributed herewith. Except as
// otherwise provided in a valid license issued to you by
// Xilinx, and to the maximum extent permitted by applicable
// law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
// WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
// AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
// BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
// INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
// (2) Xilinx shall not be liable (whether in contract or tort,
// including negligence, or under any other theory of
// liability) for any loss or damage of any kind or nature
// related to, arising under or in connection with these
// materials, including for any direct, or any indirect,
// special, incidental, or consequential loss or damage
// (including loss of data, profits, goodwill, or any type of
// loss or damage suffered as a result of any action brought
// by a third party) even if such damage or loss was
// reasonably foreseeable or Xilinx had been advised of the
// possibility of the same.
// 
// CRITICAL APPLICATIONS
// Xilinx products are not designed or intended to be fail-
// safe, or for use in any application requiring fail-safe
// performance, such as life-support or safety devices or
// systems, Class III medical devices, nuclear facilities,
// applications related to the deployment of airbags, or any
// other applications that could lead to death, personal
// injury, or severe property or environmental damage
// (individually and collectively, "Critical
// Applications"). Customer assumes the sole risk and
// liability of any use of Xilinx products in Critical
// Applications, subject only to applicable laws and
// regulations governing limitations on product liability.
// 
// THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
// PART OF THIS FILE AT ALL TIMES.
// 
// DO NOT MODIFY THIS FILE.

#include "test_zynq_ultra_ps_e_0_0_sc.h"

#include "test_zynq_ultra_ps_e_0_0.h"

#include "zynq_ultra_ps_e_tlm.h"

#include <map>
#include <string>

test_zynq_ultra_ps_e_0_0::test_zynq_ultra_ps_e_0_0(const sc_core::sc_module_name& nm) : test_zynq_ultra_ps_e_0_0_sc(nm), maxihpm1_fpd_aclk("maxihpm1_fpd_aclk"), maxigp1_awid("maxigp1_awid"), maxigp1_awaddr("maxigp1_awaddr"), maxigp1_awlen("maxigp1_awlen"), maxigp1_awsize("maxigp1_awsize"), maxigp1_awburst("maxigp1_awburst"), maxigp1_awlock("maxigp1_awlock"), maxigp1_awcache("maxigp1_awcache"), maxigp1_awprot("maxigp1_awprot"), maxigp1_awvalid("maxigp1_awvalid"), maxigp1_awuser("maxigp1_awuser"), maxigp1_awready("maxigp1_awready"), maxigp1_wdata("maxigp1_wdata"), maxigp1_wstrb("maxigp1_wstrb"), maxigp1_wlast("maxigp1_wlast"), maxigp1_wvalid("maxigp1_wvalid"), maxigp1_wready("maxigp1_wready"), maxigp1_bid("maxigp1_bid"), maxigp1_bresp("maxigp1_bresp"), maxigp1_bvalid("maxigp1_bvalid"), maxigp1_bready("maxigp1_bready"), maxigp1_arid("maxigp1_arid"), maxigp1_araddr("maxigp1_araddr"), maxigp1_arlen("maxigp1_arlen"), maxigp1_arsize("maxigp1_arsize"), maxigp1_arburst("maxigp1_arburst"), maxigp1_arlock("maxigp1_arlock"), maxigp1_arcache("maxigp1_arcache"), maxigp1_arprot("maxigp1_arprot"), maxigp1_arvalid("maxigp1_arvalid"), maxigp1_aruser("maxigp1_aruser"), maxigp1_arready("maxigp1_arready"), maxigp1_rid("maxigp1_rid"), maxigp1_rdata("maxigp1_rdata"), maxigp1_rresp("maxigp1_rresp"), maxigp1_rlast("maxigp1_rlast"), maxigp1_rvalid("maxigp1_rvalid"), maxigp1_rready("maxigp1_rready"), maxigp1_awqos("maxigp1_awqos"), maxigp1_arqos("maxigp1_arqos"), emio_gpio_i("emio_gpio_i"), emio_gpio_o("emio_gpio_o"), emio_gpio_t("emio_gpio_t"), emio_uart0_ctsn("emio_uart0_ctsn"), emio_uart0_rtsn("emio_uart0_rtsn"), emio_uart0_dsrn("emio_uart0_dsrn"), emio_uart0_dcdn("emio_uart0_dcdn"), emio_uart0_rin("emio_uart0_rin"), emio_uart0_dtrn("emio_uart0_dtrn"), pl_ps_irq0("pl_ps_irq0"), pl_resetn0("pl_resetn0"), pl_clk0("pl_clk0")
{

  // initialize pins
  mp_impl->maxihpm1_fpd_aclk(maxihpm1_fpd_aclk);
  mp_impl->emio_gpio_i(emio_gpio_i);
  mp_impl->emio_gpio_o(emio_gpio_o);
  mp_impl->emio_gpio_t(emio_gpio_t);
  mp_impl->emio_uart0_ctsn(emio_uart0_ctsn);
  mp_impl->emio_uart0_rtsn(emio_uart0_rtsn);
  mp_impl->emio_uart0_dsrn(emio_uart0_dsrn);
  mp_impl->emio_uart0_dcdn(emio_uart0_dcdn);
  mp_impl->emio_uart0_rin(emio_uart0_rin);
  mp_impl->emio_uart0_dtrn(emio_uart0_dtrn);
  mp_impl->pl_ps_irq0(pl_ps_irq0);
  mp_impl->pl_resetn0(pl_resetn0);
  mp_impl->pl_clk0(pl_clk0);

  // initialize transactors
  mp_M_AXI_HPM1_FPD_transactor = NULL;
}

void test_zynq_ultra_ps_e_0_0::before_end_of_elaboration()
{
  // configure 'M_AXI_HPM1_FPD' transactor
  if (xsc::utils::xsc_sim_manager::getInstanceParameterInt("test_zynq_ultra_ps_e_0_0", "M_AXI_HPM1_FPD_TLM_MODE") != 1)
  {
    xsc::common_cpp::properties M_AXI_HPM1_FPD_transactor_param_props;
    M_AXI_HPM1_FPD_transactor_param_props.addLong("NUM_WRITE_OUTSTANDING", "8");
    M_AXI_HPM1_FPD_transactor_param_props.addLong("NUM_READ_OUTSTANDING", "8");
    M_AXI_HPM1_FPD_transactor_param_props.addLong("DATA_WIDTH", "128");
    M_AXI_HPM1_FPD_transactor_param_props.addLong("FREQ_HZ", "100000000");
    M_AXI_HPM1_FPD_transactor_param_props.addLong("ID_WIDTH", "16");
    M_AXI_HPM1_FPD_transactor_param_props.addLong("ADDR_WIDTH", "40");
    M_AXI_HPM1_FPD_transactor_param_props.addLong("AWUSER_WIDTH", "16");
    M_AXI_HPM1_FPD_transactor_param_props.addLong("ARUSER_WIDTH", "16");
    M_AXI_HPM1_FPD_transactor_param_props.addLong("WUSER_WIDTH", "0");
    M_AXI_HPM1_FPD_transactor_param_props.addLong("RUSER_WIDTH", "0");
    M_AXI_HPM1_FPD_transactor_param_props.addLong("BUSER_WIDTH", "0");
    M_AXI_HPM1_FPD_transactor_param_props.addLong("HAS_BURST", "1");
    M_AXI_HPM1_FPD_transactor_param_props.addLong("HAS_LOCK", "1");
    M_AXI_HPM1_FPD_transactor_param_props.addLong("HAS_PROT", "1");
    M_AXI_HPM1_FPD_transactor_param_props.addLong("HAS_CACHE", "1");
    M_AXI_HPM1_FPD_transactor_param_props.addLong("HAS_QOS", "1");
    M_AXI_HPM1_FPD_transactor_param_props.addLong("HAS_REGION", "0");
    M_AXI_HPM1_FPD_transactor_param_props.addLong("HAS_WSTRB", "1");
    M_AXI_HPM1_FPD_transactor_param_props.addLong("HAS_BRESP", "1");
    M_AXI_HPM1_FPD_transactor_param_props.addLong("HAS_RRESP", "1");
    M_AXI_HPM1_FPD_transactor_param_props.addLong("SUPPORTS_NARROW_BURST", "1");
    M_AXI_HPM1_FPD_transactor_param_props.addLong("MAX_BURST_LENGTH", "256");
    M_AXI_HPM1_FPD_transactor_param_props.addLong("NUM_READ_THREADS", "4");
    M_AXI_HPM1_FPD_transactor_param_props.addLong("NUM_WRITE_THREADS", "4");
    M_AXI_HPM1_FPD_transactor_param_props.addLong("RUSER_BITS_PER_BYTE", "0");
    M_AXI_HPM1_FPD_transactor_param_props.addLong("WUSER_BITS_PER_BYTE", "0");
    M_AXI_HPM1_FPD_transactor_param_props.addFloat("PHASE", "0.000");
    M_AXI_HPM1_FPD_transactor_param_props.addString("PROTOCOL", "AXI4");
    M_AXI_HPM1_FPD_transactor_param_props.addString("READ_WRITE_MODE", "READ_WRITE");
    M_AXI_HPM1_FPD_transactor_param_props.addString("CLK_DOMAIN", "test_zynq_ultra_ps_e_0_0_pl_clk0");
    mp_M_AXI_HPM1_FPD_transactor = new xtlm::xaximm_xtlm2pin_t<128,40,16,16,1,1,16,1>("M_AXI_HPM1_FPD_transactor", M_AXI_HPM1_FPD_transactor_param_props);
    mp_M_AXI_HPM1_FPD_transactor->AWID(maxigp1_awid);
    mp_M_AXI_HPM1_FPD_transactor->AWADDR(maxigp1_awaddr);
    mp_M_AXI_HPM1_FPD_transactor->AWLEN(maxigp1_awlen);
    mp_M_AXI_HPM1_FPD_transactor->AWSIZE(maxigp1_awsize);
    mp_M_AXI_HPM1_FPD_transactor->AWBURST(maxigp1_awburst);
    mp_M_AXI_HPM1_FPD_transactor->AWLOCK(maxigp1_awlock);
    mp_M_AXI_HPM1_FPD_transactor->AWCACHE(maxigp1_awcache);
    mp_M_AXI_HPM1_FPD_transactor->AWPROT(maxigp1_awprot);
    mp_M_AXI_HPM1_FPD_transactor->AWVALID(maxigp1_awvalid);
    mp_M_AXI_HPM1_FPD_transactor->AWUSER(maxigp1_awuser);
    mp_M_AXI_HPM1_FPD_transactor->AWREADY(maxigp1_awready);
    mp_M_AXI_HPM1_FPD_transactor->WDATA(maxigp1_wdata);
    mp_M_AXI_HPM1_FPD_transactor->WSTRB(maxigp1_wstrb);
    mp_M_AXI_HPM1_FPD_transactor->WLAST(maxigp1_wlast);
    mp_M_AXI_HPM1_FPD_transactor->WVALID(maxigp1_wvalid);
    mp_M_AXI_HPM1_FPD_transactor->WREADY(maxigp1_wready);
    mp_M_AXI_HPM1_FPD_transactor->BID(maxigp1_bid);
    mp_M_AXI_HPM1_FPD_transactor->BRESP(maxigp1_bresp);
    mp_M_AXI_HPM1_FPD_transactor->BVALID(maxigp1_bvalid);
    mp_M_AXI_HPM1_FPD_transactor->BREADY(maxigp1_bready);
    mp_M_AXI_HPM1_FPD_transactor->ARID(maxigp1_arid);
    mp_M_AXI_HPM1_FPD_transactor->ARADDR(maxigp1_araddr);
    mp_M_AXI_HPM1_FPD_transactor->ARLEN(maxigp1_arlen);
    mp_M_AXI_HPM1_FPD_transactor->ARSIZE(maxigp1_arsize);
    mp_M_AXI_HPM1_FPD_transactor->ARBURST(maxigp1_arburst);
    mp_M_AXI_HPM1_FPD_transactor->ARLOCK(maxigp1_arlock);
    mp_M_AXI_HPM1_FPD_transactor->ARCACHE(maxigp1_arcache);
    mp_M_AXI_HPM1_FPD_transactor->ARPROT(maxigp1_arprot);
    mp_M_AXI_HPM1_FPD_transactor->ARVALID(maxigp1_arvalid);
    mp_M_AXI_HPM1_FPD_transactor->ARUSER(maxigp1_aruser);
    mp_M_AXI_HPM1_FPD_transactor->ARREADY(maxigp1_arready);
    mp_M_AXI_HPM1_FPD_transactor->RID(maxigp1_rid);
    mp_M_AXI_HPM1_FPD_transactor->RDATA(maxigp1_rdata);
    mp_M_AXI_HPM1_FPD_transactor->RRESP(maxigp1_rresp);
    mp_M_AXI_HPM1_FPD_transactor->RLAST(maxigp1_rlast);
    mp_M_AXI_HPM1_FPD_transactor->RVALID(maxigp1_rvalid);
    mp_M_AXI_HPM1_FPD_transactor->RREADY(maxigp1_rready);
    mp_M_AXI_HPM1_FPD_transactor->AWQOS(maxigp1_awqos);
    mp_M_AXI_HPM1_FPD_transactor->ARQOS(maxigp1_arqos);
    mp_M_AXI_HPM1_FPD_transactor->CLK(maxihpm1_fpd_aclk);
    m_M_AXI_HPM1_FPD_transactor_rst_signal.write(1);
    mp_M_AXI_HPM1_FPD_transactor->RST(m_M_AXI_HPM1_FPD_transactor_rst_signal);

    mp_impl->M_AXI_HPM1_FPD_rd_socket->bind(*(mp_M_AXI_HPM1_FPD_transactor->rd_socket));
    mp_impl->M_AXI_HPM1_FPD_wr_socket->bind(*(mp_M_AXI_HPM1_FPD_transactor->wr_socket));
  }
}

test_zynq_ultra_ps_e_0_0::~test_zynq_ultra_ps_e_0_0()
{
  delete mp_M_AXI_HPM1_FPD_transactor;
}

#ifdef MTI_SYSTEMC
SC_MODULE_EXPORT(test_zynq_ultra_ps_e_0_0);
#endif

#ifdef XM_SYSTEMC
XMSC_MODULE_EXPORT(test_zynq_ultra_ps_e_0_0);
#endif

#ifdef RIVIERA
SC_MODULE_EXPORT(test_zynq_ultra_ps_e_0_0);
#endif
