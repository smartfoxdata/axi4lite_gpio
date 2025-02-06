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

module GPCORE (
  input			iCLK,
  input			iRSTN,
  input [7:0] 		iWADR,
  input			iWR,
  input [31:0] 		iWDAT,
  input [7:0] 		iRADR,
  output[31:0] 		oRDAT, 

  input [31:0] 		iGPIN,
  output[31:0] 		oGPOUT,
  output		oINT,
  
  output		oERR
);
  
  reg[31:0]		rGpDat;
  reg[31:0]		rGpDir;
  reg			rGpIen;
  reg			rGpInt;
  reg			rGpClr;

  reg[7:0]		regAdr;
  reg[31:0]		regDat, regDatQ;
  reg			isErr, isErrQ;
  
  wire[31:0]		gpInDir;
  reg                   gpInt;
  
  parameter[7:0]	GPDAT = 8'h0,
  			GPDIR = 8'h1,
  			GPIEN = 8'h2,
  			GPINT = 8'h3;
  
  assign oRDAT 		= regDatQ;
  assign oERR 		= isErrQ;
  assign oINT		= rGpInt;
  assign oGPOUT		= rGpDat & ~rGpDir;

  // interrupt logic
  assign gpInDir 	= rGpDir & iGPIN;
  always @* gpInt	= (rGpIen & |gpInDir);
  always @(posedge iCLK or negedge iRSTN) begin
    if (~iRSTN) begin
      rGpInt <=  1'b0;
    end
    else begin
      if (~rGpInt) begin             
        rGpInt <= gpInt;
      end
      else begin
        rGpInt <= ~rGpClr;
      end      
    end
  end  
  
  // select address
  always @* regAdr = iWR ? iWADR : iRADR;
  
  // write to register
  always @(posedge iCLK or negedge iRSTN) begin
    if (~iRSTN) begin
      rGpDat <= 32'h0;
      rGpDir <= 32'h0;
      rGpIen <=  1'b0;
      rGpInt <=  1'b0;
      rGpClr <=  1'b0;
    end
    else begin
	  case (regAdr)
        GPDAT: begin
          if (iWR) rGpDat <= iWDAT & ~rGpDir;
        end
        GPDIR: begin
          if (iWR) rGpDir <= iWDAT;
        end
        GPIEN: begin
          if (iWR) rGpIen <= iWDAT[0];
        end
        GPINT: begin
          if (iWR) rGpClr <= iWDAT[0] & rGpInt;
        end
        default: begin
        end
      endcase
    end 
  end  
  
  // register access status
  always @* begin
    isErr = 1'b0;
    case (regAdr)
      GPDAT,
      GPDIR,
      GPIEN,
      GPINT:   isErr = 1'b0;
      default: isErr = iWR;
    endcase
  end
  
  // read from register
  always @* begin
    regDat = 32'h0;
    case (regAdr)
      GPDAT:   regDat = rGpDat;
      GPDIR:   regDat = rGpDir;
      GPIEN:   regDat = {31'h0, rGpIen};
      GPINT:   regDat = {31'h0, rGpInt};
      default: regDat = 32'h0;
    endcase
  end
  
  // register outputs
  always @(posedge iCLK or negedge iRSTN) begin
    if (~iRSTN) begin
      isErrQ  <= 1'b0;
      regDatQ <= 32'h0;
    end
    else begin
      isErrQ  <= isErr;
      regDatQ <= regDat;
    end 
  end
  
endmodule