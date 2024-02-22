----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/09/2023 05:11:19 PM
-- Design Name: 
-- Module Name: test_env - Behavioral
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

entity test_env is
    Port ( clk : in STD_LOGIC;
           btn : in STD_LOGIC_VECTOR (4 downto 0);
           sw : in STD_LOGIC_VECTOR (15 downto 0);
           led : out STD_LOGIC_VECTOR (15 downto 0);
           an : out STD_LOGIC_VECTOR (3 downto 0);
           cat : out STD_LOGIC_VECTOR (6 downto 0));
end test_env;

architecture Behavioral of test_env is

component MPG is
    Port(en:out STD_LOGIC;
    input:in STD_LOGIC;
    clock:in STD_LOGIC);
  end component;
  
 component SSD is
     Port(clk:in STD_LOGIC;
           digits:in STD_LOGIC_VECTOR(15 downto 0);
           an:out STD_LOGIC_VECTOR(3 downto 0);
           cat:out STD_LOGIC_VECTOR(6 downto 0));
  end component;
  
  component InstructionIF is
        Port (clk: in STD_LOGIC;
                      rst : in STD_LOGIC;
                      en : in STD_LOGIC;
                      BranchAddress : in STD_LOGIC_VECTOR(31 downto 0);
                      PCSrc : in STD_LOGIC;
                      Instruction : out STD_LOGIC_VECTOR(31 downto 0);
                      PC1 : out STD_LOGIC_VECTOR(31 downto 0));    
  end component;
  
  component Instruction_Decode is
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
  end component;
  
  component MainControl is
       Port ( Instr : in STD_LOGIC_VECTOR(31 downto 0);
             RegDst : out STD_LOGIC;
             ExtOp : out STD_LOGIC;
             ALUSrc : out STD_LOGIC;
             Branch : out STD_LOGIC;
             ALUOp : out STD_LOGIC; 
             RegWrite : out STD_LOGIC);
  end component;
  
  component EX is
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
  end component;

signal cnt: STD_LOGIC_VECTOR(3 downto 0):=(others=>'0');
signal en,rst,PCSrc:STD_LOGIC;
signal BranchAddress,Instruction,PC1:std_logic_vector(31 downto 0);
signal RD1,RD2,WD,Ext_imm:std_logic_vector(63 downto 0);

signal ALURes:std_logic_vector(63 downto 0);
signal digits: STD_LOGIC_VECTOR(63 downto 0);
signal sa:std_logic_vector(4 downto 0);
signal zero:std_logic;
signal func:std_logic_vector(5 downto 0);
--MainControl
signal RegDst, ExtOp, ALUSrc, Branch,RegWrite: STD_LOGIC;
signal ALUOp :  STD_LOGIC;

begin

debouncer1: MPG port map(en,btn(0),clk);
debouncer2: MPG port map(rst,btn(1),clk);
display: SSD port map(clk,digits(15 downto 0),an,cat);
instFetch:InstructionIF port map(clk, rst, en, BranchAddress,PCSrc, Instruction, PC1);
instDecode:Instruction_Decode port map(clk, en, Instruction, WD, RegWrite, RegDst, ExtOp, RD1, RD2, Ext_imm, func, sa);
instrMainControl:MainControl port map(Instruction, RegDst, ExtOp, ALUSrc, Branch, ALUOp, RegWrite);
instrEX:EX port map(PC1, RD1, RD2, Ext_imm, func, sa, ALUSrc, ALUOp, BranchAddress, ALURes, Zero); 

process(sw(7 downto 5),Instruction,PC1,RD1,RD2,Ext_Imm,ALURes,WD)
begin 
    case sw(7 downto 5) is
        when "000"=>digits(31 downto 0)<=Instruction;
        when "001"=>digits(31 downto 0)<=PC1;
        when "010"=>digits<=RD1;
        when "011"=>digits<=RD2;
        when "100"=>digits<=Ext_Imm;
        when "101"=>digits<=ALURes;
        when "110"=>digits<=WD;
        when others => digits <= (others => '0');
        
     end case;
end process;

led(5 downto 0) <= ALUOp & RegDst & ExtOp & ALUSrc & Branch & RegWrite;

PCSrc<=Zero and Branch;
WD<=ALURes;

end Behavioral;
