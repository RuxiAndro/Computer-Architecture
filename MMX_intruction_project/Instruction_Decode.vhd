----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10/30/2023 10:26:19 PM
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
          Instr : in STD_LOGIC_VECTOR(31 downto 0);
          WD : in STD_LOGIC_VECTOR(63 downto 0);
          RegWrite : in STD_LOGIC;
          RegDst : in STD_LOGIC;
          ExtOp : in STD_LOGIC;
          RD1 : out STD_LOGIC_VECTOR(63 downto 0);
          RD2 : out STD_LOGIC_VECTOR(63 downto 0);
          Ext_Imm : out STD_LOGIC_VECTOR(63 downto 0);
          func : out STD_LOGIC_VECTOR(5 downto 0);
          sa : out STD_LOGIC_VECTOR(4 downto 0));
end Instruction_Decode;

architecture Behavioral of Instruction_Decode is

component reg_file is
    port (
    clk : in std_logic;
    ra1 : in std_logic_vector (4 downto 0);
    ra2 : in std_logic_vector (4 downto 0);
    wa : in std_logic_vector (4 downto 0);
    wd : in std_logic_vector (63 downto 0);
    wen : in std_logic;
    en : in std_logic;
    rd1 : out std_logic_vector (63 downto 0);
    rd2 : out std_logic_vector (63 downto 0)
    );
end component;

signal WriteAddress :std_logic_vector(4 downto 0);

begin

with RegDst select
        WriteAddress <= Instr(15 downto 11) when '1', -- rd
                        Instr(20 downto 16) when '0', -- rt
                        (others => '0') when others; 
                       
regfile:reg_file port map(clk,instr(25 downto 21), instr(20 downto 16), WriteAddress, wd, RegWrite, en,rd1, rd2);     

Ext_Imm(15 downto 0) <= Instr(15 downto 0); 
    with ExtOp select
        Ext_Imm(63 downto 16) <= (others => Instr(15)) when '1',
                                (others => '0') when '0',
                                (others => '0') when others; 
                                
sa<=Instr(10 downto 6);
func<=Instr(5 downto 0);      
          
end Behavioral;

---------------------------------Reg_File

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
entity reg_file is
    port (
    clk : in std_logic;
    ra1 : in std_logic_vector (4 downto 0);
    ra2 : in std_logic_vector (4 downto 0);
    wa : in std_logic_vector (4 downto 0);
    wd : in std_logic_vector (63 downto 0);
    wen : in std_logic;
    en : in std_logic;
    rd1 : out std_logic_vector (63 downto 0);
    rd2 : out std_logic_vector (63 downto 0)
    );
end reg_file;

architecture Behavioral of reg_file is
    type reg_array is array (0 to 7) of std_logic_vector(63 downto 0);
    signal reg_file : reg_array:=(x"0000000000000000", --reg0
                                  x"0000000000000001", --reg1
                                  x"0000000000000002", --reg2
                                  x"0000000000000003", --reg3
                                  x"0000000000000004", --reg4
                                  x"0000000000000005", --reg5
                                  x"0000000000000006", --reg6
                                  others=>x"0000000000000000");
    begin
    process(clk)
        begin
        if rising_edge(clk) then
        if wen = '1' and en='1' then
        reg_file(conv_integer(wa)) <= wd;
        end if;
        end if;
    end process;
    rd1 <= reg_file(conv_integer(ra1));
    rd2 <= reg_file(conv_integer(ra2));
end Behavioral;
