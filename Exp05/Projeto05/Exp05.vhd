LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY Exp05 IS
  PORT(	reset				: IN STD_LOGIC;
        clock48MHz		: IN STD_LOGIC;
        LCD_RS, LCD_E	: OUT	STD_LOGIC;
        LCD_RW, LCD_ON	: OUT STD_LOGIC;
        DATA				: INOUT	STD_LOGIC_VECTOR(7 DOWNTO 0);
        clockPB				: IN STD_LOGIC;
        InstrALU			: IN STD_LOGIC;
        SW1			: IN STD_LOGIC);
END Exp05;

ARCHITECTURE exec OF Exp05 IS
COMPONENT LCD_Display
  GENERIC(NumHexDig: Integer:= 11);
  PORT(	reset, clk_48Mhz	: IN	STD_LOGIC;
        HexDspData		: IN  STD_LOGIC_VECTOR((NumHexDig*4)-1 DOWNTO 0);
        LCD_RS, LCD_E		: OUT	STD_LOGIC;
        LCD_RW				: OUT STD_LOGIC;
        DATA_BUS				: INOUT	STD_LOGIC_VECTOR(7 DOWNTO 0));
END COMPONENT;

COMPONENT Ifetch
  PORT(	reset			: in STD_LOGIC;
        clock			: in STD_LOGIC;
        PC_out		: out STD_LOGIC_VECTOR(7 DOWNTO 0);
        Instruction	: out STD_LOGIC_VECTOR(31 DOWNTO 0);
        PCInc			: out STD_LOGIC_VECTOR(31 DOWNTO 0);
        Branch		: in STD_LOGIC;
        Zero			: in STD_LOGIC;
        ADDResult		: in STD_LOGIC_VECTOR(31 DOWNTO 0));
END COMPONENT;

COMPONENT Idecode
  PORT(	read_data_1	: OUT STD_LOGIC_VECTOR( 31 DOWNTO 0 );
        read_data_2	: OUT STD_LOGIC_VECTOR( 31 DOWNTO 0 );
        Instruction : IN  STD_LOGIC_VECTOR( 31 DOWNTO 0 );
        Write_data	: IN  STD_LOGIC_VECTOR( 31 DOWNTO 0 );
        RegWrite 	: IN  STD_LOGIC;
        RegDst 		: IN  STD_LOGIC;
        Sign_extend : OUT STD_LOGIC_VECTOR( 31 DOWNTO 0 );
        clock,reset	: IN  STD_LOGIC );
END COMPONENT;

COMPONENT dmemory
  PORT( read_data  : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        address    : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
        write_data : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
        Memwrite   : IN  STD_LOGIC;
        clock,reset: IN  STD_LOGIC );
END COMPONENT;

COMPONENT Control 
  PORT( Opcode 		: IN  STD_LOGIC_VECTOR( 5 DOWNTO 0 );
        RegDst 		: OUT STD_LOGIC;
        RegWrite 	: OUT STD_LOGIC;
        MemToReg 	: OUT STD_LOGIC;
        MemWrite 	: OUT STD_LOGIC;
        ALUSrc 		: OUT STD_LOGIC;
        Branch		: OUT STD_LOGIC;
        ALUOp 		: OUT STD_LOGIC_VECTOR(1 DOWNTO 0));
END COMPONENT;

COMPONENT Execute 
  PORT(	Read_data_1 	: IN  STD_LOGIC_VECTOR( 31 DOWNTO 0 );
        Read_data_2 	: IN  STD_LOGIC_VECTOR( 31 DOWNTO 0 );
        Sign_extend 	: IN  STD_LOGIC_VECTOR( 31 DOWNTO 0 );
        ALUSrc 			: IN  STD_LOGIC;
        PCInc			: IN  STD_LOGIC_VECTOR( 31 DOWNTO 0 );
        ALUOp 			: IN  STD_LOGIC_VECTOR(1 DOWNTO 0);
        Function_opcode : IN  STD_LOGIC_VECTOR(5 DOWNTO 0);
        ALU_Result 		: OUT STD_LOGIC_VECTOR( 31 DOWNTO 0 );
        Zero			: OUT STD_LOGIC;
        ADDResult		: OUT STD_LOGIC_VECTOR( 31 DOWNTO 0 ));
