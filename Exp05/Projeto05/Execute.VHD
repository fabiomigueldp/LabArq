--  Execute module (Experimento 05 - ULA Completa)
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_SIGNED.ALL;

ENTITY  Execute IS
	PORT(	Read_data_1 		: IN 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
			Read_data_2 		: IN 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
			Sign_extend 		: IN 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
			ALUSrc 				: IN 	STD_LOGIC;
			PCInc				: IN	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
			ALUOp				: IN	STD_LOGIC_VECTOR( 1 DOWNTO 0 );
			Function_opcode	: IN	STD_LOGIC_VECTOR( 5 DOWNTO 0 );
			ALU_Result 			: OUT	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
			Zero				: OUT	STD_LOGIC;
			ADDResult			: OUT	STD_LOGIC_VECTOR( 31 DOWNTO 0 ));
END Execute;

ARCHITECTURE behavior OF Execute IS
	-- Sinais internos
	SIGNAL B : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL ALU_ctl : STD_LOGIC_VECTOR(2 DOWNTO 0);
	SIGNAL ALU_output_mux : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL F0, F1, F2, F3 : STD_LOGIC;
	SIGNAL SUB_Result : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL Shift_extend : STD_LOGIC_VECTOR(31 DOWNTO 0);  -- NOVO: Para shift left do offset
	
BEGIN
	-- MUX para selecionar B (Read_data_2 ou Sign_extend)
	B <= Read_data_2 WHEN ALUSrc = '0' ELSE Sign_extend;
	
	-- Extração dos bits de function necessários para ALU_ctl
	F0 <= Function_opcode(0);
	F1 <= Function_opcode(1);
	F2 <= Function_opcode(2);
	F3 <= Function_opcode(3);
	
	-- Lógica de geração de ALU_ctl (3 bits) baseada em ALUOp e Function
	-- Equações do Experimento 5:
	-- ALU_ctl(2) = ALUOp(0) OR (ALUOp(1) AND F1)
	-- ALU_ctl(1) = NOT (ALUOp(1) AND F2)
	-- ALU_ctl(0) = ALUOp(1) AND (F0 OR F3)
	ALU_ctl(2) <= ALUOp(0) OR (ALUOp(1) AND F1);
	ALU_ctl(1) <= NOT (ALUOp(1) AND F2);
	ALU_ctl(0) <= ALUOp(1) AND (F0 OR F3);
	
	-- Process da ULA: executa operação baseada em ALU_ctl
	-- 000: AND, 001: OR, 010: ADD, 110: SUB, 111: SLT
	PROCESS(ALU_ctl, Read_data_1, B)
	BEGIN
		CASE ALU_ctl IS
			WHEN "000" =>
				-- AND (E lógico bit a bit)
				ALU_output_mux <= Read_data_1 AND B;
				
			WHEN "001" =>
				-- OR (OU lógico bit a bit)
				ALU_output_mux <= Read_data_1 OR B;
				
			WHEN "010" =>
				-- ADD (Soma)
				ALU_output_mux <= Read_data_1 + B;
				
			WHEN "110" =>
				-- SUB (Subtração)
				ALU_output_mux <= Read_data_1 - B;
				
			WHEN "111" =>
				-- SLT (Set on Less Than)
				-- Subtrai e verifica se o resultado é negativo (A < B)
				SUB_Result <= Read_data_1 - B;
				IF SUB_Result(31) = '1' THEN
					-- Resultado negativo: A < B, então retorna 1
					ALU_output_mux <= X"00000001";
				ELSE
					-- Resultado positivo ou zero: A >= B, então retorna 0
					ALU_output_mux <= X"00000000";
				END IF;
				
			WHEN OTHERS =>
				-- Operação indefinida: retorna 0
				ALU_output_mux <= X"00000000";
		END CASE;
	END PROCESS;
	
	-- Saída do resultado da ALU
	ALU_Result <= ALU_output_mux;
	
	-- Flag Zero: ativa quando o resultado da ALU é zero
	Zero <= '1' WHEN ALU_output_mux = X"00000000" ELSE '0';
	
	-- CORREÇÃO: Shift left de 2 bits no offset (multiplica por 4)
	-- No MIPS, o offset é em palavras (4 bytes), mas PC é em bytes
	Shift_extend <= Sign_extend(29 downto 0) & "00";
	
	-- Soma para cálculo do endereço de desvio: PCInc + (Sign_extend << 2)
	-- (deslocamento relativo ao PC para BEQ)
	ADDResult <= PCInc + Shift_extend;
	
END behavior;

