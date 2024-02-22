----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/19/2023 07:17:41 PM
-- Design Name: 
-- Module Name: MainControl - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity MainControl is
     Port ( Instr : in STD_LOGIC_VECTOR(31 downto 0);
           RegDst : out STD_LOGIC;
           ExtOp : out STD_LOGIC;
           ALUSrc : out STD_LOGIC;
           Branch : out STD_LOGIC;
           ALUOp : out STD_LOGIC; 
           RegWrite : out STD_LOGIC);
end MainControl;

architecture Behavioral of MainControl is

begin

process(Instr(31 downto 26))
begin
    RegDst<='0';
    ExtOp<='0';
    ALUSrc<='0';
    Branch<='0';
    RegWrite<='0';
    ALUOp<='0';
    case(Instr(31 downto 26)) is
        when "000000"=>        -- R
            RegDst<='1';
            RegWrite<='1';
            AluOp<='0';
        when "000001"=>       
            ExtOp<='1';
            ALUSrc<='1';
            Branch<='1';
            AluOp<='1';
        when others=>
            RegDst<='0';
            ExtOp<='0';
            ALUSrc<='0';
            Branch<='0';
            RegWrite<='0';
            ALUOp<='0';
      end case;
  end process;
  
end Behavioral;
