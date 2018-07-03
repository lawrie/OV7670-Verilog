`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    21:12:24 12/03/2014 
// Design Name: 
// Module Name:    camera_read 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module camera_read(
	input wire clk,
	output wire x_clock,
	input wire p_clock,
	input wire vsync,
        output vsync_copy,
	input wire href,
        output href_copy,
	input wire [7:0] p_data,
	//output reg [15:0] pixel_data =0,
	output reg pixel_valid = 0,
	output reg frame_done,
	output wire DIGIT,
	output wire [6:0] SEG
    );

	
   reg [1:0]  clkpre = 2'b00;     // prescaler, from 100MHz to 25MHz
   reg [7:0] first_byte, second_byte;
   reg [9:0] row_count, col_count;
   reg start_of_frame = 0;
   reg [15:0] pixel_data;
   reg [7:0] data;
   reg [27:0] avg;

   assign vsync_copy = vsync;
   assign href_copy = href;

        display_7_seg d2 (.CLK(clk), .n(data), .SEG(SEG), .DIGIT(DIGIT));

        always @(posedge clk)
        begin
           clkpre <= clkpre + 1;
        end

	assign x_clock = clkpre[1];
	
	reg [1:0] FSM_state = 0;
        reg pixel_half = 0;
	
	localparam WAIT_FRAME_START = 0;
	localparam ROW_CAPTURE = 1;
	
	
	always@(posedge p_clock)
	begin 
	
	case(FSM_state)
	
	WAIT_FRAME_START: begin //wait for VSYNC
	   FSM_state <= (!vsync) ? ROW_CAPTURE : WAIT_FRAME_START;
	   frame_done <= 0;
	   pixel_half <= 0;
           start_of_frame <= 1;
           row_count <= 0;
           col_count <= 0;
           avg <= 0;
	end
	
	ROW_CAPTURE: begin 
	   FSM_state <= vsync ? WAIT_FRAME_START : ROW_CAPTURE;
           //if (vsync) data = col_count[9:2];
           if (vsync) data <= avg[26:19];
	   frame_done <= vsync;
	   pixel_valid <= (href && pixel_half); 
	   if (href) begin
               if (start_of_frame) begin
                  if (!pixel_half) begin
                    first_byte <= p_data;
                    //data <= p_data;
                  end 
                  else begin
                    start_of_frame <= 0;
                    second_byte <= p_data;
                    //data <= p_data;
                  end
               end
	       if (pixel_half) pixel_data[7:0] <= p_data;
	       else pixel_data[15:8] <= p_data;
               if (pixel_half) avg <= avg + p_data;
               if (pixel_half) row_count <= row_count + 1;
	       pixel_half <= ~ pixel_half;
	   end else begin
             //if (row_count != 0) data <= row_count[9:2];
             row_count <= 0;
             if (row_count != 0) col_count <= col_count + 1;
           end
	end
	
	
	endcase
	end
	
endmodule
