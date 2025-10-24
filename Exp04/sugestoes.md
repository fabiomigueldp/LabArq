Modificações por arquivo
1) CONTROL.vhd (cria o sinal Branch para BEQ)

Localização específica

Arquivo: CONTROL.vhd (raiz do projeto ou src/CONTROL.vhd)

Seção: entity CONTROL is (declaração de portas) e lógica combinacional na architecture onde hoje você define R_format, LW, SW, RegDst, RegWrite, ALUSrc, MemWrite, MemToReg.

Detalhamento da modificação

Adicionar uma saída Branch : out std_logic.

Gerar Branch='1' apenas quando Opcode="000100" (BEQ).

Não alterar o que já existe para R-format/LW/SW.

Código (trechos)

-- entity: ADICIONE a porta Branch
entity CONTROL is
  port (
    Opcode   : in  std_logic_vector(5 downto 0);
    RegDst   : out std_logic;
    RegWrite : out std_logic;
    MemToReg : out std_logic;
    MemWrite : out std_logic;
    ALUSrc   : out std_logic;
    Branch   : out std_logic       -- NOVO
  );
end CONTROL;

-- architecture: ADICIONE a geração de Branch (BEQ = "000100")
-- sinais auxiliares existentes: R_format, LW, SW
signal BEQ : std_logic;

BEQ      <= '1' when Opcode = "000100" else '0';  -- NOVO
RegDst   <= R_format;
RegWrite <= '1' when (R_format='1' or LW='1') else '0';
ALUSrc   <= '1' when (LW='1' or SW='1') else '0';
MemWrite <= SW;
MemToReg <= '1' when LW='1' else '0';

Branch   <= BEQ;                                   -- NOVO


O PDF pede explicitamente a criação do sinal Branch na UC para BEQ. 

Experimento4

2) EXECUTE.vhd (gera Zero e ADDResult; recebe PCInc)

Localização específica

Arquivo: EXECUTE.vhd (ou src/EXECUTE.vhd)

Seção: entity EXECUTE is (ports) e architecture (onde já existe o MUX de B e o ALU_Result <= Read_data_1 + B).

Detalhamento da modificação

Adicionar entradas/saídas:

PCInc : in std_logic_vector(31 downto 0) (PC+1 vindo do IFETCH)

Zero : out std_logic (1 quando Read_data_1 = Read_data_2)

ADDResult : out std_logic_vector(31 downto 0) (PCInc + Sign_extend)

Manter a soma existente da ALU (ADD) para ALU_Result.

Não implementar novas operações de ALU (nada além de igualdade para Zero e soma PCInc+SignExtend).

Código (trechos)

-- entity: ADICIONE portas PCInc, Zero e ADDResult
entity EXECUTE is
  port (
    Read_data_1 : in  std_logic_vector(31 downto 0);
    Read_data_2 : in  std_logic_vector(31 downto 0);
    Sign_extend : in  std_logic_vector(31 downto 0);
    ALUSrc      : in  std_logic;
    PCInc       : in  std_logic_vector(31 downto 0); -- NOVO
    ALU_Result  : out std_logic_vector(31 downto 0);
    Zero        : out std_logic;                     -- NOVO
    ADDResult   : out std_logic_vector(31 downto 0)  -- NOVO
  );
end EXECUTE;

-- architecture: PRESERVE o que já existe e ACRESCENTE:
-- (se o projeto usa ieee.numeric_std)
-- library ieee; use ieee.std_logic_1164.all; use ieee.numeric_std.all;

signal B : std_logic_vector(31 downto 0);

-- MUX já existente
B <= Read_data_2 when ALUSrc='0' else Sign_extend;

-- ALU de soma já existente
ALU_Result <= std_logic_vector(unsigned(Read_data_1) + unsigned(B));

-- NOVO: flag Zero (Rs == Rt)
Zero <= '1' when Read_data_1 = Read_data_2 else '0';

-- NOVO: PC+1 (words) + SignExtend (words)
ADDResult <= std_logic_vector(unsigned(PCInc) + unsigned(Sign_extend));


