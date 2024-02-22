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
use IEEE.NUMERIC_STD.ALL;

entity EX is
 Port ( PC1 : in STD_LOGIC_VECTOR(31 downto 0);
           RD1 : in STD_LOGIC_VECTOR(63 downto 0);
           RD2 : in STD_LOGIC_VECTOR(63 downto 0);
           Ext_Imm : in STD_LOGIC_VECTOR(63 downto 0);
           func : in STD_LOGIC_VECTOR(5 downto 0);
           sa : in STD_LOGIC_VECTOR(4 downto 0);
           ALUSrc : in STD_LOGIC;
           ALUOp : in STD_LOGIC;
           BranchAddress : out STD_LOGIC_VECTOR(31 downto 0);
           ALURes : out STD_LOGIC_VECTOR(63 downto 0);
           Zero : out STD_LOGIC);
end EX;

architecture Behavioral of EX is

signal A : STD_LOGIC_VECTOR(63 downto 0);
signal B : STD_LOGIC_VECTOR(63 downto 0);
signal C : STD_LOGIC_VECTOR(63 downto 0);
signal C_33:STD_LOGIC_VECTOR(32 downto 0);
signal carry:STD_LOGIC_VECTOR(31 downto 0);
signal C_31_0:STD_LOGIC_VECTOR(31 downto 0);
signal C_31_1:STD_LOGIC_VECTOR(31 downto 0);
signal ALUCtrl : STD_LOGIC_VECTOR(2 downto 0);

begin

with ALUSrc select
        B <= RD2 when '0', 
	              Ext_Imm when '1',
	              (others => '0') when others;
 
 process(AluOp,func)
 begin
    case AluOp is 
        when '0'=> --R
            case func is
                when "000000"=>ALUCtrl<="000"; --add
                when "000001"=>ALUCtrl<="001";--sub
                when "000010"=>ALUCtrl<="010";--and
                when "000011"=>ALUCtrl<="011";--pslld <<
                when "000100"=>ALUCtrl<="100";-->>
                when others => ALUCtrl <= (others => '0');
            end case;
        when '1'=>ALUCtrl<="001"; -- sub
        when others => ALUCtrl <= (others => '0');
    end case;
 end process;
 
 process(ALUCtrl,sa,RD1,B,C)
 begin 
    case ALUCtrl is
        when "000" => C_33<= ('0' & RD1(31 downto 0)) + ('0' & B(31 downto 0)); --add
                       C(63 downto 32)<=RD1(63 downto 32)+B(63 downto 32)+C_33(32);
                       C(31 downto 0)<=C_33(31 downto 0);
        -- when "001" => C_33<= ('0'& RD1(31 downto 0)) - ('0'& B(31 downto 0)); --sub
                    --   C(63 downto 32)<=RD1(63 downto 32)-B(63 downto 32)- not C_33(32);
                     --  C(31 downto 0)<= not C_33(31 downto 0);  
      --  when "001" =>C_33 <= ('0' & RD1(31 downto 0)) - ('0' & B(31 downto 0)); 
        --             C(63 downto 32) <= RD1(63 downto 32) - B(63 downto 32) - not C_33(32);
          --           if C_33(32) = '1' then 
            --            C(63 downto 32) <= (others => '0');
              --       end if;
        when "001" => 
            C_31_0<=RD1(31 downto 0)-B(31 downto 0);
            carry<=not RD1(31 downto 0) and B(31 downto 0);
            C_31_1<=RD1(63 downto 32) xor B(63 downto 32) xor carry;
            C<=C_31_1 & C_31_0;
        when "010" => C <= RD1 and B; --and
        when "100" =>   --psrld
               case sa is
                  when "00001" => C(63 downto 32)<='0' & B(63 downto 33);
                                  C(31 downto 0)<=B(32) & B(31 downto 1);
                  when "00010" => C(63 downto 32)<="00" & B(63 downto 34);
                                  C(31 downto 0)<=B(33 downto 32) & B(31 downto 2);
                  when "00011" => C(63 downto 32)<="000" & B(63 downto 35);
                                  C(31 downto 0)<=B(34 downto 32) & B(31 downto 3);
                  when others => C <= (others => '0');
                end case;
        when "011" =>     --pslld
              case sa is
                   when "000001" => C(63 downto 32)<= B(62 downto 31);
                                    C(31 downto 0)<=(B(30 downto 0) &'0');
                    when "000010" => C(63 downto 32)<= B(61 downto 30);
                                     C(31 downto 0)<=(B(29 downto 0) &"00");
                    when "000011" => C(63 downto 32)<= B(60 downto 29);
                                     C(31 downto 0)<=(B(28 downto 0) &"000");
                    when others => C <= (others => '0');
              end case;
        when others => C <= (others => '0');
     end case;
     
     case C is
                 when X"0000000000000000" => Zero <= '1';
                 when others => Zero <= '0';
             end case;
             
  end process;
  
  ALURes<=C;
  BranchAddress<=Ext_Imm(31 downto 0)+PC1;
        
    
end Behavioral;
