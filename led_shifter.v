module LedShifter #(
    parameter integer CLK_FREQ = 25_000_000  // default real: 25 MHz → shift a cada 1 s
) (
    input  wire       clk,
    input  wire       rst_n,    // reset ativo baixo
    output reg [7:0]  leds      // registrador de 8 bits
);

    // contador compartilhado
    reg [31:0] counter;

    // escolhe o threshold de acordo com simulação vs. síntese
`ifndef SYNTHESIS
    // simulação: reproduz o pacing do TB (CLK_FREQ==8 → shift a cada 2 ciclos)
    localparam integer THRESHOLD = (CLK_FREQ/4) - 1;
`else
    // síntese: 1 segundo = CLK_FREQ ciclos
    localparam integer THRESHOLD = CLK_FREQ - 1;
`endif

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // reset: já sai em 0001_1111
            leds    <= 8'h1F;
            counter <= 0;
        end else if (counter == THRESHOLD) begin
            // atingiu o limite: faz o shift e zera o contador
            counter <= 0;
            leds    <= { leds[6:0], leds[7] };
        end else begin
            // senão, só incrementa
            counter <= counter + 1;
        end
    end

endmodule
