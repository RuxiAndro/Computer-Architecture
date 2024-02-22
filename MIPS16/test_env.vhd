----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/01/2023 09:51:37 AM
-- Design Name: 
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
  
  component InstructionRF is
      Port (clk: in STD_LOGIC;
            rst : in STD_LOGIC;
            en : in STD_LOGIC;
            BranchAddress : in STD_LOGIC_VECTOR(15 downto 0);
            JumpAddress : in STD_LOGIC_VECTOR(15 downto 0);
            Jump : in STD_LOGIC;
            PCSrc : in STD_LOGIC;
            Instruction : out STD_LOGIC_VECTOR(15 downto 0);
            PC1 : out STD_LOGIC_VECTOR(15 downto 0));
  end component;
  
  component Instruction_Decode is
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
  end component;
  
  component MainControl is
       Port ( Instr : in STD_LOGIC_VECTOR(2 downto 0);
             RegDst : out STD_LOGIC;
             ExtOp : out STD_LOGIC;
             ALUSrc : out STD_LOGIC;
             Branch : out STD_LOGIC;
             Jump : out STD_LOGIC;
             ALUOp : out STD_LOGIC_VECTOR(2 downto 0); --2 sau 3 biti
             MemWrite : out STD_LOGIC;
             MemtoReg : out STD_LOGIC;
             RegWrite : out STD_LOGIC);
  end component;
  
  component EX is
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
  end component;
  
  component MEM is
       Port (clk : in STD_LOGIC;
             en : in STD_LOGIC;
             ALUResIn : in STD_LOGIC_VECTOR(15 downto 0);
             RD2 : in STD_LOGIC_VECTOR(15 downto 0);
             MemWrite : in STD_LOGIC;            
             MemData : out STD_LOGIC_VECTOR(15 downto 0);
             ALUResOut : out STD_LOGIC_VECTOR(15 downto 0));
   end component;    
  
signal cnt: STD_LOGIC_VECTOR(3 downto 0):=(others=>'0');
signal en,rst,PCSrc:STD_LOGIC;
signal JumpAddress,BranchAddress:std_logic_vector(15 downto 0);
signal Instruction,PC1,RD1,RD2,WD,Ext_imm:std_logic_vector(15 downto 0);
signal MemData,ALURes,ALURes1:std_logic_vector(15 downto 0);
signal digits: STD_LOGIC_VECTOR(15 downto 0);
signal sa:std_logic;
signal zero:std_logic;
signal func:std_logic_vector(2 downto 0);
--MainControl
signal RegDst, ExtOp, ALUSrc, Branch, Jump, MemWrite, MemtoReg, RegWrite : STD_LOGIC;
signal ALUOp :  STD_LOGIC_VECTOR(2 downto 0);

begin

debouncer1: MPG port map(en,btn(0),clk);
debouncer2: MPG port map(rst,btn(1),clk);
display: SSD port map(clk,digits,an,cat);
instFetch:InstructionRF port map(clk, rst, en, BranchAddress, JumpAddress, Jump, PCSrc, Instruction, PC1);
instDecode:Instruction_Decode port map(clk, en, Instruction(12 downto 0), WD, RegWrite, RegDst, ExtOp, RD1, RD2, Ext_imm, func, sa);
instrMainControl:MainControl port map(Instruction(15 downto 13), RegDst, ExtOp, ALUSrc, Branch, Jump, ALUOp, MemWrite, MemtoReg, RegWrite);
instrEX:EX port map(PC1, RD1, RD2, Ext_imm, func, sa, ALUSrc, ALUOp, BranchAddress, ALURes, Zero); 
instrMEM:MEM port map(clk,en,ALURes,RD2,MemWrite,MemData,ALURes1);

process(sw(7 downto 5),Instruction,PC1,RD1,RD2,Ext_Imm,ALURes,MemData,WD)
begin 
    case sw(7 downto 5) is
        when "000"=>digits<=Instruction;
        when "001"=>digits<=PC1;
        when "010"=>digits<=RD1;
        when "011"=>digits<=RD2;
        when "100"=>digits<=Ext_Imm;
        when "101"=>digits<=ALURes;
        when "110"=>digits<=MemData;
        when "111"=>digits<=WD;
        when others => digits <= (others => '0');
        
     end case;
end process;

led(10 downto 0) <= ALUOp & RegDst & ExtOp & ALUSrc & Branch & Jump & MemWrite & MemtoReg & RegWrite;

with MemtoReg select
        WD <= MemData when '1',
              ALURes1 when '0',
              (others => '0') when others;

PCSrc<=Zero and Branch;
JumpAddress<=PC1(15 downto 13) & Instruction(12 downto 0);

end Behavioral;
