module VGAMod
(
    input                   CLK,
    input                   nRST,

    input                   PixelClk,

    output                  LCD_DE,
    output                  LCD_HSYNC,
    output                  LCD_VSYNC,

	output          [4:0]   LCD_B,
	output          [5:0]   LCD_G,
	output          [4:0]   LCD_R
);



localparam      V_BackPorch = 16'd1; 
localparam      V_Pluse 	= 16'd5; 
localparam      HightPixel  = 16'd600;
localparam      V_FrontPorch= 16'd2; 

localparam      H_BackPorch = 16'd50; 	
localparam      H_Pluse 	= 16'd1; 
localparam      WidthPixel  = 16'd1024;
localparam      H_FrontPorch= 16'd50;

localparam changeColorFrames = 16'd50;

localparam      PixelForHS  =   WidthPixel + H_BackPorch + H_FrontPorch;  	
localparam      LineForVS   =   HightPixel + V_BackPorch + V_FrontPorch;

reg [15:0] LineCount;
reg [15:0] PixelCount;

reg [4:10] colors;

    always @(  posedge PixelClk or negedge nRST  )begin
        if( !nRST ) begin
            LineCount       <=  16'b0;    
            PixelCount      <=  16'b0;
            end
        else if(  PixelCount  ==  PixelForHS ) begin
            PixelCount      <=  16'b0;
            LineCount       <=  LineCount + 1'b1;
            end
        else if(  LineCount  == LineForVS  ) begin
            LineCount       <=  16'b0;
            PixelCount      <=  16'b0;
            end
        else
            PixelCount      <=  PixelCount + 1'b1;
    end



//Here note the negative polarity of HSYNC and VSYNC
assign  LCD_HSYNC = (( PixelCount >= H_Pluse)&&( PixelCount <= (PixelForHS-H_FrontPorch))) ? 1'b0 : 1'b1;
assign  LCD_VSYNC = ((( LineCount  >= V_Pluse )&&( LineCount  <= (LineForVS-0) )) ) ? 1'b0 : 1'b1;


assign  LCD_DE = (  ( PixelCount >= H_BackPorch )&&
                    ( PixelCount <= PixelForHS-H_FrontPorch ) &&
                    ( LineCount >= V_BackPorch ) &&
                    ( LineCount <= LineForVS-V_FrontPorch-1 ))  ? 1'b1 : 1'b0;
                    //It will shake if there not minus one

assign IS_BORDER = PixelCount == H_BackPorch  ||  PixelCount == H_BackPorch+ WidthPixel - 1
                || LineCount ==   V_BackPorch || LineCount == HightPixel + V_BackPorch   - 1 ;

    localparam          Colorbar_width   =   WidthPixel / 16;

    assign  LCD_B     =  IS_BORDER ? 5'b11111 :
                        ( PixelCount < ( H_BackPorch +  Colorbar_width * 0  )) ? 5'b00000 :
                        ( PixelCount < ( H_BackPorch +  Colorbar_width * 1  )) ? 5'b00001 : 
                        ( PixelCount < ( H_BackPorch +  Colorbar_width * 2  )) ? 5'b00010 :    
                        ( PixelCount < ( H_BackPorch +  Colorbar_width * 3  )) ? 5'b00100 :    
                        ( PixelCount < ( H_BackPorch +  Colorbar_width * 4  )) ? 5'b01000 :    
                        ( PixelCount < ( H_BackPorch +  Colorbar_width * 5  )) ? 5'b11111 :
                        5'b0;

    assign  LCD_G    =  IS_BORDER ? 6'b111111 :
                        ( PixelCount < ( H_BackPorch +  Colorbar_width * 6  )) ? 6'b000001: 
                        ( PixelCount < ( H_BackPorch +  Colorbar_width * 7  )) ? 6'b000010:    
                        ( PixelCount < ( H_BackPorch +  Colorbar_width * 8  )) ? 6'b000100:    
                        ( PixelCount < ( H_BackPorch +  Colorbar_width * 9  )) ? 6'b001000:    
                        ( PixelCount < ( H_BackPorch +  Colorbar_width * 10 )) ? 6'b010000:    
                        ( PixelCount < ( H_BackPorch +  Colorbar_width * 11 )) ? 6'b111111:  6'b000000;

    assign  LCD_R    =  IS_BORDER ? 5'b11111 :
                        ( PixelCount < ( H_BackPorch +  Colorbar_width * 12 )) ? 5'b00001 : 
                        ( PixelCount < ( H_BackPorch +  Colorbar_width * 13 )) ? 5'b00010 :    
                        ( PixelCount < ( H_BackPorch +  Colorbar_width * 14 )) ? 5'b00100 :    
                        ( PixelCount < ( H_BackPorch +  Colorbar_width * 15 )) ? 5'b01000 :    
                        ( PixelCount < ( H_BackPorch +  Colorbar_width * 16 )) ? 5'b11111 :  5'b00000;



endmodule