----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/06/2025 10:54:36 AM
-- Design Name: 
-- Module Name: UE_bilete - Behavioral
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
use IEEE.STD_LOGIC_unsigned.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity UE_bilete is
 
             Port (  
            --Y1  -- one for all D_IN
            D_in: in std_logic_vector(7 downto 0);
            Reset: in std_logic;
            --X1   ----Structura Stoc 
             clk: in std_logic; --- pentru toate care au nevoie
             Big_reset: in std_logic; -- pentru toate
             nxt: in std_logic;--- pentru toate care au nevoie   -- MPG
             Cancel: in std_logic;
             
             --moduri de functionare
             incarcare: in std_logic;
             actualizare: in std_logic;
             bilet: in std_logic;
             Rest_mode: in std_logic;
             
             -- led-uri/uc
             fin_initializare: out std_logic;
             valuta_corecta: out std_logic; 
             zero_bilete: out std_logic;
             Gata: out std_logic;
             Rest1,Rest2,Rest5,Rest10, Rest20,Rest50: out std_logic;
             
             
             
            ---X2 ------Dist-Select-Registre
            load: in std_logic;
            sel_ok: out std_logic;

            ---X3 ------Reg_sum_part
             En_Reg_suma_part: in std_logic;
    
             ---X4 ------Comparator
             
             Gr_Eq: out std_logic;
             EN_Comp_suma: in std_logic;
             
             --X5 ------ Scazator_Rest
             En_Scazator: in std_logic; 
             Scazator_gata: out std_logic;
             ----X6 ----Verificator Rest
            En_verificator:in std_logic;
            Rest_ok:out std_logic;
            done_rest:out std_logic;
            --afisor
            
            anozi: out std_logic_vector (7 downto 0);
            catozi: out std_logic_vector (6 downto 0)
              );
end UE_bilete;

architecture Behavioral of UE_bilete is

signal Distanta: std_logic_vector (7 downto 0);  ---S1
signal Suma: std_logic_vector (7 downto 0); --- S2
signal Rest:  std_logic_vector(7 downto 0); --Semnal clar-- S3

    -- cifre distanta
     signal D2:  std_logic_vector(3 downto 0);
     signal D1:  std_logic_vector(3 downto 0);
     signal D0:  std_logic_vector(3 downto 0);
    --Cifre suma
     signal S2:  std_logic_vector(3 downto 0);
     signal S1:  std_logic_vector(3 downto 0);
     signal S0:  std_logic_vector(3 downto 0);
     --- semnale bcd
     signal bcdin: std_logic_vector (3 downto 0);
    signal anodin: std_logic_vector (7 downto 0);
    signal cnt: std_logic_vector (16 downto 0):= (others=>'0');
    signal state: std_logic_vector(2 downto 0):= (others=>'0');


--- Semnale stoc 
signal bilete: std_logic_vector (7 downto 0);
signal O1: std_logic_vector (7 downto 0);
signal O2: std_logic_vector (7 downto 0);
signal O5: std_logic_vector (7 downto 0);
signal O10: std_logic_vector (7 downto 0);
signal O20: std_logic_vector (7 downto 0);
signal O50: std_logic_vector (7 downto 0);


----Componente

component  bcd7segment is
Port ( BCDin : in STD_LOGIC_VECTOR (3 downto 0);
       Seven_Segment : out STD_LOGIC_VECTOR (6 downto 0);
       
       Anodout: out std_logic_vector(7 downto 0) ;
       Anodin: in std_logic_vector(7 downto 0) );
end component bcd7segment;

component  convertor_vector_to_cifre is
Port (
        bin: in std_logic_vector(7 downto 0);
        C2: out std_logic_vector(3 downto 0);-- sute
        C1: out std_logic_vector(3 downto 0); -- zeci
        C0: out std_logic_vector(3 downto 0)  -- unități
    );
end component convertor_vector_to_cifre;

component Structura_Stoc is
      Port (
             Reset: in std_logic;
             clk: in std_logic;
             Big_reset: in std_logic;
             nxt: in std_logic;
             
             --moduri de functionare
             incarcare: in std_logic;
             actualizare: in std_logic;
             bilet: in std_logic;
             Rest_mode: in std_logic;
             
             -- led-uri/uc
             fin_initializare: out std_logic;
             valuta_corecta: out std_logic; 
             zero_bilete: out std_logic;
             Gata: out std_logic;
             Rest1,Rest2,Rest5,Rest10, Rest20,Rest50: out std_logic;
             
             --port bus pentru rest
             Rest:in std_logic_vector(7 downto 0);
             -- switchuri de intrare
             D_in_stoc: in std_logic_vector(7 downto 0);
              
             --registre de stoc
             Bilete: out std_logic_vector(7 downto 0);
             M1:  out std_logic_vector(7 downto 0);
             M2:  out std_logic_vector(7 downto 0);
             M5:  out std_logic_vector(7 downto 0);
             M10: out std_logic_vector(7 downto 0);
             M20: out std_logic_vector(7 downto 0);
             M50: out std_logic_vector(7 downto 0)
            
      );
