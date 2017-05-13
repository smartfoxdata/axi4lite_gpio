////////////////////////////////////////////////////////////////////////////////
//
// MIT License
//
// Copyright (c) 2017 Smartfox Data Solutions Inc.
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

module AXI4LITEIF (
  input			iCLK, 
  input			iRSTN,
  
  // write address channel
  input [3:0]		iAWID,
  input [31:0]		iAWADDR,   //AXI4-Lite
  input [3:0]		iAWLEN,
  input [2:0]		iAWSIZE,
  input [1:0]		iAWBURST,
  input [1:0]		iAWLOCK,
  input [3:0]		iAWCACHE,
  input [2:0]		iAWPROT,   //AXI4-Lite
  input			iAWQOS,
  input			iAWREGION,
  input			iAWVALID,  //AXI4-Lite
  output		oAWREADY,  //AXI4-Lite
  
  // write data channel
  input [3:0]		iWID,
  input [31:0]		iWDATA,    //AXI4-Lite
  input [3:0]		iWSTRB,    //AXI4-Lite
  input			iWLAST,
  input			iWVALID,   //AXI4-Lite
  output		oWREADY,   //AXI4-Lite
  
  // write response channel
  output[3:0]		oBID,
  output[1:0]		oBRESP,    //AXI4-Lite
  output		oBVALID,   //AXI4-Lite
  input			iBREADY,   //AXI4-Lite
  
  // read address channel
  input [3:0]		iARID,
  input [31:0]		iARADDR,   //AXI4-Lite
  input [3:0]		iARLEN,
  input [2:0]		iARSIZE,
  input [1:0]		iARBURST,
  input [1:0]		iARLOCK,
  input [3:0]		iARCACHE,
  input [2:0]		iARPROT,   //AXI4-Lite
  input			iARQOS,
  input			iARREGION,
  input			iARVALID,  //AXI4-Lite
  output		oARREADY,  //AXI4-Lite

  // read data channel
  output[3:0]		oRID,
  output[31:0]		oRDATA,    //AXI4-Lite
  output[1:0]		oRRESP,    //AXI4-Lite
  output		oRLAST,
  output		oRVALID,   //AXI4-Lite
  input			iRREADY,   //AXI4-Lite
  
  // interface to register block
  output[7:0]		oPWADR,
  output[31:0]		oPWDAT,
  output                oPWRTE,
  output[7:0]		oPRADR,
  input[31:0]		iPRDAT,
  input			iPERR  
);
  
  //AXI4-Lite
  // - all transactions are of burst lenght 1
  // - all data accesses use the full width of the data bus (32bit or 64bit)
  // - all accesses are non-modifiable, non-bufferable
  // - exclusive accesses are not supported
  AXADRCHSM WRADRCH (
    .iCLK		(iCLK), 
    .iRSTN		(iRSTN),

    .iADDR		(iAWADDR),
    .iPROT		(iAWPROT),
    .iVALID		(iAWVALID),
    .oREADY		(oAWREADY),
    
    .iBUSY		(iARVALID & ~iAWVALID)
  );
  
  AXWRCH WRDATCH (
    .iCLK		(iCLK), 
    .iRSTN		(iRSTN),

    .iAWADDR		(iAWADDR),
    .iWDATA		(iWDATA),
    .iWSTRB		(iWSTRB),
    .iWVALID		(iWVALID),
    .oWREADY		(oWREADY),
    
    .iARVALID		(iARVALID),
  
    .oBRESP		(oBRESP),
    .oBVALID		(oBVALID),
    .iBREADY		(iBREADY),
    
    .oPWADR		(oPWADR),
    .oPWDAT		(oPWDAT),
    .oPWRTE		(oPWRTE),
    .iPERR		(iPERR)
  );

  AXADRCHSM RDADRCH (
    .iCLK		(iCLK), 
    .iRSTN		(iRSTN),

    .iADDR		(iARADDR),
    .iPROT		(iARPROT),
    .iVALID		(iARVALID),
    .oREADY		(oARREADY),
    
    .iBUSY		(iAWVALID)
  );

 AXRDCH RDDATCH (
    .iCLK		(iCLK), 
    .iRSTN		(iRSTN),
  
    .iARADDR		(iARADDR),
    .iARVALID		(iARVALID),
  
    .oRDATA		(oRDATA),
    .oRRESP		(oRRESP),
    .oRVALID		(oRVALID),
    .iRREADY		(iRREADY),
  
    .oPRADR		(oPRADR),
    .iPRDAT		(iPRDAT),
    .iPERR		(iPERR)
);
  
endmodule
