`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 

// Create Date: 30/08/2024 11:45:43 AM
// Design Name: 
// Module Name: ultrasonido
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module ContadorConTrigger(
    input wire clk,          
    output reg trigger      
);
reg [32:0] contador1=0;        //60us=7500000 33 bits=68ms //reg[32:0]
parameter limitcount= 33'd8500000; //limitcount= 33'd8500000;
parameter limittrig = 33'd3000; //10us--24us //limittrig = 33'd3000; //24us--3000
always @(posedge clk)
 begin
 if (contador1<limitcount)
 begin
    contador1<=contador1+1;
    if (contador1 < limittrig) 
	begin
        trigger <= 1'b1;
    end 
	else 
	begin
        trigger <= 1'b0;
    end
 end
else
begin
contador1<=0;
end
end
endmodule

module ContadorConEcho(
    input wire clk,           // Entrada de reloj
    input wire echo,          // Entrada de control (cuando echo=1, se incrementa el contador)
	input wire trigger,
    output reg [32:0] contador2=0 // Salida del contador de 32 bits reg [32:0]
);
always @(posedge clk) 
    begin
		if(echo==1)
			begin
				contador2=contador2+1; //Se va almacenando en un contador si el ultrasonido genera el echo
			end
		else if (trigger)
			begin 
				contador2=0;
			end
	end
endmodule

module Controlmotor(
    input clk,
    input wire [32:0] contador2, //wire [32:0]
    input wire start,
    input wire color,
    output reg motor1in3, led1, motor1in4, motor2in2, motor2in1 
);
//assign  led1 = (contador2>108750000)?1'b1:1'b0;
parameter L1=33'd304500;  //L1=33'd108750; //870us=15cm=108750 50cm=362500}42cm = 304500
always @(posedge clk)  
begin
	if ((contador2>L1) && (start==1'b1))
		  begin
		  if (color==1)
			begin
				motor1in3 <= 1'b1;  //high
				motor1in4 <= 1'b0;  //low
				motor2in1 <= 1'b1;  //low
				motor2in2 <= 1'b0;  //low
				led1 <= 1'b1;
			end
          if (color==0)
			begin
				motor1in3 <= 1'b0;  //high
				motor1in4 <= 1'b1;  //low
				motor2in1 <= 1'b1;  //high
				motor2in2 <= 1'b0;  //low
				led1 <= 1'b0;
			end
	      end
	 if ((contador2<L1) && (start==1'b1))
	       if (color==1)
	       begin
				motor1in3 <= 1'b1;  //high
				motor1in4 <= 1'b0;  //low
				motor2in1 <= 1'b0;  //low
				motor2in2 <= 1'b1;  //low
				led1 <= 1'b1;
			end
	       if (color==0)
	       begin
				motor1in3 <= 1'b1;  //high
				motor1in4 <= 1'b0;  //low
				motor2in1 <= 1'b0;  //low
				motor2in2 <= 1'b1;  //low
				led1 <= 1'b1;
			end		
			
	if (start==0)
	       begin
				motor1in3 <= 1'b0;  //high
				motor1in4 <= 1'b0;  //low
				motor2in1 <= 1'b0;  //low
				motor2in2 <= 1'b0;  //low
				led1 <= 1'b1;
			end   
	   
end	
endmodule

module top(
  input clk,
  input echo,
  input color,
 //input stop,
  input start,
  output trig,
  output motor1in3,
  output led1,
  output motor1in4,
  output motor2in1,
  output motor2in2
);
  wire [32:0] s0; //wire [32;0] sO
  // ContadorConTrigger
  ContadorConTrigger ContadorConTrigger_i0 (
    .clk( clk ),
    .trigger( trig )
  );
  // ContadorConEcho
  ContadorConEcho ContadorConEcho_i1 (
    .clk( clk ),
    .echo( echo ),
	.trigger( trig ),
    .contador2( s0 )
  );
  // ControlLed
  Controlmotor Controlmotor_i2 (
    .clk( clk ),
    .contador2( s0 ),
    .color ( color ),
    .start( start ),
	//.stop( stop ),
    .motor1in3( motor1in3 ),
    .led1( led1 ),
	.motor1in4( motor1in4 ),
	.motor2in1( motor2in1 ),
	.motor2in2( motor2in2 )
  );
endmodule