O PDF pede Zero (comparação Rs==Rt) e o somador PC+1 + SignExtend dentro de EXECUTE, produzindo ADDResult. Nada de shift-left-2, pois estamos trabalhando em palavras (observação do PDF). 

Experimento4

 

Experimento4_BEQ

3) IFETCH.vhd (exporta PCInc e decide NEXT_PC com MUX Branch∧Zero)

Localização específica

Arquivo: IFETCH.vhd (ou src/IFETCH.vhd)

Seção: entity IFETCH is (ports) e architecture onde hoje há PC, PC_INC, NEXT_PC e a atribuição antiga NEXT_PC <= PC_INC.

Detalhamento da modificação

Adicionar portas:

PCInc : out std_logic_vector(31 downto 0) (expor PC+1)

Branch : in std_logic (da UC)

Zero : in std_logic (da EXECUTE)

ADDResult : in std_logic_vector(31 downto 0) (da EXECUTE)

Alterar a seleção de NEXT_PC:

ANTES: NEXT_PC <= PC_INC

DEPOIS: NEXT_PC <= ADDResult when (Branch='1' and Zero='1') else PC_INC

Atribuir PCInc <= PC_INC para exportar o PC+1.

Código (trechos)

-- entity: ADICIONE as novas portas
entity IFETCH is
  port (
    reset       : in  std_logic;
    clock       : in  std_logic;
    instruction : out std_logic_vector(31 downto 0);
    PC_OUT      : out std_logic_vector(7 downto 0);
    -- NOVOS PORTS:
    PCInc       : out std_logic_vector(31 downto 0);
    Branch      : in  std_logic;
    Zero        : in  std_logic;
    ADDResult   : in  std_logic_vector(31 downto 0)
  );
end IFETCH;

-- architecture: MANTENHA sinais PC, PC_INC, NEXT_PC já existentes
-- ... cálculo de PC_INC = PC + 1 (em palavras) já existente ...

-- Exponha PC+1
PCInc <= PC_INC;  -- NOVO

-- Substitua a linha antiga:
-- NEXT_PC <= PC_INC;
-- por:
NEXT_PC <= ADDResult when (Branch='1' and Zero='1') else PC_INC;  -- NOVO


O PDF determina que o MUX que escolhe o NextPC (desvio vs sequência) fique em IFETCH, controlado por Branch e Zero, e que PC+1 venha do próprio IFETCH. 

Experimento4

4) Exp04.vhd (TOP-LEVEL) — renomeado a partir de Exp03.vhd

Localização específica

Arquivo: renomeie o arquivo Exp03.vhd para Exp04.vhd e troque o nome da entidade de Exp03 para Exp04.

Seções a ajustar:

Declaração dos componentes IFETCH, EXECUTE, CONTROL (copiar/colar definições novas de PORT).

Sinais internos para novas conexões: Branch, Zero, PCInc, ADDResult.

Port maps dos três componentes e ligações entre eles.

Detalhamento da modificação

Não altere IDECODE, DMEMORY ou LCD_Display no top além do fio novo, se necessário.

Conexões novas:

CONTROL.Branch => Branch

IFETCH.PCInc => PCInc

EXECUTE.PCInc => PCInc

EXECUTE.Zero => Zero

IFETCH.Zero => Zero

EXECUTE.ADDResult => ADDResult

IFETCH.ADDResult => ADDResult

IFETCH.Branch => Branch

Código (trechos)

-- entity/top: renomeie
entity Exp04 is
  port (
    -- mesmas portas externas do Exp03 (clock48MHz, reset, LCD, etc.)
  );
end Exp04;

-- component declarations: ATUALIZE as portas dos três blocos
component CONTROL
  port (
    Opcode   : in  std_logic_vector(5 downto 0);
    RegDst   : out std_logic;
    RegWrite : out std_logic;
    MemToReg : out std_logic;
    MemWrite : out std_logic;
    ALUSrc   : out std_logic;
    Branch   : out std_logic
  );
end component;