end component Structura_Stoc;

component Scazator_rest is
  Port (Cancel: in std_logic;
        Reset: in std_logic; 
        En_Scazator: in std_logic; 
        Suma, Distanta: in std_logic_vector(7 downto 0);
        Rest: out std_logic_vector(7 downto 0);
        Scazator_gata: out std_logic
   );
end component Scazator_rest;


component Registru_sum_part is
   Port ( clk: in std_logic;
            nxt:in std_logic;
          Reset: in std_logic;
          En_Reg_suma_part: in std_logic;
          D_in: in std_logic_vector(7 downto 0);
          Suma_part: out std_logic_vector(7 downto 0)
   );
end  component Registru_sum_part;

component Dist_select_registru is
port(         D_in : in std_logic_vector(7 downto 0);
              Reset: in std_logic;
              clk: in std_logic;
              load: in std_logic;
              nxt: in std_logic;
              sel_ok: out std_logic;
              D_out: out std_logic_vector (7 downto 0));
end component Dist_select_registru;

component Comparator_suma is
port (Reset: in std_logic;
 Suma: in std_logic_vector(7 downto 0);
       Dist: in std_logic_vector(7 downto 0);
       Gr_Eq: out std_logic;
       
       EN_Comp_suma: in std_logic);
end component Comparator_suma;

component Verificator_stoc_rest is
    Port (  clk: in std_logic;
            Reset: in std_logic;
            M1, M2, M5, M10, M20, M50: in std_logic_vector (7 downto 0);
            Rest: in std_logic_vector(7 downto 0);
            En_verificator:in std_logic;
           Rest_ok:out std_logic;
           done_rest: out std_logic
    );
end component Verificator_stoc_rest;


begin



---PORT MAP Pentru tot

X1: Structura_stoc port map ( Reset ,clk, Big_reset, nxt, incarcare, actualizare,bilet, rest_mode, fin_initializare, valuta_corecta,
                zero_bilete, Gata, Rest1, Rest2, Rest5, Rest10, Rest20, Rest50, Rest,
                    D_in, bilete, O1, O2, O5, O10, O20, O50);
                    
X2: Dist_select_registru port map (D_in, Reset, clk, load, nxt, sel_ok, Distanta);

X3: Registru_sum_part port map (clk,nxt,Reset, En_reg_suma_part, D_in, Suma);

X4: Comparator_suma port map ( Reset, Suma, Distanta, Gr_Eq, En_comp_suma);

X5: Scazator_Rest port map (Cancel, Reset, En_Scazator, Suma, Distanta, Rest, Scazator_gata);

X6: Verificator_stoc_rest port map (clk, Reset, O1, O2, O5, O10, O20, O50, Rest, En_verificator, Rest_ok,done_rest); 

Cifre1: convertor_vector_to_cifre port map(distanta,D2,D1,D0);

Cifre2:convertor_vector_to_cifre port map(suma,S2,S1,S0);

afisor: bcd7segment port map (bcdin,catozi,anozi,anodin);


process(clk)

constant max:std_logic_vector (16 downto 0):="11000011010100000";

begin

if rising_edge(clk) then
        cnt<=cnt+1;
   if(cnt=max) then
        cnt<=(others=>'0');
        
   ---distanta     
        if state="000" then
            anodin<="01111111";
            bcdin<=d2;
            state<= state+1;
        
        elsif state="001" then
            anodin<="10111111";
            bcdin<=d1;
            state<= state+1;
        
        elsif state="010" then
            anodin<="11011111";
            bcdin<=d0;
            state<= state+1; 
   --suma    
        elsif state="011" then
            anodin<="11111011";
            bcdin<=s2;
            state<= state+1; 
        
        elsif state="100" then
            anodin<="11111101";
            bcdin<=s1;
            state<= state+1; 
       
        elsif state="101" then
            anodin<="11111110";
            bcdin<=s0;
            state<= "000"; 
            
        end if;
    end if;
end if;
end process;


end Behavioral;
