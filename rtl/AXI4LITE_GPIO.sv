////////////////////////////////////////////////////////////////////////////////
//
// MIT License
//
// Copyright (c) 2025 Smartfox Data Solutions Inc.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in 
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//
////////////////////////////////////////////////////////////////////////////////

module AXI4LITE_GPIO (
  input			CLK, 
  input			RSTN, 
  input [31:0] 		GPIN,                 
  output[31:0] 		GPOUT,                 
  output		INT,
  
  // write address channel
  input [31:0]		AWADDR,
  input [2:0]		AWPROT,
  input			AWVALID,
  output		AWREADY,
  
  // write data channel
  input [31:0]		WDATA,
  input [3:0]		WSTRB,
  input			WVALID,
  output		WREADY,
  
  // write response channel
  output[1:0]		BRESP,
  output		BVALID,
  input			BREADY,

  // read address channel
  input [31:0]		ARADDR,
  input [2:0]		ARPROT,
  input			ARVALID,
  output		ARREADY,

  // read data channel
  output[31:0]		RDATA,
  output[1:0]		RRESP,
  output		RVALID,
  input			RREADY
);

  wire[7:0]             PWADR;
  wire[31:0]            PWDAT;
  wire	   	        PWRTE;
  wire[7:0]             PRADR;
  wire[31:0]            PRDAT;
  wire                  PERR;

  
  AXI4LITEIF AXI4LITEIF (
    .iCLK		(CLK), 
    .iRSTN		(RSTN),
    
    .iAWADDR		(AWADDR),
    .iAWPROT		(AWPROT),
    .iAWVALID		(AWVALID),
    .oAWREADY		(AWREADY),
    .iWDATA		(WDATA),
    .iWSTRB		(WSTRB),
    .iWVALID		(WVALID),
    .oWREADY		(WREADY),
    .oBRESP		(BRESP),
    .oBVALID		(BVALID),
    .iBREADY		(BREADY),
    .iARADDR		(ARADDR),
    .iARPROT		(ARPROT),
    .iARVALID		(ARVALID),
    .oARREADY		(ARREADY),
    .oRDATA		(RDATA),
    .oRRESP		(RRESP),
    .oRVALID		(RVALID),
    .iRREADY		(RREADY),
    
    .oPWADR		(PWADR),
    .oPWDAT		(PWDAT),
    .oPWRTE		(PWRTE),
    .oPRADR		(PRADR),
    .iPRDAT		(PRDAT),
    .iPERR     		(PERR)
  );
  
  GPCORE GPCORE (
    .iCLK		(CLK), 
    .iRSTN		(RSTN),
    
    .iWADR		(PWADR),
    .iWR		(PWRTE),
    .iWDAT		(PWDAT),
    .iRADR		(PRADR),
    .oRDAT		(PRDAT),
    .oERR		(PERR),

    .iGPIN		(GPIN),
    .oGPOUT		(GPOUT),
    .oINT		(INT)
  );

endmodule