END COMPONENT;

SIGNAL DataInstr 	: STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL DisplayData: STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL PCAddr		: STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL RegDst		: STD_LOGIC;
SIGNAL RegWrite	: STD_LOGIC;
SIGNAL ALUResult	: STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL SignExtend	: STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL readData1	: STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL readData2	: STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL HexDspData	: STD_LOGIC_VECTOR(43 DOWNTO 0);
SIGNAL clock		: STD_LOGIC;
-- controles para LW/SW
SIGNAL MemToReg		: STD_LOGIC;
SIGNAL MemWrite		: STD_LOGIC;
SIGNAL ALUSrcCtl	: STD_LOGIC;
-- dados memória e write-back
SIGNAL DataMemOut	: STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL WriteBack	: STD_LOGIC_VECTOR(31 DOWNTO 0);
-- novos sinais para BEQ
SIGNAL Branch		: STD_LOGIC;
SIGNAL Zero			: STD_LOGIC;
SIGNAL PCInc		: STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL ADDResult	: STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL ALUOp_signal	: STD_LOGIC_VECTOR(1 DOWNTO 0);
SIGNAL Function_field : STD_LOGIC_VECTOR(5 DOWNTO 0);

BEGIN
  Function_field <= DataInstr(5 DOWNTO 0);
  LCD_ON <= '1';
  clock <= NOT clockPB;  -- invertido conforme checklist do roteiro
	
	
  -- MUX de write-back: seleciona entre ALUResult e DataMemOut
  WriteBack <= ALUResult WHEN MemToReg='0' ELSE DataMemOut;
  
  -- MUX para DisplayData: mostra WriteBack para ver resultado LW/R-type
  DisplayData <= DataInstr WHEN InstrALU = '0' ELSE WriteBack;
  
  HexDspData <= "0000" & PCAddr & DisplayData;

  lcd: LCD_Display
  PORT MAP(
    reset				=> reset,
    clk_48Mhz		=> clock48MHz,
    HexDspData	=> HexDspData,
    LCD_RS			=> LCD_RS,
    LCD_E				=> LCD_E,
    LCD_RW			=> LCD_RW,
    DATA_BUS			=> DATA);
  
  IFT: Ifetch
  PORT MAP(
    reset			=> reset,
    clock 		=> clock,
    PC_out		=> PCAddr,
    Instruction	=> DataInstr,
    PCInc			=> PCInc,
    Branch		=> Branch,
    Zero			=> Zero,
    ADDResult		=> ADDResult);

  CTR: Control
  PORT MAP(
    Opcode   => DataInstr(31 DOWNTO 26),
    RegDst   => RegDst,
    RegWrite => RegWrite,
    MemToReg => MemToReg,
    MemWrite => MemWrite,
    ALUSrc   => ALUSrcCtl,
    Branch   => Branch,
    ALUOp    => ALUOp_signal);

  IDEC: Idecode
  PORT MAP(
    read_data_1 => readData1,
    read_data_2 => readData2,
    Instruction => DataInstr,
    Write_data  => WriteBack,
    RegWrite    => RegWrite,
    RegDst      => RegDst,
    Sign_extend => SignExtend,
    clock       => clock,
    reset       => reset);
  
  EXE: Execute
  PORT MAP(
    Read_data_1     => readData1,
    Read_data_2     => readData2,
    Sign_extend     => SignExtend,
    ALUSrc          => ALUSrcCtl,
    PCInc           => PCInc,
    ALUOp           => ALUOp_signal,
    Function_opcode => Function_field,
    ALU_Result      => ALUResult,
    Zero            => Zero,
    ADDResult       => ADDResult);

  DMEM: dmemory
  PORT MAP(
    read_data  => DataMemOut,
    address    => ALUResult(9 DOWNTO 2),
    write_data => readData2,
    Memwrite   => MemWrite,
    clock      => clock,
    reset      => reset);

END exec;