component EXECUTE
  port (
    Read_data_1 : in  std_logic_vector(31 downto 0);
    Read_data_2 : in  std_logic_vector(31 downto 0);
    Sign_extend : in  std_logic_vector(31 downto 0);
    ALUSrc      : in  std_logic;
    PCInc       : in  std_logic_vector(31 downto 0);
    ALU_Result  : out std_logic_vector(31 downto 0);
    Zero        : out std_logic;
    ADDResult   : out std_logic_vector(31 downto 0)
  );
end component;

component IFETCH
  port (
    reset       : in  std_logic;
    clock       : in  std_logic;
    instruction : out std_logic_vector(31 downto 0);
    PC_OUT      : out std_logic_vector(7 downto 0);
    PCInc       : out std_logic_vector(31 downto 0);
    Branch      : in  std_logic;
    Zero        : in  std_logic;
    ADDResult   : in  std_logic_vector(31 downto 0)
  );
end component;

-- sinais internos NOVOS
signal Branch    : std_logic;
signal Zero      : std_logic;
signal PCInc     : std_logic_vector(31 downto 0);
signal ADDResult : std_logic_vector(31 downto 0);

-- port maps (principais ligações novas)
U_IF  : IFETCH
  port map (
    reset       => reset,
    clock       => clock,
    instruction => DataInstr,
    PC_OUT      => PCAddr,
    PCInc       => PCInc,        -- NOVO
    Branch      => Branch,       -- NOVO
    Zero        => Zero,         -- NOVO
    ADDResult   => ADDResult     -- NOVO
  );

U_EXE : EXECUTE
  port map (
    Read_data_1 => readData1,
    Read_data_2 => readData2,
    Sign_extend => SignExtend,
    ALUSrc      => ALUSrcCtl,
    PCInc       => PCInc,        -- NOVO
    ALU_Result  => ALUResult,
    Zero        => Zero,         -- NOVO
    ADDResult   => ADDResult     -- NOVO
  );

U_CTL : CONTROL
  port map (
    Opcode   => DataInstr(31 downto 26),
    RegDst   => RegDst,
    RegWrite => RegWrite,
    MemToReg => MemToReg,
    MemWrite => MemWrite,
    ALUSrc   => ALUSrcCtl,
    Branch   => Branch          -- NOVO
  );


O PDF instrui explicitamente a renomear o top para Exp04 e a propagar as novas PORTs de CONTROL/EXECUTE/IFETCH para a TLE (top-level entity). 

Experimento4

5) program.mif (memória de instruções) — ajustar ao estado inicial do Exp. 4

Localização específica

Arquivo: program.mif (ou src/program.mif ligado à ROM de instruções)

Seção: conteúdo inicial (endereços 00..06)

Detalhamento da modificação

Substituir o conteúdo para o Estado Inicial do Exp. 4 (Figura 2).

Atenção: os comentários do PDF mostram endereços de memória em palavras, com imediatos que no hex da instrução aparecem como bytes; no nosso datapath, NÃO há shift-left-2 para BEQ (soma em palavras). Não altere o mapeamento de DMEMORY neste experimento.

Conteúdo (trecho)

Depth = 256;
Width = 32;
Address_radix = HEX;
Data_radix = HEX;
Content
Begin
 00: 8C020000;  -- lw $2,0   ; memory(00)=55
 01: 8C030004;  -- lw $3,4   ; memory(01)=AA
 02: 00430820;  -- add $1,$2,$3
 03: AC01000C;  -- sw $1,12  ; memory(03)=FF
 04: 8C04000C;  -- lw $4,12  ; memory(03)=FFFFFFFF
 05: 1022FFFF;  -- beq $1,$2,-4
 06: 1021FFF9;  -- beq $1,$1,-28
 07..FF: 00000000;
End;


Esta é a figura de Estado Inicial de Memória do Exp. 4 (o objetivo é exercitar as duas condições do BEQ). 

Experimento4

6) Arquivos sem modificação (preservar do Exp. 3)

IDECODE.vhd — inalterado (sign-extend e banco de registradores já servem ao BEQ).

DMEMORY.vhd — inalterado (não há mudança pedida no Exp. 4).

LCD_Display.vhd — inalterado.

Qualquer lógica adicional de ALUOp, J/JR, shifts etc. não deve ser adicionada neste experimento.