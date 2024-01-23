`define SET_ON 		        1'b1
`define SET_OFF             1'b0

`define regdst_RD           1'b1
`define regdst_RT           1'b0

`define alusrc_IMM          1'b1
`define alusrc_RD           1'b0

`define branch_ON           1'b1
`define branch_OFF          1'b0

`define memToReg_MEM        1'b1
`define memToReg_ALU        1'b0

`define hilosrc_HI          1'b1
`define hilosrc_LO          1'b0

`define mulOrdiv_MUL        1'b1
`define mulOrdiv_DIV        1'b0

`define memWrite_WORD       4'b1111
`define memWrite_HALF       4'b0011
`define memWrite_BYTE       4'b0001
`define memWrite_OFF        4'b0000

`define memReadWidth_WORD       4'b1111
`define memReadWidth_HALF       4'b0011
`define memReadWidth_BYTE       4'b0001
`define memReadWidth_OFF        4'b0000