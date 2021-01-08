module yAdder1(z, cout, a, b, cin); 
	output z, cout; 
	input a, b, cin; 
	xor left_xor(tmp, a, b); 
	xor right_xor(z, cin, tmp); 
	and left_and(outL, a, b); 
	and right_and(outR, tmp, cin); 
	or my_or(cout, outR, outL); 
endmodule 


module yAdder(z, cout, a, b, cin); 
	output signed [31:0] z; 
	output cout; 
	input signed [31:0] a, b; 
	input cin; 
	wire [31:0] in, out; 
	yAdder1 mine[31:0](z, out, a, b, in); 
	assign in[0] = cin; 
	assign in[1] = out[0]; 
	assign in[31:2] = out[30:1];
	
endmodule

	
module yArith(z, cout, a, b, ctrl); 

output [31:0] z, expect; 
output cout; 
input [31:0] a, b; 
input ctrl; 
wire[31:0] notB, tmp, tmp1; 
wire cin; 

not my_not[31:0] (notB,b);
yAdder subtract(tmp1, cout, a, notB, ctrl);
yAdder add(tmp, cout, a, b, ctrl);
yMux #(.SIZE(32)) pick(z, tmp, tmp1, ctrl); 
// instantiate the components and connect them 

endmodule 


module yAlu(z, ex, a, b, op); 
input [31:0] a, b, slt; 
input [2:0] op; 
output [31:0] z; 
output ex;
wire res, condition;
wire [15:0] z16;
wire [7:0] z8;
wire [3:0] z4;
wire [1:0] z2;
wire [31:0] andres,orres, arithres, slt; 
assign slt[31:1]= 0;  
// not supported 

xor my_xor(condition, a[31], b[31]);
yMux #(1) my_slt(slt[0], arithres[31], a[31], condition);
and my_and[31:0] (andres, a, b);
or  my_or[31:0] (orres, a, b);
yArith my_arithm (arithres, res, a, b, op[2]);
yMux4to1 #(32) pick(z, andres, orres, arithres, slt, op[1:0]);
or or16[15:0](z16, z[15:0], z[31:16]);
or or8[7:0](z8, z16[7:0], z16[15:8]);
or or4[3:0](z4, z8[3:0], z8[7:4]);
or or2[1:0](z2, z4[1:0], z4[3:2]);
or (z1,z2[0:0],z2[1:1]);
assign ex = ~z1;   
endmodule


module yMux(z, a, b, c); 
	parameter SIZE = 32; 
	output [SIZE-1:0] z; 
	input [SIZE-1:0] a, b; 
	input c; 
	yMux1 mine[SIZE-1:0](z, a, b, c); 
endmodule 

module yMux1(z, a, b, c); 
	output z; 
	input a, b, c; 
	wire notC, upper, lower; 
	not my_not(notC, c); 
	and upperAnd(upper, a, notC); 
	and lowerAnd(lower, c, b); 
	or my_or(z, upper, lower); 
endmodule 


module yMux2(z, a, b, c); 
	output [1:0] z; 
	input [1:0] a, b; 
	input c; 
	yMux1 upper(z[0], a[0], b[0], c); 
	yMux1 lower(z[1], a[1], b[1], c); 
endmodule 

module yMux4to1(z, a0,a1,a2,a3, c); 
	parameter SIZE = 2; 
	output [SIZE-1:0] z; 
	input [SIZE-1:0] a0, a1, a2, a3; 
	input [1:0] c; 
	wire [SIZE-1:0] zLo, zHi; 
	yMux #(SIZE) lo(zLo, a0, a1, c[0]); 
	yMux #(SIZE) hi(zHi, a2, a3, c[0]); 
	yMux #(SIZE) final(z, zLo, zHi, c[1]); 
endmodule 



module ff(q, d, clk, enable);
/****************************
An Edge-Triggerred Flip-flop 
Written by H. Roumani, 2008.
****************************/
output [31:0] q;
input [31:0] d; 
input clk, enable;
reg [31:0] q;

always @ (posedge clk)
  if (enable) q <= d; 

endmodule

module mem(memOut, address, memIn, clk, read, write);
/****************************
Behavioral Memory Unit.
Written by H. Roumani, 2009.
****************************/

parameter DEBUG = 0;

parameter CAPACITY = 16'hffff;
input clk, read, write;
input [31:0] address, memIn;
output [31:0] memOut;
reg [31:0] memOut;
reg [31:0] arr [0:CAPACITY];
reg fresh = 1;

