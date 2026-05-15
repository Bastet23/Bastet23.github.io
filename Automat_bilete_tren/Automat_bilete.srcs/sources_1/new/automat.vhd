----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/09/2025 06:31:44 PM
-- Design Name: 
-- Module Name: automat - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity automat is
  Port ( 
        D_in: in std_logic_vector(7 downto 0); 
        Enable_mare: in std_logic;
        clk: in std_logic;
        Big_reset: in std_logic;
        nxt: in std_logic;
        Cancel: in std_logic;
        
         -- led-uri/uc                         
 --fin_initializare: out std_logic;       
 --valuta_corecta: in std_logic;         
    zero_bilete: out std_logic;   --inout         
    Gata: out std_logic;   --inout                
     bilet: out std_logic;            
     suma_insuficienta: out std_logic;
    Rest_insuficient: out std_logic; 
    Rest1,Rest2,Rest5,Rest10, Rest20,Rest50: out std_logic;
    introduce_bacnota:out std_logic:='0';
    
    incarcare: out std_logic; --inout
    --Rest_mode: inout std_logic;
    load: out std_logic;--inout
    -- afisor
            anozi: out std_logic_vector (7 downto 0);
            catozi: out std_logic_vector (6 downto 0)
  );
end automat;

architecture Behavioral of automat is

signal Rest_mode: std_logic;

component MPG is
    Port (btn : in STD_LOGIC;
           clk : in STD_LOGIC;
           en : out STD_LOGIC );
end  component MPG;

component Uc_bilete is
 Port (    --Enable_mare
  
            Enable_mare: in std_logic;
            --Y1  -- one for all D_IN
            
            Reset: out std_logic;
            --X1   ----Structura Stoc 
             clk: in std_logic; --- pentru toate care au nevoie
             Big_reset: in std_logic; -- pentru toate
             nxt: in std_logic;--- pentru toate care au nevoie   -- MPG
             Cancel: in std_logic;
             
             --moduri de functionare
             incarcare: out std_logic;
             actualizare: out std_logic;
             Rest_mode: out std_logic;
             
             -- led-uri/uc
             fin_initializare: in std_logic;
             valuta_corecta: in std_logic; 
             zero_bilete: in std_logic;
             Gata: in std_logic;
             bilet: out std_logic;
             suma_insuficienta: out std_logic;
             Rest_insuficient: out std_logic;       
            
            ---X2 ------Dist-Select-Registre
            
            load: out std_logic;
            sel_ok: in std_logic;

            ---X3 ------Reg_sum_part
             En_Reg_suma_part: out std_logic;
             

             ---X4 ------Comparator
            
             Gr_Eq: in std_logic;
             EN_Comp_suma: out std_logic;
             
             --X5 ------ Scazator_Rest
             En_Scazator: out std_logic; 
             Scazator_gata: in std_logic;

             ----X6 ----Verificator Rest
            En_verificator: out std_logic;
            Rest_ok:in std_logic;
            done_rest:in std_logic
            
         );
end component Uc_bilete;

component UE_bilete is
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
             bilet:in std_logic;
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
end component UE_bilete;

signal sbilet: std_logic;
signal reset: std_logic;
signal sel_ok: std_logic;
signal fin_initializare: std_logic;
signal valuta_corecta: std_logic; --- cu 1
signal scazator_gata: std_logic;
signal actualizare: std_logic;
signal en_reg_suma_part: std_logic;
signal gr_eq: std_logic;
signal en_comp_suma: std_logic;
signal en_scazator: std_logic;
signal en_verificator: std_logic;
signal rest_ok: std_logic; -- cu 1
-----------------
--signal reset: std_logic:='0';
--signal sel_ok: std_logic:='0';
--signal fin_initializare: std_logic:='0';
--signal valuta_corecta: std_logic:='1'; --- cu 1
--signal scazator_gata: std_logic:='0';
--signal actualizare: std_logic:='0';
--signal en_reg_suma_part: std_logic:='0';
--signal gr_eq: std_logic:='0';
--signal en_comp_suma: std_logic:='0';
--signal en_scazator: std_logic:='0';
--signal en_verificator: std_logic:='0';
--signal rest_ok: std_logic:='1'; -- cu 1
-----

signal szero_bilete: std_logic;
signal sgata: std_logic;
signal sincarcare: std_logic;
signal sload: std_logic; 
signal done_rest: std_logic;




signal btn_nxt: std_logic:='0';
begin


UC: Uc_bilete port map( enable_mare, reset, clk, big_reset, nxt, cancel, sincarcare, actualizare, rest_mode, 
                        fin_initializare, valuta_corecta, szero_bilete, sgata, sbilet, suma_insuficienta,
                        rest_insuficient, sload, sel_ok, en_reg_suma_part,gr_eq, En_comp_suma, en_scazator,
                        scazator_gata, en_verificator, rest_ok,done_rest);
                        
 UE: Ue_bilete port map (D_in, Reset,clk, big_reset, nxt, cancel, sincarcare, actualizare, sbilet,rest_mode,
                        fin_initializare,valuta_corecta, szero_bilete, sgata, rest1, rest2, rest5, rest10,
                        rest20, rest50, sload, sel_ok, en_reg_suma_part, gr_eq, En_comp_suma, en_scazator,
                        scazator_gata, en_verificator, rest_ok,done_rest,anozi,catozi);

buton_nxt: mpg port map(nxt, clk, btn_nxt);

zero_bilete<=szero_bilete;
gata<=sgata;
incarcare<=sincarcare;
load<=sload;
bilet<=sbilet;
introduce_bacnota<=en_reg_suma_part;
end Behavioral;
