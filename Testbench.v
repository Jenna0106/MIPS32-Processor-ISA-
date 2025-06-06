// y $display and not $ monitor? latter wont work in loop
// y %d? to display decimal val in the reg

`timescale 1ns / 1ps
module tb1;
reg clk1,clk2;
integer k;

processor dut(clk1,clk2);

initial begin
    clk1=0; clk2=0;
    repeat(20)
    begin
        #5 clk1=1; #5 clk1=0;
        #5 clk2=1; #5 clk2=0;
    end
end

//ht_1: adding 3 numbers 
/*initial begin
    for (k=0;k<32;k=k+1) 
        dut.regbank[k] = k;
     
    dut.mem[0] = 32'h2801000a ; //addi r1,r0,10;
    dut.mem[1] = 32'h28020014 ; //addi r2,r0,20;
    dut.mem[2] = 32'h28030019 ; //addi r3,r0,30;
    dut.mem[3] = 32'h0ce77800 ; //add r7,r7,r7 dummy instr to deal with data hazard
    dut.mem[4] = 32'h0ce77800 ; //add r7,r7,r7  dummy instr to deal with data hazard
    dut.mem[5] = 32'h00222000 ; //add r4,r1,r2;
    dut.mem[6] = 32'h0ce77800 ; //add r7,r7,r7 dummy instr to deal with data hazard
    dut.mem[7] = 32'h00832800 ; //add r5,r4,r3;
    dut.mem[8] = 32'hfc000000 ; //hlt
    
    dut.halted=0;
    dut.pc=0;
    dut.branch_taken=0;
end
initial begin
#280
    for (k=0;k<8;k=k+1) begin
        $display($time,"r %d = %d",k,dut.regbank[k]);
    end
    $finish;
end*/

//ht_3: factorial
initial begin
    for (k=0;k<32;k=k+1) 
        dut.regbank[k] = k; 
        
         dut.mem[0]  = 32'h280a00c8; // ADDI R10,R0,200
        dut.mem[1]  = 32'h28020001; // ADDI R2,R0,1 (initialize result=1)
        dut.mem[2]  = 32'h0ce77800; // dummy instr 
        dut.mem[3]  = 32'h21430000; // LW R3,0(R10) (load N=7)
        dut.mem[4]  = 32'h0ce77800; // dummy instr
        dut.mem[5]  = 32'h14431000; // MUL R2,R2,R3 (result *= N)
        dut.mem[6]  = 32'h0ce77800; // dummy instr
        dut.mem[7]  = 32'h0ce77800; // dummy instr
        dut.mem[8]  = 32'h2c630001; // SUBI R3,R3,1 (N--)
        dut.mem[9]  = 32'h0ce77800; // dummy instr
        dut.mem[10] = 32'h3460fffa; // BNEQZ R3,-6 (loop if N!=0)

        // y -6?  pc at bneqz instr is 10, when pc recah 10 it will update to 11, loop is 5th intsr
            // 11-6= 5th instr
        dut.mem[11] = 32'h2542fffe; // SW R2,-2(R10) (store result at 198)
        // y -2? 200-2= 198 : location where we hv to store it
        dut.mem[12] = 32'hfc000000; // HLT

        dut.mem[200]=7; //finding factorial of 

    dut.halted=0;
    dut.pc=0;
    dut.branch_taken=0;
end
initial begin
        #9000;
        $display ("mem[200]=%d , mem[198]=%d",dut.mem[200],dut.mem[198]);
        #200 $finish;
    end

 
//ht_2 load from memory ,add vale, store to memory
/*initial begin
        for (k=0;k<32;k=k+1) 
            dut.regbank[k] = k; 
        // Program memory initialization
    dut.mem[0] = 32'h28010078;   // addi r1, r0, 120 (r1 = 120)
    dut.mem[1] = 32'h0c631800;    // dummy instr (add r3, r3, r3)
    dut.mem[2] = 32'h20220000;    // lw r2, 0(r1) (r2 = mem[120])
    dut.mem[3] = 32'h0c631800;    // dummy instr
    dut.mem[4] = 32'h2842002d;    // addi r2, r2, 45 (r2 += 45)
    dut.mem[5] = 32'h0c631800;    // dummy instr
    dut.mem[6] = 32'h24220001;    // sw r2, 1(r1) (mem[121] = r2)
    dut.mem[7] = 32'hfc000000;    // hlt
    
    // Data memory initialization
    dut.mem[120] = 85;            // Initialize mem[120] = 85
    
    dut.branch_taken = 0;
    dut.halted = 0;
    dut.pc = 0;                    // Start execution from address 0

    // Wait for completion and display results
    #1000;
        $display("mem[120]: %d ,mem[121]: %d",dut.mem[120],dut.mem[121]);
        #200
         $finish;
    end  */

endmodule
