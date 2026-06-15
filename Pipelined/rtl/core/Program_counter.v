module program_counter (
    input wire[31:0] pc_next,
    input wire clk,
    input wire rst,//synchronous active low
    output reg[31:0] pc
);

always@(posedge clk) begin
    if(rst==1'b0) pc<= 32'd0;
    else pc<=pc_next;
end
    
endmodule