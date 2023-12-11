module AXI_ORB720 #
(
    parameter ADDR_WIDTH = 12,
    parameter C_AXIS_TDATA_WIDTH = 32
)
   (
    // input    axi_clk,
    input    axi_Mclk,
    input    axi_reset_n,
    /*
     * AXI slave interface (input to the FIFO)
     */
    input  wire [C_AXIS_TDATA_WIDTH-1:0]  s_axis_data,
    input  wire                   s_axis_valid,
    input  wire    [3:0]          s_axis_keep,
    output                     	  s_axis_ready,////
    // input  wire                   s_axis_last,
    
    output  wire [C_AXIS_TDATA_WIDTH-1:0]  m_axis_data,
    output                    m_axis_valid,
	output wire    [3:0]          m_axis_keep,////
    input  wire                   m_axis_ready,
    /* output reg                   m_axis_last,//// */
	
	//debug ILA
    output ORB_intr,
	output DMA_rst,
	output [1:0] wsta,
	output [9 :0] vga_hs_cnt,
	output [9 :0] vga_vs_cnt,
	output [1 :0] buf_data_state,
    //
	output [39:0] match_data
    );					//
	assign ORB_intr = (DMA_rst == 1'b1 && vga_hs_cnt == 10'd719) ? 1'd1: 1'd0;
					
	reg [1:0] clk50M;	//100 data_rom, 50 sys
	always@(posedge axi_Mclk)
	begin
		clk50M <= clk50M + 2'd1;
	end

    // Instantiate ORB_matching module
    top ORB (
        .reset(DMA_rst), // Connect to DMA_rst
        .video_clk(axi_Mclk), // Connect to axi_clk
		.mode_sw(1'd0),	//8 bits
		.star_up_sw(1'd1),
		.video_gray_out(s_axis_data[7:0]),
		.delay_video_data(s_axis_data[31:24]),
        
		.rout(m_axis_data[31:28]), // Connect to g_out
		.gout(m_axis_data[27:24]), // Connect to g_out
        .bout(m_axis_data[23:20]), // Connect to b_out
		.o_video_minus(open), 	//m_axis_data[7:0]),
		//
		
		.o_vga_hs_cnt(vga_hs_cnt),
		.o_vga_vs_cnt(vga_vs_cnt),
		.o_buf_data_state(buf_data_state),
		.o_match_data(match_data),
		.signal_test(open)
    );

	assign	m_axis_data[19:0] = (clk50M == 1'd0) ? match_data[39:20] : match_data[19:0];
	//Host ignore same pos 
	
	// always@(posedge axi_Mclk)
	// begin	
		// if (!DMA_rst)
			// begin
			// vga_hs_cnt<= 10'd0;
			// vga_vs_cnt<= 10'd0;
			// end
		// else
			// begin
			 // if (vga_hs_cnt < 720)
                 // vga_hs_cnt <= vga_hs_cnt + 1;
             // else
			 // begin
                 // vga_hs_cnt <= 0;
				 // if (vga_vs_cnt < 480)
					 // vga_vs_cnt <= vga_vs_cnt + 1;
				 // else
					 // vga_vs_cnt <= 0;
			// end 
         // end 
	// end
	reg r_s_axis_keep;
	always @(posedge axi_Mclk) begin	// axi_clk and 
        r_s_axis_keep <= s_axis_keep;
	end
	assign m_axis_keep = r_s_axis_keep;
	
	//next page , low trig
	assign DMA_rst = ((s_axis_keep == 4'b1111));// || (m_axis_ready == 1'b1));
				//sta != 2'd3			//DMA_reset = 0 
	reg r_m_axis_keep;
	always @(posedge axi_Mclk) begin
		r_m_axis_keep <= (DMA_rst ) ? 4'b1111 : 4'b0000;
	end 
	
		
	//FSM
	reg [1:0] sta;	
	assign wsta = sta;
	// parameter RxTx = 2'd0;
			  // Rx = 2'd1;
			  // Tx = 2'd2;
			  // narrow = 2'd3;
//	parameter frameSize = 720*480;
	always @(posedge axi_Mclk) begin
        if (!DMA_rst) begin		// |s_axis_keep = 4'b1111)
            sta <= 2'd3;//RxTx;
        end 
		else begin 				
			// if (vga_vs_cnt * 828 + vga_hs_cnt < 240*240/2)
			if (vga_vs_cnt < 480 && vga_hs_cnt <720)
				sta <= 2'd0;//RxTx;
			else if ((vga_vs_cnt * 828 + vga_hs_cnt <720*480) )
				sta <= 2'd1;//Rx;
			else if (vga_vs_cnt < 480 & vga_hs_cnt < 720)
				sta <= 2'd2;//Tx;
			else
				sta <= 2'd3;//narrow;
		end 
	end 

	//s2mm
	reg r_m_axis_valid, r_s_axis_ready;
	assign m_axis_valid = r_m_axis_valid;
	assign s_axis_ready = r_s_axis_ready;
	
	always @(posedge axi_Mclk) begin	// axi_clk and 
        if (!DMA_rst) 
            r_m_axis_valid <= 1'b0;	
		else begin 		
			if (m_axis_ready == 1'b1) 
			begin
				case(sta)
					2'd0:
					begin
					r_m_axis_valid <= 1'b1;  
					end
					2'd1:
					begin
					r_m_axis_valid <= 1'b1;  
					end
					2'd2:
					begin
					r_m_axis_valid <= 1'b1;  
					end
					2'd3:
					begin
					r_m_axis_valid <= 1'b1;  
					end
					default:
					begin
					r_m_axis_valid <= r_m_axis_valid;  
					end
					
				endcase
			end
			else
				r_m_axis_valid <= 1'b0;	
		end
	end	
				
	always @(posedge axi_Mclk) begin	// axi_clk and 
        if (!DMA_rst) begin
			r_s_axis_ready <= 1'b0;
        end 
	else begin 				
			case(sta)
				2'd0:
				begin
				r_s_axis_ready <= 1'b1;
				end
				2'd1:
				begin
				r_s_axis_ready <= 1'b1;	
				end
				2'd2:
				begin
				r_s_axis_ready <= 1'b1;
				end
				2'd3:
				begin
				r_s_axis_ready <= 1'b1;
				end
				default:
				begin
				r_s_axis_ready <= r_s_axis_ready;
				end
				
			endcase
			// end
		end
	end
	
endmodule
