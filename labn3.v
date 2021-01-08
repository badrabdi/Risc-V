module labN; 
wire [31:0] PCin; 
reg clk;
wire [1:0] ALUop;
wire [5:0] fnCode;
wire [2:0] op; 
wire [5:0] opCode;
wire RegDst, RegWrite, ALUSrc, Mem2Reg, MemRead, MemWrite, beq, j, rtype;
reg  [31:0] entryPoint;
wire [31:0] wd, rd1, rd2, imm, ins, PCp4, z; 
wire [25:0] jTarget; 
wire zero;
reg INT;  
wire [31:0] memOut, wb;

yIF myIF(ins, PCp4, PCin, clk); 
yID myID(rd1, rd2, imm, jTarget, ins, wd, RegDst, RegWrite, clk); 
yEX myEx(z, zero, rd1, rd2, imm, op, ALUSrc); 
yDM myDM(memOut, z, rd2, clk, MemRead, MemWrite); 
yWB myWB(wb, z, memOut, Mem2Reg); 
yPC myPC(PCin, PCp4, INT, entryPoint, imm, jTarget, zero, beq, j);
assign wd = wb;  
assign opCode = ins[31:26];
yC1 myC1(rtype, lw, sw, j, beq, opCode);
yC2 myC2(RegDst, ALUSrc, RegWrite, Mem2Reg, MemRead, MemWrite, rtype, lw, sw, beq, j);

assign fnCode = ins[5:0];
yC3 myC3(ALUop, rtype, beq);
yC4 myC4(op, ALUop, fnCode);



initial 
	begin 
	 //------------------------------------Entry point 
	   entryPoint = 128; INT = 1; #1;
	 //------------------------------------Run program 
	 repeat (43) 
	 begin 
	  //---------------------------------Fetch an ins 
	      clk = 1; #1; INT = 0;
	  //---------------------------------Set control signals 
	     // RegDst = 0; RegWrite = 0; ALUSrc = 1; MemRead = 0; MemWrite = 0; Mem2Reg = 0; 
	      //op = 3'b010; 
	      //beq = 0; j = 0;
	      // Add statements to adjust the above defaults 
	      //if (ins[31:26] == 0) //Rtype
		// begin 
		// MemRead = 0; MemWrite = 0; Mem2Reg = 0;
		  // RegDst = 1; RegWrite = 1; ALUSrc = 0;
		  // if (ins[5:0] == 37) //op = 3'b001;  
		 //end 
	      //else if(ins[31:26]==2)//J
	      	// begin
	      	   //RegDst = 0; RegWrite = 0; ALUSrc = 1;
	      	   //MemRead = 0; MemWrite = 0; Mem2Reg = 0;
	      	   //j=1;
	      	 //end 		 
	     // else
	         // begin
	          //	if (ins[31:26] == 4) //beq
	          //	begin 
	            	//RegDst = 0; RegWrite = 0; ALUSrc = 0;
	            	//op = 3'b110;
	            	//MemRead = 0; MemWrite = 0; Mem2Reg = 0;
	            	//beq = 1;
	            //	end
	            	//else if (ins[31:26] == 43)//sw
	            	//begin 
	            	//MemRead = 0; MemWrite = 1; Mem2Reg = 0;
	            	//RegDst = 0; RegWrite = 0; ALUSrc = 1;
	            	//end 
	            //	else if (ins[31:26] === 35) // load word
			//begin
			//	RegDst = 0; RegWrite = 1; ALUSrc = 1;
			//	MemRead = 1; MemWrite = 0; Mem2Reg = 1;
			//end
			//else
			//begin //addi 
			//	MemRead = 0; MemWrite = 0; Mem2Reg = 0;
			  //  	RegDst = 0; RegWrite = 1; ALUSrc = 1;
			//end
	             
	          //end	 
	  //---------------------------------Execute the ins       
	      clk = 0; #1; 
	  //---------------------------------View results 
	  
	   $display("%h: rd1= %2d, rd2= %2d, imm=%h, jTarget= %h, z= %3d, zero= %b", ins, rd1, rd2, imm, jTarget, z, zero);
	  
	  //---------------------------------Prepare for the next ins 
	//  if (INT == 1)
		//PCin = entryPoint;
	  
	  //else 
	  //	if (beq && zero === 1)
		//	PCin = PCp4 + (imm << 2);
		//else if (j)
		//	PCin = jTarget << 2;
		//else
	  	//	PCin = PCp4; 
	 end 
	 $finish; 
	end 
		//always
			//begin
			//#1 clk=~clk;
			//end 	
 
endmodule 
