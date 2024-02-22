----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10/30/2023 10:18:27 PM
-- Design Name: 
-- Module Name: InstructionIF - Behavioral
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

entity InstructionIF is
      Port (clk: in STD_LOGIC;
                    rst : in STD_LOGIC;
                    en : in STD_LOGIC;
                    BranchAddress : in STD_LOGIC_VECTOR(31 downto 0);
                    PCSrc : in STD_LOGIC;
                    Instruction : out STD_LOGIC_VECTOR(31 downto 0);
                    PC1 : out STD_LOGIC_VECTOR(31 downto 0));    
end InstructionIF;

architecture Behavioral of InstructionIF is


signal q: std_logic_vector(31 downto 0) := (others => '0');
signal d: std_logic_vector(31 downto 0);

signal sum: std_logic_vector(31 downto 0);
    
type rom_mem is array(0 to 31) of std_logic_vector(31 downto 0);
signal rom:rom_mem:=(B"000000_00001_00010_00011_00000_000000",   -- 22 1800 r3=r1+r2=1+2=3
                       B"000000_00100_00010_00101_00000_000001", -- 44 2801 r5=r4-r2=4-2=2
                       B"000000_00010_00011_00100_00000_000010", -- 43 2002 r2 and r3 = 2 and 3 =2 
                       B"000000_00011_00010_00011_00001_000100", -- 62 1844 psrld r2>>1 ,2>>1=1
                       B"000000_00101_00010_00001_00001_000011", -- A2 0843 pslld r2<<1 ,2<<1=4
                       B"000001_000100_000100_0000000000000010", -- 1104 0002 pcmpeqw
                      
                       others => X"00000000"
 );

begin 

process(clk)  --PC  
begin 
    if rising_edge(clk) then 
        if rst='1' then 
            q<=x"00000000";
        elsif en='1' then 
            q<=d;
        end if;
    end if;
end process;

Instruction<=rom(conv_integer(q(4 downto 0)));
sum<= 1+q;
PC1<=sum;

process(PCSrc,sum,BranchAddress)
begin
    case PCSrc is
        when '1'=>d<=BranchAddress;
        when others =>d<=sum ; 
    end case;
end process;

end Behavioral;
