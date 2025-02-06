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

module AXWRCH (
  input 		iCLK, 
  input			iRSTN, 
  
  input [31:0]		iAWADDR,
  input [31:0]		iWDATA,
  input [3:0]		iWSTRB,
  input			iWVALID,
  output		oWREADY,
  
  input			iARVALID,
  
  output[1:0]		oBRESP,
  output		oBVALID,
  input			iBREADY,
  
  output[7:0]		oPWADR,
  output[31:0]		oPWDAT,
  output                oPWRTE,
  input			iPERR  
);
 
  reg [7:0]		wAddr;
  reg [31:0]		wData;
  reg			wEna;

  reg			wrAct;
  reg			wReady;
  reg [1:0]		bResp, bRespQ;
  reg			bValid;
  
  parameter[1:0]	OKAY   	= 2'b00,
  			SLVERR 	= 2'b10;
  
  parameter		SET	= 1'b1,
  			RESET	= 1'b0;
  
  // to AXI
  assign oWREADY	= wReady;
  assign oBRESP  	= iPERR ? SLVERR : bRespQ;
  assign oBVALID	= bValid;
  
  // to register block
  assign oPWADR		= wAddr;
  assign oPWDAT		= wData;
  assign oPWRTE		= wEna;
    
  // signals to register block
  always @(posedge iCLK or negedge iRSTN) begin
    if (~iRSTN) begin
      wAddr <= 8'h0;
      wData <= 32'h0;
      wEna  <= RESET;
    end
    else begin
      if (iWVALID & ~wrAct) begin
        wAddr <= iAWADDR[7:0];
        wData <= iWDATA;
        wEna  <= &iWSTRB;
      end
      else begin
      	wAddr <= 8'h0;
      	wData <= 32'h0;
      	wEna  <= RESET;
      end
    end 
  end

  // signals to AXI
  always @(posedge iCLK or negedge iRSTN) begin
    if (~iRSTN) begin
      wReady <= SET;
      wrAct  <= RESET;
      bResp  <= OKAY;
      bRespQ <= OKAY;
      bValid <= RESET;
    end
    else begin      
      // reset write active if read valid is received
      wReady <= iARVALID ? RESET : SET;
      
      // register resp to make timing as iPERR
      bRespQ <= bResp;
      
      if (~wrAct) begin
        wrAct <= iWVALID;
      end
      else begin
        if (~bValid) begin
          bValid <= SET;
          bResp	 <= &iWSTRB ? OKAY : SLVERR;
        end
        else begin
          if (iBREADY) begin
            bValid <= RESET;
            bResp  <= OKAY;
            wrAct  <= RESET;
          end
        end
      end
    end 
  end
  
endmodule