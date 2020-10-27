
`timescale 1 ns / 1 ps

	module partial_led_test_v1_0 #
	(
		// Users to add parameters here

		// User parameters ends
		// Do not modify the parameters beyond this line


		// Parameters of Axi Slave Bus Interface S00_AXI
		parameter integer C_S00_AXI_DATA_WIDTH	= 32,
		parameter integer C_S00_AXI_ADDR_WIDTH	= 4
	)
	(
		// Users to add ports here
        output wire [3:0] leds,
		// User ports ends
		// Do not modify the ports beyond this line


		// Ports of Axi Slave Bus Interface S00_AXI
		input wire  s00_axi_aclk,
		input wire  s00_axi_aresetn,
		input wire [C_S00_AXI_ADDR_WIDTH-1 : 0] s00_axi_awaddr,
		input wire [2 : 0] s00_axi_awprot,
		input wire  s00_axi_awvalid,
		output wire  s00_axi_awready,
		input wire [C_S00_AXI_DATA_WIDTH-1 : 0] s00_axi_wdata,
		input wire [(C_S00_AXI_DATA_WIDTH/8)-1 : 0] s00_axi_wstrb,
		input wire  s00_axi_wvalid,
		output wire  s00_axi_wready,
		output wire [1 : 0] s00_axi_bresp,
		output wire  s00_axi_bvalid,
		input wire  s00_axi_bready,
		input wire [C_S00_AXI_ADDR_WIDTH-1 : 0] s00_axi_araddr,
		input wire [2 : 0] s00_axi_arprot,
		input wire  s00_axi_arvalid,
		output wire  s00_axi_arready,
		output wire [C_S00_AXI_DATA_WIDTH-1 : 0] s00_axi_rdata,
		output wire [1 : 0] s00_axi_rresp,
		output wire  s00_axi_rvalid,
		input wire  s00_axi_rready,

		// Ports of AXIS Slave Bus Interface S00_AXIS
		
		input wire [23:0] s_axis_config_tdata,          // input wire [23 : 0] s_axis_config_tdata
		input wire s_axis_config_tvalid,                // input wire s_axis_config_tvalid
		output wire s_axis_config_tready,                // output wire s_axis_config_tready
		input wire [C_S00_AXI_DATA_WIDTH-1:0] s_axis_data_tdata,                      // input wire [31 : 0] s_axis_data_tdata
		input wire s_axis_data_tvalid,                 // input wire s_axis_data_tvalid
		output wire s_axis_data_tready,                    // output wire s_axis_data_tready
		input wire s_axis_data_tlast,                      // input wire s_axis_data_tlast

		// Ports of AXIS Master Bus Interface M00_AXIS

		output wire [C_S00_AXI_DATA_WIDTH-1:0] m_axis_data_tdata,                     // output wire [31 : 0] m_axis_data_tdata
		output wire m_axis_data_tvalid,                    // output wire m_axis_data_tvalid
		input wire m_axis_data_tready,                    // input wire m_axis_data_tready
		output wire m_axis_data_tlast,                      // output wire m_axis_data_tlast

		// Ports of FFT Debug

		output wire event_frame_started,                  // output wire event_frame_started
		output wire event_tlast_unexpected,            // output wire event_tlast_unexpected
		output wire event_tlast_missing,                  // output wire event_tlast_missing
		output wire event_status_channel_halt,      // output wire event_status_channel_halt
		output wire event_data_in_channel_halt,    // output wire event_data_in_channel_halt
		output wire event_data_out_channel_halt  // output wire event_data_out_channel_halt

	);
// Instantiation of Axi Bus Interface S00_AXI
	partial_led_test_v1_0_S00_AXI partial_led_test_v1_0_S00_AXI_inst (
	    .leds(leds),
		.S_AXI_ACLK(s00_axi_aclk),
		.S_AXI_ARESETN(s00_axi_aresetn),
		.S_AXI_AWADDR(s00_axi_awaddr),
		.S_AXI_AWPROT(s00_axi_awprot),
		.S_AXI_AWVALID(s00_axi_awvalid),
		.S_AXI_AWREADY(s00_axi_awready),
		.S_AXI_WDATA(s00_axi_wdata),
		.S_AXI_WSTRB(s00_axi_wstrb),
		.S_AXI_WVALID(s00_axi_wvalid),
		.S_AXI_WREADY(s00_axi_wready),
		.S_AXI_BRESP(s00_axi_bresp),
		.S_AXI_BVALID(s00_axi_bvalid),
		.S_AXI_BREADY(s00_axi_bready),
		.S_AXI_ARADDR(s00_axi_araddr),
		.S_AXI_ARPROT(s00_axi_arprot),
		.S_AXI_ARVALID(s00_axi_arvalid),
		.S_AXI_ARREADY(s00_axi_arready),
		.S_AXI_RDATA(s00_axi_rdata),
		.S_AXI_RRESP(s00_axi_rresp),
		.S_AXI_RVALID(s00_axi_rvalid),
		.S_AXI_RREADY(s00_axi_rready),
		
		.s_axis_config_tdata(s_axis_config_tdata),                  // input wire [23 : 0] s_axis_config_tdata
		.s_axis_config_tvalid(s_axis_config_tvalid),                // input wire s_axis_config_tvalid
		.s_axis_config_tready(s_axis_config_tready),                // output wire s_axis_config_tready
		.s_axis_data_tdata(s_axis_data_tdata),                      // input wire [31 : 0] s_axis_data_tdata
		.s_axis_data_tvalid(s_axis_data_tvalid),                    // input wire s_axis_data_tvalid
		.s_axis_data_tready(s_axis_data_tready),                    // output wire s_axis_data_tready
		.s_axis_data_tlast(s_axis_data_tlast),                      // input wire s_axis_data_tlast

		.m_axis_data_tdata(m_axis_data_tdata),                      // output wire [31 : 0] m_axis_data_tdata
		.m_axis_data_tvalid(m_axis_data_tvalid),                    // output wire m_axis_data_tvalid
		.m_axis_data_tready(m_axis_data_tready),                    // input wire m_axis_data_tready
		.m_axis_data_tlast(m_axis_data_tlast),                      // output wire m_axis_data_tlast

		.event_frame_started(event_frame_started),                  // output wire event_frame_started
		.event_tlast_unexpected(event_tlast_unexpected),            // output wire event_tlast_unexpected
		.event_tlast_missing(event_tlast_missing),                  // output wire event_tlast_missing
		.event_status_channel_halt(event_status_channel_halt),      // output wire event_status_channel_halt
		.event_data_in_channel_halt(event_data_in_channel_halt),    // output wire event_data_in_channel_halt
		.event_data_out_channel_halt(event_data_out_channel_halt)  // output wire event_data_out_channel_halt
	);

	// Add user logic here

	

	// User logic ends

	endmodule

// module partial_led_test_v1_0_S00_AXI
// (
// );

// endmodule
