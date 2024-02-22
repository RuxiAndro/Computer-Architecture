----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/19/2023 07:11:57 PM
-- Design Name: 
-- Module Name: EX - Behavioral
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
use IEEE.std_logic_arith.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity EX is
 Port ( PC1 : in STD_LOGIC_VECTOR(15 downto 0);
           RD1 : in STD_LOGIC_VECTOR(15 downto 0);
           RD2 : in STD_LOGIC_VECTOR(15 downto 0);
           Ext_Imm : in STD_LOGIC_VECTOR(15 downto 0);
           func : in STD_LOGIC_VECTOR(2 downto 0);
           sa : in STD_LOGIC;
           ALUSrc : in STD_LOGIC;
           ALUOp : in STD_LOGIC_VECTOR(2 downto 0);
           BranchAddress : out STD_LOGIC_VECTOR(15 downto 0);
           ALURes : out STD_LOGIC_VECTOR(15 downto 0);
           Zero : out STD_LOGIC);
end EX;

architecture Behavioral of EX is

signal A : STD_LOGIC_VECTOR(15 downto 0);
signal B : STD_LOGIC_VECTOR(15 downto 0);
signal C : STD_LOGIC_VECTOR(15 downto 0);
signal ALUCtrl : STD_LOGIC_VECTOR(2 downto 0);

begin

with ALUSrc select
        B <= RD2 when '0', 
	              Ext_Imm when '1',
	              (others => '0') when others;
 
 process(AluOp,func)
 begin
    case AluOp is 
        when "000"=> --R
            case func is
                when "000"=>ALUCtrl<="000"; --add
                when "001"=>ALUCtrl<="001";--sub
                when "010"=>ALUCtrl<="010";--sll
                when "011"=>ALUCtrl<="011";--srl
                when "100"=>ALUCtrl<="100";--and
                when "101"=>ALUCtrl<="101";--or
                when "110"=>ALUCtrl<="110";--xor
                when "111"=>ALUCtrl<="111";--addu
                when others => ALUCtrl <= (others => '0');
            end case;
        when "001"=>ALUCtrl<="000"; -- +
        when "010"=>ALUCtrl<="001"; -- - beq
        when "101"=>ALUCtrl<="100"; -- &
        when "110"=>ALUCtrl<="101"; -- |
        when others => ALUCtrl <= (others => '0');
    end case;
 end process;
 
 process(ALUCtrl,sa,RD1,B,C)
 begin 
    case ALUCtrl is
        when "000" => C <= RD1 + B; --add
        when "001" => C <= RD1 - B; --sub
        when "010" =>   --sll
               case sa is
                  when '1' => C <= B(14 downto 0) & "0";
                  when '0' => C <= B;
                  when others => C <= (others => '0');
                 end case;
        when "011" =>     --srl
              case sa is
                   when '1' => C <= "0" & B(15 downto 1);
                   when '0' => C <= B;
                   when others => C <= (others => '0');
                        end case;
        when "100" => C <= RD1 and B; --and andi
        when "101" => C <= RD1 or B; --or ori
        when "110" => C <= RD1 xor B; --xor
        when others => C <= (others => '0');
     end case;
     
     case C is
                 when X"0000" => Zero <= '1';
                 when others => Zero <= '0';
             end case;
             
  end process;
  
  ALURes<=C;
  BranchAddress<=Ext_Imm+PC1;
        
    
end Behavioral;
