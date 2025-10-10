LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;


ENTITY Idecode IS
	  PORT(	read_data_1	: OUT STD_LOGIC_VECTOR( 31 DOWNTO 0 );
				read_data_2	: OUT STD_LOGIC_VECTOR( 31 DOWNTO 0 );
				Instruction : IN 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
				ALU_result	: IN 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
				RegWrite 	: IN 	STD_LOGIC;
				RegDst 		: IN 	STD_LOGIC;
				Sign_extend : OUT STD_LOGIC_VECTOR( 31 DOWNTO 0 );
				clock,reset	: IN 	STD_LOGIC );
END Idecode;

ARCHITECTURE behavior OF Idecode IS

	--<insira a definição do vetor de regitradores>
	TYPE regvet IS ARRAY (0 TO 31) OF STD_LOGIC_VECTOR(31 DOWNTO 0);

	--<insira os sinais internos necessários>
	SIGNAL reg : regvet;
	SIGNAL Rs_ID, Rt_ID, Rd_ID : STD_LOGIC_VECTOR(4 DOWNTO 0);
	SIGNAL Immediate_value : STD_LOGIC_VECTOR(15 DOWNTO 0);
	SIGNAL write_reg_ID : STD_LOGIC_VECTOR(4 DOWNTO 0);
	SIGNAL WRIte_data : STD_LOGIC_VECTOR (31 DOWNTO 0);
	

BEGIN
	-- Os sinais abaixo devem receber as identificacoes dos registradores
	-- que estao definidos na instrucao, ou seja, o indice dos registradores
	-- a serem utilizados na execucao da instrucao
	-- Esses sinais separam em partes os bits da instrução
		Rs_ID 	<= Instruction(25 DOWNTO 21);
   	Rt_ID 	<= Instruction(20 DOWNTO 16);
   	Rd_ID	<= Instruction(15 DOWNTO 11);
   	Immediate_value <= Instruction(15 DOWNTO 0);
	
	-- Os sinais abaixo devem receber o conteudo dos registradores, reg(i)
	-- USE "CONV_INTEGER(Rs_ID)" para converter os bits de indice do registrador
	-- para um inteiro a ser usado como indice do vetor de registradores.
	-- Exemplo: dado um sinal X do tipo array de registradores, 
	-- X(CONV_INTEGER("00011")) recuperaria o conteudo do registrador 3.
	read_data_1 <= reg(CONV_INTEGER(Rs_ID));	 
	read_data_2 <= reg(CONV_INTEGER(Rt_ID));
	
	-- Crie um multiplexador que seleciona o registrador de escrita de acordo com o sinal RegDst
  write_reg_ID <= Rd_ID WHEN RegDst = '1' ELSE Rt_ID;
	
	-- Ligue no sinal abaixo os bits relativos ao valor a ser escrito no registrador destino.
	write_data <= ALU_result;
	
	-- Estenda o sinal Immediate_value de instrucoes do tipo I de 16-bits to 32-bits
	-- Faca isto independente do tipo de instrucao, mas use apenas quando
	-- for instrucao do tipo I.
   Sign_extend <= x"0000" & Immediate_value WHEN Immediate_value(15)='0' ELSE
									x"FFFF" & Immediate_value;

PROCESS
	BEGIN
		WAIT UNTIL clock'EVENT AND clock = '1';
		IF reset = '1' THEN
			-- Inicializa os registradores com seu numero
			FOR i IN 0 TO 31 LOOP
				reg(i) <= CONV_STD_LOGIC_VECTOR( i, 32 );
 			END LOOP;
  		ELSIF RegWrite = '1' AND Write_reg_ID /= "00000" THEN
		   -- Escreve no registrador indicado pela instrucao
			reg(CONV_INTEGER(write_reg_ID))<= write_data;
		END IF;
	END PROCESS;
END behavior;