always @(read or address or arr[address])
begin
	if (fresh == 1)
	begin
		fresh = 0;
		$readmemh("ram.dat", arr);
	end

	if (read == 1)
	begin
		if (address[1:0] != 2'b00)
		begin
			//$display("Unaligned Load Address %d", address); 
			memOut = 32'hxxxxxxxx;
		end
		else if (address > CAPACITY)
		begin
			//$display("Address %h out of range %d", address, CAPACITY);
			memOut = 32'hxxxxxxxx;
		end
		else
		begin
			memOut = arr[address];
		end
	end
end

always @(posedge clk)
begin
	if (write == 1)
	begin
		if (address[1:0] != 2'b00)
		begin
			//$display("Unaligned Store Address %d", address);
		end
		else if (address > CAPACITY)
		begin
			$display("Address %d out of range %d", address, CAPACITY);
		end
		else
		begin
			arr[address] <= memIn;
			if (DEBUG != 0) $display("MEM: wrote %0dd at address %0dd", memIn, address);
		end
	end
end

endmodule




module rf(RD1,RD2, RN1,RN2, WN,WD, clk, W);
/****************************
Behavioral register file
Written by H. Roumani, 2009
****************************/
parameter DEBUG = 0;

input clk, W;
input [4:0] RN1, RN2, WN;
input [31:0] WD;
output [31:0] RD1, RD2;

reg [31:0] RD1, RD2;
reg [31:0] arr [1:31];

always @(RN1 or arr[RN1])
	if (RN1 == 0)
		RD1 = 0;
	else
	begin
		RD1 = arr[RN1];
		if (DEBUG != 0) $display("RF: read %0dd from reg#%0d", RD1, RN1);
	end

always @(RN2 or arr[RN2])
	if (RN2 == 0)
		RD2 = 0;
	else
	begin
		RD2 = arr[RN2];
		if (DEBUG != 0) $display("RF: read %0dd from reg#%0d", RD2, RN2);
	end
		

always @(posedge clk) 
	if (W == 1 && WN != 0)
	begin
		arr[WN] = WD;
		if (DEBUG != 0) $display("RF: wrote %0dd to reg#%0d", WD, WN);
	end

endmodule


module yIF(ins, PCp4, PCin, clk); 
output [31:0] ins, PCp4; 
input [31:0] PCin; 
input clk,enable,read,write;
wire ex;
input [31:0] a, memIn;
input [2:0] op;
wire [31:0] regout; 

register #(32) lol(regout, PCin, clk, enable);
mem my_instr(ins, regout, memIn, clk, read, write);
yAlu my_Alu(PCp4, ex, a, regout, op);
assign write = 0;
assign op = 2;
assign enable = 1;
assign read = 1;
assign a = 4;
endmodule 

module yID(rd1, rd2, imm, jTarget, ins, wd, RegDst, RegWrite, clk); 
output [31:0] rd1, rd2, imm; 
output [25:0] jTarget; 
input [31:0] ins, wd; 
input RegDst, RegWrite, clk; 
wire [4:0] wn;
wire [4:0] rd;
wire [4:0]rn1,rn2;
wire [15:0]zeros, ones;

assign zeros = 16'h0000;
assign ones = 16'hffff;
assign rn1 = ins[25:21];
assign rn2 = ins[20:16];
assign jTarget = ins[25:0];
assign imm[15:0] = ins[15:0];
assign rd = ins[15:11];
yMux #(16) myMux(imm[31:16], zeros, ones , ins[15]);
yMux #(5) my_wn(wn, rn2, rd, RegDst); 
rf myRf(rd1, rd2, rn1, rn2, wn, wd, clk, RegWrite);



endmodule 


module yEX(z, zero, rd1, rd2, imm, op, ALUSrc); 
output [31:0] z; 
output zero; 
input [31:0] rd1, rd2, imm; 
input [2:0] op; 
input ALUSrc; 
wire [31:0] b;

yMux #(32) myMux(b, rd2, imm, ALUSrc);
yAlu my_Alu(z,zero, rd1, b, op);

//always@(z or zero or rd1 or rd2 or imm or op or ALUSrc)
	//$display("yEX z=%h zero=%h rd1=%h rd2=%h imm=%h op=%h ALUSrc=%h", z, zero, rd1, rd2, imm, op, ALUSrc);

endmodule


module yDM(memOut, exeOut, rd2, clk, MemRead, MemWrite); 
output [31:0] memOut; 
input [31:0] exeOut, rd2; 
input clk, MemRead, MemWrite;

 
// instantiate the circuit (only one line) 
mem myMem(memOut, exeOut, rd2, clk, MemRead, MemWrite);

//always@(memOut or z or rd2 or clk or MemRead or MemWrite)
	//$display("yDM memOut=%h z=%h rd2=%h clk=%h MemRead=%h MemWrite=%h", memOut, z, rd2, clk, MemRead, MemWrite);
endmodule 

module yWB(wb, exeOut, memOut, Mem2Reg); 
output [31:0] wb; 
input [31:0] exeOut, memOut; 
input Mem2Reg;
 

yMux #(32) my_mux(wb, exeOut, memOut, Mem2Reg);
// instantiate the circuit (only one line) 
endmodule 

module yPC(PCin, PCp4,INT,entryPoint,imm,jTarget,zero,branch,jump);
output [31:0] PCin;
input [31:0] PCp4, entryPoint, imm;
input [25:0] jTarget;
input INT, zero, branch, jump;
wire [31:0] immX4, bTarget, choiceA, choiceB, target;
wire doBranch, zf;
assign immX4[31:2] = imm[29:0];
assign immX4[1:0] = 2'b00;
assign target[27:2] = jTarget[25:0];
assign target[31:28] = PCp4[31:28]; 
assign target[1:0] = 2'b00;

yAlu myALU(bTarget, zf, PCp4, immX4, 3'b010);
and (doBranch, branch, zero);
yMux #(32) mux1(choiceA, PCp4, bTarget, doBranch);
yMux #(32) mux2(choiceB,choiceA,target,jump);
yMux #(32) mux3(PCin,choiceB,entryPoint,INT);

endmodule 

module yC1(rtype, lw, sw, jump, branch, opCode);
output rtype, lw, sw, jump, branch;
input [5:0] opCode; 

wire not4, not3, not2; //lw
not (not4, opCode[4]);
not (not3, opCode[3]);
not (not2, opCode[2]);
and (lw, opCode[5], not4, not3, not2, opCode[1], opCode[0]);

wire n1, n2;  //sw
not (n1, opCode[2]);
not (n2, opCode[4]);
and (sw, opCode[5], n2, opCode[3], not1, opCode[1], opCode[0]);

wire b5, b4, b3, b1, b0; //beq
not (b4, opCode[4]);
not (b3, opCode[3]);
not (b5, opCode[5]);
not (b1, opCode[1]);
not (b0, opCode[0]);
and (branch, b5, b4, b3, opCode[2], b1, b0);

wire j0,j2,j3,j4,j5; //jump
not (j4, opCode[4]);
not (j3, opCode[3]);
not (j5, opCode[5]);
not (j0, opCode[0]);
not (j2, opCode[2]);
and (jump, j5, j4, j3, j2, opCode[1], j0);

wire r0, r1, r2, r3, r4, r5;//r-type
not (r4, opCode[4]);
not (r3, opCode[3]);
not (r5, opCode[5]);
not (r1, opCode[1]);
not (r0, opCode[0]);
not (r2, opCode[2]);
and (rtype, r5, r4, r3, r2, r1, r0);

endmodule

module yC2(RegDst, ALUSrc, RegWrite, Mem2Reg, MemRead, MemWrite,rtype, lw, sw, branch,jump);
output RegDst, ALUSrc, RegWrite, Mem2Reg, MemRead, MemWrite;
input rtype, lw, sw, branch, jump;

assign RegDst = rtype;
nor (ALUSrc, rtype, branch);
nor (RegWrite, branch, sw, jump);
assign Mem2Reg = lw;
assign MemRead = lw;
assign MemWrite = sw;

endmodule

module yC3(ALUop, rtype, branch);
output [1:0] ALUop;
input rtype, branch;
wire [1:0] out;
yMux #(2) myMux(out, 2'b00, 2'b10, rtype);
yMux #(2) myMux1(ALUop, out, 2'b01, branch);
// build the circuit
// Hint: you can do it in only2lines
endmodule

module yC4(op, ALUop, fnCode);
output [2:0] op;
input [5:0] fnCode;
input [1:0] ALUop;
wire f0,f1,f2,f3;
wire or1, notf2, notALUop1, and2;
// instantiate and connect
assign  f0 = fnCode[0];
assign  f1 = fnCode[1];
assign  f2 = fnCode[2];
assign  f3 = fnCode[3];
or (or1, f3, f0);
and (op[0], or1, ALUop[1]);
//not (notf2, f2);
//not (notALUop1, ALUop[1]);
nand (op[1], f2, ALUop[1]);
and (and2, ALUop[1], f1);
or (op[2], ALUop[0], and2);


endmodule

module 
yChip(ins, rd2, wb, entryPoint, INT, clk);
output [31:0] ins, rd2, wb;
input [31:0] entryPoint;
input INT, clk;

wire [31:0] PCin; 
wire [1:0] ALUop;
wire [5:0] fnCode;
wire [2:0] op; 
wire [5:0] opCode;
wire RegDst, RegWrite, ALUSrc, Mem2Reg, MemRead, MemWrite, beq, j, rtype;
wire [31:0] wd, rd1, imm, ins, PCp4, z; 
wire [25:0] jTarget; 
wire zero; 
wire [31:0] memOut;

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



endmodule




module register(q, d, clk, enable);
/****************************
An Edge-Triggerred Register.
Written by H. Roumani, 2008.
****************************/

parameter SIZE = 2;
output [SIZE-1:0] q;
input [SIZE-1:0] d;
input clk, enable;

ff myFF[SIZE-1:0](q, d, clk, enable);

endmodule



