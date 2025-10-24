--  Execute module
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_SIGNED.ALL;

ENTITY  Execute IS
	PORT(	Read_data_1 	: IN 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
			Read_data_2 	: IN 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
			Sign_extend 	: IN 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
			ALUSrc 			: IN 	STD_LOGIC;
			PCInc			: IN	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
			ALU_Result 		: OUT	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
			Zero			: OUT	STD_LOGIC;
			ADDResult		: OUT	STD_LOGIC_VECTOR( 31 DOWNTO 0 ));
END Execute;

ARCHITECTURE behavior OF Execute IS
	SIGNAL B : STD_LOGIC_VECTOR(31 DOWNTO 0);
BEGIN
	-- MUX para selecionar B (Read_data_2 ou Sign_extend)
	B <= Read_data_2 WHEN ALUSrc = '0' ELSE Sign_extend;
	
	-- ALU: soma Read_data_1 + B
	ALU_Result <= Read_data_1 + B;
	
	-- Comparação para BEQ: Zero = 1 quando Read_data_1 == Read_data_2
	Zero <= '1' WHEN Read_data_1 = Read_data_2 ELSE '0';
	
	-- Soma para cálculo do endereço de desvio: PCInc + Sign_extend
	ADDResult <= PCInc + Sign_extend;
END behavior;

