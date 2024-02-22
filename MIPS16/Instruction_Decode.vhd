----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/05/2023 06:41:11 PM
-- Design Name: 
-- Module Name: Instruction_Decode - Behavioral
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

entity Instruction_Decode is
    Port ( clk: in STD_LOGIC;
          en : in STD_LOGIC;    
          Instr : in STD_LOGIC_VECTOR(12 downto 0);
          WD : in STD_LOGIC_VECTOR(15 downto 0);
          RegWrite : in STD_LOGIC;
          RegDst : in STD_LOGIC;
          ExtOp : in STD_LOGIC;
          RD1 : out STD_LOGIC_VECTOR(15 downto 0);
          RD2 : out STD_LOGIC_VECTOR(15 downto 0);
          Ext_Imm : out STD_LOGIC_VECTOR(15 downto 0);
          func : out STD_LOGIC_VECTOR(2 downto 0);
          sa : out STD_LOGIC);
end Instruction_Decode;

architecture Behavioral of Instruction_Decode is

type reg_array is array(0 to 7)of std_logic_vector(15 downto 0);
signal reg_file : reg_array:=(others => X"0000");       

signal WriteAddress :std_logic_vector(2 downto 0);

begin

with RegDst select
        WriteAddress <= Instr(6 downto 4) when '1', -- rd
                        Instr(9 downto 7) when '0', -- rt
                        (others => '0') when others;  

process(clk,en,RegWrite,WD)
begin
    if rising_edge(clk) then
        if en='1' and RegWrite='1' then
            reg_file(conv_integer(WriteAddress))<=WD;
        end if;
    end if;
end process;

RD1<=reg_file(conv_integer(Instr(12 downto 10))); --rs
RD2<=reg_file(conv_integer(Instr(9 downto 7)));  --rt

Ext_Imm(6 downto 0) <= Instr(6 downto 0); 
    with ExtOp select
        Ext_Imm(15 downto 7) <= (others => Instr(6)) when '1',
                                (others => '0') when '0',
                                (others => '0') when others;

sa<=Instr(3);
func<=Instr(2 downto 0);

end Behavioral;
