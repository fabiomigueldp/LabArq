-- control module
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY control IS
   PORT( Opcode 		: IN 	STD_LOGIC_VECTOR( 5 DOWNTO 0 );
			RegDst 		: OUT 	STD_LOGIC;
			RegWrite 	: OUT 	STD_LOGIC;
			MemToReg 	: OUT 	STD_LOGIC;
			MemWrite 	: OUT 	STD_LOGIC;
			ALUSrc 		: OUT 	STD_LOGIC;
			Branch		: OUT	STD_LOGIC);
END control;

ARCHITECTURE behavior OF control IS

	SIGNAL  R_format, LW, SW, BEQ 	: STD_LOGIC;

BEGIN           
	R_format <= '1' WHEN Opcode="000000" ELSE '0';
	LW       <= '1' WHEN Opcode="100011" ELSE '0'; -- lw
	SW       <= '1' WHEN Opcode="101011" ELSE '0'; -- sw
	BEQ      <= '1' WHEN Opcode="000100" ELSE '0'; -- beq
	
	RegDst   <= R_format;
	RegWrite <= '1' WHEN (R_format='1' OR LW='1') ELSE '0';
	ALUSrc   <= '1' WHEN (LW='1' OR SW='1') ELSE '0';
	MemWrite <= SW;
	MemToReg <= '1' WHEN LW='1' ELSE '0';
	Branch   <= BEQ;
	
	

   END behavior;


