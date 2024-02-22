----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/29/2023 07:22:45 PM
-- Design Name: 
-- Module Name: InstructionRF - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity IFetch is
   Port (clk: in STD_LOGIC;
          rst : in STD_LOGIC;
          en : in STD_LOGIC;
          BranchAddress : in STD_LOGIC_VECTOR(15 downto 0);
          JumpAddress : in STD_LOGIC_VECTOR(15 downto 0);
          Jump : in STD_LOGIC;
          PCSrc : in STD_LOGIC;
          Instruction : out STD_LOGIC_VECTOR(15 downto 0);
          PC1 : out STD_LOGIC_VECTOR(15 downto 0));
end IFetch;

architecture Behavioral of IFetch is

signal mux1:std_logic_vector(15 downto 0);
signal mux2:std_logic_vector(15 downto 0);
signal q:std_logic_vector(15 downto 0):= (others => '0');
signal cnt:std_logic_vector(15 downto 0);
signal sum:std_logic_vector(15 downto 0);

type rom_mem is array(0 to 255) of std_logic_vector(15 downto 0);
signal rom:rom_mem:=(
     B"000_000_000_001_0_000", --add $1,$0,$0   X 10                 0
     B"001_000_100_0000111",   --addi $4,$0,7   X 2207               1
     B"000_000_000_010_0_000", --add $2,$0,$0   X 20                 2
     B"000_000_000_101_0_000", --add $5,$0,$0   X 50                 3
     B"001_000_110_0000001",   --addi &6,&0,1   X 2301               4
     
     B"100_001_100_0011000",    --beq $1,$4,24    8618 --posibil 23  5
     B"000_000_000_000_0_000", --add $0,$0,$0     0                  6
     B"000_000_000_000_0_000", --add $0,$0,$0     0                  7
     B"000_000_000_000_0_000", --add $0,$0,$0     0                  8
     B"010_010_011_0000000",   --lw &3,A_addr($2)  X 4980            9
     B"000_000_000_000_0_000", --add $0,$0,$0      0                 10
     B"000_000_000_000_0_000", --add $0,$0,$0      0                 11
     B"000_011_110_110_0_100", -- and $6,$6,$3     X 0F64            12
     B"000_000_000_000_0_000", --add $0,$0,$0      0                 13
     B"000_000_000_000_0_000", --add $0,$0,$0      0                 14
     
     
     B"100_110_000_0000111",   --beq $6,$0,7       9807              15
     B"000_000_000_000_0_000", --add $0,$0,$0      0                 16
     B"000_000_000_000_0_000", --add $0,$0,$0      0                 17
     B"000_000_000_000_0_000", --add $0,$0,$0      0                 18
     B"001_010_010_0000001",   --addi $2,$2,1      X 2901            19
     B"001_001_001_0000001",   --addi $1,$1,1      X 2481            20
     B"111_0000000000101",      --J 5              E005              21
     B"000_000_000_000_0_000", --add $0,$0,$0      0                 22
     
     B"000_110_101_101_0_000", --add $5,$5,$6       X 1Ad0           23
     B"001_000_110_0000001",   --addi $6,$0,1       X 2301           24
     B"001_010_010_0000001",   --addi $2,$2,1       X 2901           25
     B"001_001_001_0000001",   --addi $1,$1,1       X 2481           26
     B"111_0000000000101",      --J 5               E005             27
     B"000_000_000_000_0_000", --add $0,$0,$0       0                28
     
     B"011_111_101_0000000",  --sw $5,sum_addr($7)  X 7E80           29
      others => X"0000"
                 );
begin


process(clk,rst,mux2)
begin
    if clk='1' and clk'event then
        if rst='1' then
            q<=(others => '0');
        elsif en='1' then
            q<=mux2;  
        end if;
    end if;
  end process;
  
Instruction<=rom(conv_integer(q(7 downto 0)));
sum<=1 + q;
PC1<=sum;


process(PCSrc,sum,BranchAddress)
begin
    case PCSrc is
        when '1'=>mux1<=BranchAddress;
         when others =>mux1<=sum ; 
    end case;
end process;

process(Jump,mux1,Jumpaddress)
begin
    case Jump is
        when '1'=>mux2<=JumpAddress;
         when others=>mux2<=mux1;
    end case;
end process;

end Behavioral;
