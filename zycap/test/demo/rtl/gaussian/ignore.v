`timescale 1ns/1ps

// gaussian_ap_fadd_2_full_dsp_32 gaussian_ap_fadd_2_full_dsp_32_u (
//     .aclk                 ( aclk ),
//     .aclken               ( aclken ),
//     .s_axis_a_tvalid      ( a_tvalid ),
//     .s_axis_a_tdata       ( a_tdata ),
//     .s_axis_b_tvalid      ( b_tvalid ),
//     .s_axis_b_tdata       ( b_tdata ),
//     .m_axis_result_tvalid ( r_tvalid ),
//     .m_axis_result_tdata  ( r_tdata )
// );

module gaussian_ap_fadd_2_full_dsp_32 (
    input aclk,
    input aclken,
    input s_axis_a_tvalid,
    input s_axis_a_tdata,
    input s_axis_b_tvalid,
    input s_axis_b_tdata,
    output m_axis_result_tvalid,
    output m_axis_result_tdata);
endmodule


module gaussian_ap_fmul_1_max_dsp_32 (
    input aclk,
    input aclken,
    input s_axis_a_tvalid,
    input s_axis_a_tdata,
    input s_axis_b_tvalid,
    input s_axis_b_tdata,
    output m_axis_result_tvalid,
    output m_axis_result_tdata);
endmodule

module gaussian_ap_fdiv_7_no_dsp_32 (
    input aclk,
    input aclken,
    input s_axis_a_tvalid,
    input s_axis_a_tdata,
    input s_axis_b_tvalid,
    input s_axis_b_tdata,
    output m_axis_result_tvalid,
    output m_axis_result_tdata);
endmodule

module gaussian_ap_sitofp_2_no_dsp_32 (
    input aclk,
    input aclken,
    input s_axis_a_tvalid,
    input s_axis_a_tdata,
    input s_axis_b_tvalid,
    input s_axis_b_tdata,
    output m_axis_result_tvalid,
    output m_axis_result_tdata);
endmodule

module gaussian_ap_fpext_0_no_dsp_32 (
    input aclk,
    input aclken,
    input s_axis_a_tvalid,
    input s_axis_a_tdata,
    input s_axis_b_tvalid,
    input s_axis_b_tdata,
    output m_axis_result_tvalid,
    output m_axis_result_tdata);
endmodule

module gaussian_ap_fcmp_0_no_dsp_32 (
    input aclk,
    input aclken,
    input s_axis_a_tvalid,
    input s_axis_a_tdata,
    input s_axis_operation_tvalid,
    input s_axis_operation_tdata,
    input s_axis_b_tvalid,
    input s_axis_b_tdata,
    output m_axis_result_tvalid,
    output m_axis_result_tdata);
endmodule

module gaussian_ap_fexp_6_full_dsp_32 (
    input aclk,
    input aclken,
    input s_axis_a_tvalid,
    input s_axis_a_tdata,
    input s_axis_b_tvalid,
    input s_axis_b_tdata,
    output m_axis_result_tvalid,
    output m_axis_result_tdata);
endmodule

module gaussian_ap_dadd_3_full_dsp_64 (
    input aclk,
    input aclken,
    input s_axis_a_tvalid,
    input s_axis_a_tdata,
    input s_axis_b_tvalid,
    input s_axis_b_tdata,
    output m_axis_result_tvalid,
    output m_axis_result_tdata);
endmodule

module axis_dwidth_converter_1 (
    input aclk,
    input aresetn,
    input s_axis_tvalid,
    output s_axis_tready,
    input s_axis_tlast,
    input s_axis_tdata,
    output m_axis_tvalid,
    input m_axis_tready,
    output m_axis_tdata,
    output m_axis_tlast);
endmodule














































