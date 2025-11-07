LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;  -- Tipo de sinal STD_LOGIC e STD_LOGIC_VECTOR
USE IEEE.STD_LOGIC_ARITH.ALL;  -- Operacoes aritmeticas sobre binarios
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
LIBRARY altera_mf;
USE altera_mf.altera_mf_components.ALL; -- Componente de memoria

ENTITY Ifetch IS
	PORT( reset 		: IN STD_LOGIC;
		  clock 		: IN STD_LOGIC;
		  PC_OUT 		: OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
		  instruction 	: OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		  PCInc			: OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		  Branch		: IN STD_LOGIC;
		  Zero			: IN STD_LOGIC;
		  ADDResult		: IN STD_LOGIC_VECTOR(31 DOWNTO 0));
END Ifetch;





ARCHITECTURE behavior OF Ifetch IS
-- Descreva aqui os demais sinais internos
	SIGNAL PC, PC_INC, NEXT_PC : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL memaddr : STD_LOGIC_VECTOR (7 DOWNTO 0);
	SIGNAL instr : STD_LOGIC_VECTOR (31 DOWNTO 0);
 	
	
	
BEGIN
	-- Descricao da Memoria
	data_memory: altsyncram -- Declaracao do compomente de memoria
	GENERIC MAP(
		operation_mode	=> "ROM",
		width_a			=> 32, -- tamanho da palavra (Word)
		widthad_a		=> 8,   -- tamanho do barramento de endereco
		lpm_type			=> "altsyncram",
		outdata_reg_a	=> "UNREGISTERED",
		init_file		=> "program.mif",  -- arquivo com estado inicial
		intended_device_family => "Cyclone")
	PORT MAP(
		address_a	=> memaddr, 
		q_a			=> instr,
		clock0		=> clock); -- sinal de clock da memoria
	
	-- Descricao do somador (soma 1 palavra)
	Memaddr <= PC(9 downto 2);  -- CORREÇÃO: Usar PC atual, não Next_PC
	PC_OUT <= PC(9 downto 2);
	Instruction <= instr;
	PC_INC <= PC + 4;
	
	-- Exporta PC+4 (PC incrementado)
	PCInc <= PC_INC;
	
	-- MUX para seleção do próximo PC:
	-- Se Branch='1' AND Zero='1', então próximo PC = ADDResult (desvio)
	-- Caso contrário, próximo PC = PC_INC (sequencial)
	Next_PC <= X"00000000" WHEN reset = '1' 
			   ELSE ADDResult WHEN (Branch='1' AND Zero='1')
			   ELSE PC_INC;
	
	
	-- Descricao do registrador (32 bits)
	PROCESS (clock, reset)
	BEGIN
		IF reset ='1' THEN
		PC <= X"00000000";
		ELSIF (clock'event AND clock='1') THEN
		PC <= next_PC;
		end if;
		end PROCESS;
	
	

	 
END behavior;
