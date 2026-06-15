module Reg_file (
    input wire clk, //clock 
    input wire rst, // reset its synchronous active low
    input wire WE3, // write enable
    input wire [4:0] A1, //address 1
    input wire [4:0] A2, //address 2
    input wire [4:0] A3, //address 3
    input wire [31:0] WD3, //write port with address from A3
    output wire [31:0] RD1, //read port with address from A2
    output wire [31:0] RD2 //read port with address from A1
);
    
    // data is taken from this like add x3,x1,x2 the x here are reg in the reg file
    reg[31:0] x[31:0];

    //made these combinational and write is done sequentially

    assign RD1=(A1==5'd0)?32'd0:x[A1];
    assign RD2=(A2==5'd0)?32'd0:x[A2];

    integer i;

    always @(negedge clk) begin //for pipelined version the reg file sends data at negedge
        if (!rst) begin
            for (i = 0; i < 32; i = i + 1)
                x[i] <= 32'd0;
        end
        else if (WE3 && (A3 != 5'd0)) begin
            x[A3] <= WD3;
        end
    end

endmodule