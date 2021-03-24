`timescale 1 ns / 1 ps

module zycap #
  (
    // Width of S_AXI data bus
    parameter integer C_S_AXI_DATA_WIDTH = 32,
    // Width of S_AXI address bus
    parameter integer C_S_AXI_ADDR_WIDTH = 8
  )
  (
    // PL Ports
    output wire zycap_axis_mux_en,
    output wire zycap_axis_mux_drop,
    output wire [1:0] zycap_axis_mux_sel,
    output wire zycap_icap_rw,
    input  wire zycap_icap_err_status,
    // AXILite Signal
    input wire  s_axi_lite_aclk,
    input wire  s_axi_lite_aresetn,
    input wire [C_S_AXI_ADDR_WIDTH-1 : 0] s_axi_lite_awaddr,
    input wire [2 : 0] s_axi_lite_awprot,
    input wire  s_axi_lite_awvalid,
    output wire  s_axi_lite_awready,
    input wire [C_S_AXI_DATA_WIDTH-1 : 0] s_axi_lite_wdata,
    input wire [(C_S_AXI_DATA_WIDTH/8)-1 : 0] s_axi_lite_wstrb,
    input wire  s_axi_lite_wvalid,
    output wire  s_axi_lite_wready,
    output wire [1 : 0] s_axi_lite_bresp,
    output wire  s_axi_lite_bvalid,
    input wire  s_axi_lite_bready,
    input wire [C_S_AXI_ADDR_WIDTH-1 : 0] s_axi_lite_araddr,
    input wire [2 : 0] s_axi_lite_arprot,
    input wire  s_axi_lite_arvalid,
    output wire  s_axi_lite_arready,
    output wire [C_S_AXI_DATA_WIDTH-1 : 0] s_axi_lite_rdata,
    output wire [1 : 0] s_axi_lite_rresp,
    output wire  s_axi_lite_rvalid,
    input wire  s_axi_lite_rready
    );

  localparam integer ADDR_LSB = (C_S_AXI_DATA_WIDTH/32) + 1;
  localparam integer OPT_MEM_ADDR_BITS = 1;

  // AXI4LITE signals
  reg [C_S_AXI_ADDR_WIDTH-1 : 0]   axi_awaddr;
  reg    axi_awready;
  reg    axi_wready;
  reg [1 : 0]   axi_bresp;
  reg    axi_bvalid;
  reg [C_S_AXI_ADDR_WIDTH-1 : 0]   axi_araddr;
  reg    axi_arready;
  reg [C_S_AXI_DATA_WIDTH-1 : 0]   axi_rdata;
  reg [1 : 0]   axi_rresp;
  reg    axi_rvalid;

  wire   slv_reg_rden;
  wire   slv_reg_wren;
  reg [C_S_AXI_DATA_WIDTH-1:0]   reg_data_out;
  integer   byte_index;

  reg [C_S_AXI_DATA_WIDTH-1:0] slv_reg0;
  reg [C_S_AXI_DATA_WIDTH-1:0] slv_reg1;
  reg [C_S_AXI_DATA_WIDTH-1:0] slv_reg2;


  // I/O Connections assignments
  assign s_axi_lite_awready  = axi_awready;
  assign s_axi_lite_wready  = axi_wready;
  assign s_axi_lite_bresp  = axi_bresp;
  assign s_axi_lite_bvalid  = axi_bvalid;
  assign s_axi_lite_arready  = axi_arready;
  assign s_axi_lite_rdata  = axi_rdata;
  assign s_axi_lite_rresp  = axi_rresp;
  assign s_axi_lite_rvalid  = axi_rvalid;
  // Implement axi_awready generation
  // axi_awready is asserted for one s_axi_lite_aclk clock cycle when both
  // s_axi_lite_awvalid and s_axi_lite_wvalid are asserted. axi_awready is
  // de-asserted when reset is low.

  always @( posedge s_axi_lite_aclk )
  begin
    if ( s_axi_lite_aresetn == 1'b0 )
      begin
        axi_awready <= 1'b0;
      end 
    else
      begin    
        if (~axi_awready && s_axi_lite_awvalid && s_axi_lite_wvalid)
          begin
            // slave is ready to accept write address when 
            // there is a valid write address and write data
            // on the write address and data bus. This design 
            // expects no outstanding transactions. 
            axi_awready <= 1'b1;
          end
        else           
          begin
            axi_awready <= 1'b0;
          end
      end 
  end       

  // Implement axi_awaddr latching
  // This process is used to latch the address when both 
  // s_axi_lite_awvalid and s_axi_lite_wvalid are valid. 

  always @( posedge s_axi_lite_aclk )
  begin
    if ( s_axi_lite_aresetn == 1'b0 )
      begin
        axi_awaddr <= 0;
      end 
    else
      begin    
        if (~axi_awready && s_axi_lite_awvalid && s_axi_lite_wvalid)
          begin
            // Write Address latching 
            axi_awaddr <= s_axi_lite_awaddr;
          end
      end 
  end       

  // Implement axi_wready generation
  // axi_wready is asserted for one s_axi_lite_aclk clock cycle when both
  // s_axi_lite_awvalid and s_axi_lite_wvalid are asserted. axi_wready is 
  // de-asserted when reset is low. 

  always @( posedge s_axi_lite_aclk )
  begin
    if ( s_axi_lite_aresetn == 1'b0 )
      begin
        axi_wready <= 1'b0;
      end 
    else
      begin    
        if (~axi_wready && s_axi_lite_wvalid && s_axi_lite_awvalid)
          begin
            // slave is ready to accept write data when 
            // there is a valid write address and write data
            // on the write address and data bus. This design 
            // expects no outstanding transactions. 
            axi_wready <= 1'b1;
          end
        else
          begin
            axi_wready <= 1'b0;
          end
      end 
  end       

  // Implement memory mapped register select and write logic generation
  // The write data is accepted and written to memory mapped registers when
  // axi_awready, s_axi_lite_wvalid, axi_wready and s_axi_lite_wvalid are asserted. Write strobes are used to
  // select byte enables of slave registers while writing.
  // These registers are cleared when reset (active low) is applied.
  // Slave register write enable is asserted when valid address and data are available
  // and the slave is ready to accept the write address and write data.
  assign slv_reg_wren = axi_wready && s_axi_lite_wvalid && axi_awready && s_axi_lite_awvalid;

  always @( posedge s_axi_lite_aclk )
  begin : axi_write_proc
    reg [OPT_MEM_ADDR_BITS:0] loc_addr;
    if ( s_axi_lite_aresetn == 1'b0 )
      begin
        slv_reg0 <= 0;
        slv_reg1 <= 0;
      end 
    else begin
      loc_addr = axi_awaddr[ADDR_LSB+OPT_MEM_ADDR_BITS:ADDR_LSB];
      if (slv_reg_wren) begin
        if (loc_addr == 2'b00) begin
          for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 ) begin
            if ( s_axi_lite_wstrb[byte_index] == 1 ) begin
              slv_reg0[(byte_index*8) +: 8] <= s_axi_lite_wdata[(byte_index*8) +: 8];
            end
          end
        end
        if (loc_addr == 2'b01) begin
          for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 ) begin
            if ( s_axi_lite_wstrb[byte_index] == 1 ) begin
              slv_reg1[(byte_index*8) +: 8] <= s_axi_lite_wdata[(byte_index*8) +: 8];
            end
          end
        end
      end
    end
  end

  // Implement write response logic generation
  // The write response and response valid signals are asserted by the slave 
  // when axi_wready, s_axi_lite_wvalid, axi_wready and s_axi_lite_wvalid are asserted.  
  // This marks the acceptance of address and indicates the status of 
  // write transaction.

  always @( posedge s_axi_lite_aclk )
  begin
    if ( s_axi_lite_aresetn == 1'b0 )
      begin
        axi_bvalid  <= 0;
        axi_bresp   <= 2'b0;
      end 
    else
      begin    
        if (axi_awready && s_axi_lite_awvalid && ~axi_bvalid && axi_wready && s_axi_lite_wvalid)
          begin
            // indicates a valid write response is available
            axi_bvalid <= 1'b1;
            axi_bresp  <= 2'b0; // 'OKAY' response 
          end                   // work error responses in future
        else
          begin
            if (s_axi_lite_bready && axi_bvalid) 
              //check if bready is asserted while bvalid is high) 
              //(there is a possibility that bready is always asserted high)   
              begin
                axi_bvalid <= 1'b0; 
              end  
          end
      end
  end   

  // Implement axi_arready generation
  // axi_arready is asserted for one s_axi_lite_aclk clock cycle when
  // s_axi_lite_arvalid is asserted. axi_awready is 
  // de-asserted when reset (active low) is asserted. 
  // The read address is also latched when s_axi_lite_arvalid is 
  // asserted. axi_araddr is reset to zero on reset assertion.

  always @( posedge s_axi_lite_aclk )
  begin
    if ( s_axi_lite_aresetn == 1'b0 )
      begin
        axi_arready <= 1'b0;
        axi_araddr  <= 32'b0;
      end 
    else
      begin    
        if (~axi_arready && s_axi_lite_arvalid)
          begin
            // indicates that the slave has acceped the valid read address
            axi_arready <= 1'b1;
            // Read address latching
            axi_araddr  <= s_axi_lite_araddr;
          end
        else
          begin
            axi_arready <= 1'b0;
          end
      end 
  end       

  // Implement axi_arvalid generation
  // axi_rvalid is asserted for one s_axi_lite_aclk clock cycle when both 
  // s_axi_lite_arvalid and axi_arready are asserted. The slave registers 
  // data are available on the axi_rdata bus at this instance. The 
  // assertion of axi_rvalid marks the validity of read data on the 
  // bus and axi_rresp indicates the status of read transaction.axi_rvalid 
  // is deasserted on reset (active low). axi_rresp and axi_rdata are 
  // cleared to zero on reset (active low).  
  always @( posedge s_axi_lite_aclk )
  begin
    if ( s_axi_lite_aresetn == 1'b0 )
      begin
        axi_rvalid <= 0;
        axi_rresp  <= 0;
      end 
    else
      begin    
        if (axi_arready && s_axi_lite_arvalid && ~axi_rvalid)
          begin
            // Valid read data is available at the read data bus
            axi_rvalid <= 1'b1;
            axi_rresp  <= 2'b0; // 'OKAY' response
          end   
        else if (axi_rvalid && s_axi_lite_rready)
          begin
            // Read data is accepted by the master
            axi_rvalid <= 1'b0;
          end                
      end
  end    

  // Implement memory mapped register select and read logic generation
  // Slave register read enable is asserted when valid address is available
  // and the slave is ready to accept the read address.
  assign slv_reg_rden = axi_arready & s_axi_lite_arvalid & ~axi_rvalid;

  always @(*)
  begin
    if ( s_axi_lite_aresetn == 1'b0 )
      begin
        reg_data_out <= 0;
      end 
    else
      begin    
        // Address decoding for reading registers
        case ( axi_araddr[ADDR_LSB+OPT_MEM_ADDR_BITS:ADDR_LSB] )
          2'b00   : reg_data_out <= slv_reg0;
          2'b01   : reg_data_out <= slv_reg1;
          2'b10   : reg_data_out <= slv_reg2;
          default : reg_data_out <= 0;
        endcase
      end   
  end

  // Output register or memory read data
  always @( posedge s_axi_lite_aclk )
  begin
    if ( s_axi_lite_aresetn == 1'b0 )
      begin
        axi_rdata  <= 0;
      end 
    else
      begin    
        // When there is a valid read address (s_axi_lite_arvalid) with 
        // acceptance of read address by the slave (axi_arready), 
        // output the read dada 
        if (slv_reg_rden)
          begin
            axi_rdata <= reg_data_out;     // register read data
          end   
      end
  end

  // Assign registers to control signals
  assign zycap_axis_mux_en   = slv_reg0[0];
  assign zycap_axis_mux_drop = slv_reg0[1];
  assign zycap_axis_mux_sel  = slv_reg0[3:2];
  assign zycap_icap_rw       = slv_reg1[0];

  // Assign status signals to registers
  always@(posedge s_axi_lite_aclk)
  begin : stat_to_reg_proc
    reg [OPT_MEM_ADDR_BITS:0] loc_addr;
    if (s_axi_lite_aresetn == 1'b0) begin
      slv_reg2 <= 0;
    end else begin
      loc_addr = axi_awaddr[ADDR_LSB + OPT_MEM_ADDR_BITS:ADDR_LSB];
      slv_reg2[0] <= zycap_icap_err_status;
    end
  end

endmodule