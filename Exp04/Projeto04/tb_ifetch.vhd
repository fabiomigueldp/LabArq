-- Testbench para Ifetch
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY tb_ifetch IS
END tb_ifetch;

ARCHITECTURE behavior OF tb_ifetch IS

    COMPONENT Ifetch
    PORT(
        reset       : IN STD_LOGIC;
        clock       : IN STD_LOGIC;
        PC_OUT      : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        instruction : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        PCInc       : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        Branch      : IN STD_LOGIC;
        Zero        : IN STD_LOGIC;
        ADDResult   : IN STD_LOGIC_VECTOR(31 DOWNTO 0)
    );
    END COMPONENT;

    -- Sinais de teste
    SIGNAL reset_tb       : STD_LOGIC := '1';
    SIGNAL clock_tb       : STD_LOGIC := '0';
    SIGNAL PC_OUT_tb      : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL instruction_tb : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL PCInc_tb       : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL Branch_tb      : STD_LOGIC := '0';
    SIGNAL Zero_tb        : STD_LOGIC := '0';
    SIGNAL ADDResult_tb   : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');

    -- Período do clock
    CONSTANT clock_period : TIME := 100 ps;

BEGIN

    -- Instancia o módulo Ifetch
    uut: Ifetch PORT MAP (
        reset       => reset_tb,
        clock       => clock_tb,
        PC_OUT      => PC_OUT_tb,
        instruction => instruction_tb,
        PCInc       => PCInc_tb,
        Branch      => Branch_tb,
        Zero        => Zero_tb,
        ADDResult   => ADDResult_tb
    );

    -- Processo do clock
    clock_process: PROCESS
    BEGIN
        clock_tb <= '0';
        WAIT FOR clock_period/2;
        clock_tb <= '1';
        WAIT FOR clock_period/2;
    END PROCESS;

    -- Processo de estímulo
    stim_process: PROCESS
    BEGIN
        -- Reset ativo por 175ps
        reset_tb <= '1';
        WAIT FOR 175 ps;
        
        -- Desativa reset
        reset_tb <= '0';
        
        -- Aguarda algumas instruções serem executadas
        WAIT FOR 1000 ps;
        
        -- Finaliza simulação
        WAIT;
    END PROCESS;

END behavior;
