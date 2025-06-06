`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:        ECE Dept.,CET
// Engineer:       Jennifer George
// 
// Create Date:    04/06/2004
// Design Name:    5-Stage Pipelined RISC Processor
// Module Name:    processor
// Project Name:   Pipelined Processor Design in Verilog
// Target Devices: Generic FPGA / ASIC
// Tool Versions:  Any Verilog Simulation Tool (e.g., ModelSim, Vivado)
// Description: 
//   This module implements a simplified 5-stage pipelined processor with the 
//   following stages:
//      - IF (Instruction Fetch)
//      - ID (Instruction Decode / Register Fetch)
//      - EX (Execute / Address Calculation)
//      - MEM (Memory Access)
//      - WB (Write Back)
// 
//   The processor supports:
//      - R-type operations: add, sub, mul, and, or, slt
//      - I-type operations: addi, subi, slti, lw, sw
//      - Branch instructions: beqz, bneqz
//      - HALT instruction for stopping the pipeline
// 
// Dependencies: 
//   - None
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//   - Pipeline registers used for inter-stage buffering
//   - Instruction memory and data memory are modeled as separate blocks
//   - Includes basic hazard handling for branch instructions
//
//////////////////////////////////////////////////////////////////////////////////

module processor(clk1,clk2);
input clk1,clk2;

reg [31:0] regbank [0:31]; //32 32bit reg bank
reg [31:0] mem [0:1023];   // memory block

reg [31:0] pc,if_id_npc,if_id_ir;
reg [31:0] id_ex_a,id_ex_b,id_ex_npc,id_ex_imm,id_ex_ir;
reg [31:0] ex_mem_aluout,ex_mem_b,ex_mem_ir;
reg [2:0] ex_mem_type,id_ex_type,mem_wb_type;
reg ex_mem_cond;
reg [31:0] mem_wb_lmd,mem_wb_aluout,mem_wb_ir;


reg halted,branch_taken;

parameter add=6'b000000,sub=6'b000001,mul=6'b000101,hlt=6'b111111,slt=6'b000100,ors=6'b000011,ands=6'b000010;
parameter lw=6'b001000,sw=6'b001001,addi=6'b001010,subi=6'b001111,slti=6'b001100,bneqz=6'b001101,beqz=6'b001110;
parameter rr=3'b000,rm=3'b001,load=3'b010,store=3'b011,branch=3'b100,halt=3'b101;

always @(posedge clk1) //if
begin   
    if (halted==0) begin
        if (branch_taken) begin
            // Already handled branch
            branch_taken <= 0; end
        if ((ex_mem_cond==1 && ex_mem_ir[31:26] == beqz) || (ex_mem_cond==0 && ex_mem_ir[31:26] == bneqz))begin   
            if_id_ir <= #2 mem[ex_mem_aluout];
            branch_taken <= #2 1;
            if_id_npc <= #2 ex_mem_aluout+1;
            pc <= #2 ex_mem_aluout+1;
        end
        else begin
            if_id_ir <= #2 mem[pc];
            if_id_npc <= #2 pc+1;
            pc <= #2 pc+1;  
        end
     end
end
       

always @(posedge clk2) //id
begin   
    if (halted==0) begin
        if (if_id_ir[25:21]==5'b00000) id_ex_a <= 0; else id_ex_a <= #2 regbank[if_id_ir[25:21]]; //rs
        if (if_id_ir[20:16]==5'b00000) id_ex_b <= 0; else id_ex_b <= #2 regbank[if_id_ir[20:16]]; //rt
        
        id_ex_npc <= #2 if_id_npc;
        id_ex_imm <= #2 {{16{if_id_ir[15]}},{if_id_ir[15:0]}};
        id_ex_ir <= #2 if_id_ir;
        
        case (if_id_ir[31:26])
            add,sub,mul,slt,ors,ands : id_ex_type <= #2 rr;
            lw : id_ex_type <= #2 load;
            sw : id_ex_type <= #2 store;
            addi,subi,slti : id_ex_type <= #2 rm;
            bneqz,beqz :id_ex_type <= #2 branch;
            hlt :id_ex_type <= #2 halt;
            default : id_ex_type <= #2 halt;
         endcase
        
     end
end

always @(posedge clk1) //ex
begin   
    if (halted==0) begin   
        ex_mem_ir <= #2 id_ex_ir;
        ex_mem_type <= #2 id_ex_type;
        branch_taken <= 0; 
        
        case (id_ex_type)
            rr : begin
                    case (id_ex_ir[31:26]) //opcode
                        add : ex_mem_aluout <= #2 id_ex_a + id_ex_b;
                        sub : ex_mem_aluout <= #2 id_ex_a - id_ex_b;
                        mul : ex_mem_aluout <= #2 id_ex_a * id_ex_b;
                        slt : ex_mem_aluout <= #2 id_ex_a < id_ex_b;
                        ors : ex_mem_aluout <= #2 id_ex_a | id_ex_b;
                        ands : ex_mem_aluout <= #2 id_ex_a & id_ex_b;
                        default : ex_mem_aluout <= 32'hx ;
                    endcase
                end
                 
            rm : begin
                    case (id_ex_ir[31:26]) //opcode
                        addi : ex_mem_aluout <= #2 id_ex_a + id_ex_imm;
                        subi : ex_mem_aluout <= #2 id_ex_a - id_ex_imm;
                        slti : ex_mem_aluout <= #2 id_ex_a < id_ex_imm;
                        default : ex_mem_aluout <= 32'hx ;
                    endcase
                end
                     
            load,store : begin
                            ex_mem_aluout <= #2 id_ex_a+id_ex_imm;
                            ex_mem_b <= #2 id_ex_b;
                        end
                                 
            branch : begin
                         ex_mem_aluout <= #2 id_ex_npc + id_ex_imm;
                         ex_mem_cond <= #2 (id_ex_a ==0);
                     end
                     
            default : ex_mem_aluout <= 32'hx;
        endcase
        
     end
end

always @(posedge clk2) //mem
begin 
    if (halted == 0) begin
        mem_wb_ir <=#2 ex_mem_ir;
        mem_wb_type <= #2 ex_mem_type;
        case (ex_mem_type)
            rr,rm : begin
                    mem_wb_aluout <= #2 ex_mem_aluout;
                    end
            load :begin
                    mem_wb_lmd <= #2 mem[ex_mem_aluout];
                    end
            store : if (branch_taken ==0)begin
                        mem[ex_mem_aluout] <= #2 ex_mem_b;
                    end
            default : mem_wb_aluout <= #2 32'hx;
        endcase
    end
 end

always @(posedge clk1) //wb
begin
    if (branch_taken == 0) begin
    case (mem_wb_type)
    rr : regbank[mem_wb_ir[15:11]] <= #2 mem_wb_aluout; //rd
    rm : regbank[mem_wb_ir[20:16]] <= #2 mem_wb_aluout; //rt
    load : regbank[mem_wb_ir[20:16]] <= #2 mem_wb_lmd; //rt
    halt : halted <= 1'b1;
    endcase
    end
end

endmodule
