----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/08/2025 09:59:05 AM
-- Design Name: 
-- Module Name: Uc_bilete - Behavioral
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

entity Uc_bilete is
  Port (    --Enable_mare
  
            Enable_mare: in std_logic;
            --Y1  -- one for all D_IN
            
            Reset: out std_logic:='0';
            --X1   ----Structura Stoc 
             clk: in std_logic; --- pentru toate care au nevoie
             Big_reset: in std_logic; -- pentru toate
             nxt: in std_logic;--- pentru toate care au nevoie   -- MPG
             Cancel: in std_logic;
             
             --moduri de functionare
             incarcare: out std_logic:='0';
             actualizare: out std_logic:='0';
             Rest_mode: out std_logic:='0';
             
             -- led-uri/uc
             fin_initializare: in std_logic;
             valuta_corecta: in std_logic; 
             zero_bilete: in std_logic;
             Gata: in std_logic;
             bilet: out std_logic:='0';
             suma_insuficienta: out std_logic:='0';
             Rest_insuficient: out std_logic:='0';       
           
            ---X2 ------Dist-Select-Registre
            
            load: out std_logic:='0';
            sel_ok: in std_logic;

            ---X3 ------Reg_sum_part
             En_Reg_suma_part: out std_logic:='0';
             

             ---X4 ------Comparator
            
             Gr_Eq: in std_logic;
             EN_Comp_suma: out std_logic:='0';
             
             --X5 ------ Scazator_Rest
             En_Scazator: out std_logic:='0'; 
             Scazator_gata: in std_logic;

             ----X6 ----Verificator Rest
            En_verificator: out std_logic:='0';
            Rest_ok:in std_logic;
            done_rest:in std_logic
            
         );
end Uc_bilete;

architecture Behavioral of Uc_bilete is

type t_state is ( idle, incarcare_stoc, idle_2, selectare_distanta, introducere_bacnota, verificare_suma, 
                verificare_rest,scazator_rest, renuntarea_operatiei, ofer_bilet, oferire_rest, final); 

signal state: t_state :=idle;
signal canceled: std_logic:='0';
begin


process(state,clk,big_reset,enable_mare, cancel, nxt, fin_initializare,zero_bilete,sel_ok,
        valuta_corecta,gr_eq,scazator_gata,rest_ok,gata )

begin


if rising_edge(clk) then

    
    if enable_mare='1' then
    
    if big_reset='1' then
         Reset<='1';
         state<=idle;
        bilet<='0';
        rest_insuficient<='0';
        suma_insuficienta<='0';
        canceled<='0';
    elsif cancel='1' and canceled='0'then
     state<=renuntarea_operatiei;
     canceled<='1';
    else
        
        case state is
     --idle    
        when idle=>
        
        reset<='0';
        
        if nxt='1' then
            state<=incarcare_stoc;
            --incarcare<='1';
        
        end if;
     --incarcare stoc   
        when incarcare_stoc=>
        
        if fin_initializare='1' then
            state<=idle_2;
            --incarcare<='0'; -- oprim ce i inainte
        
        end if;
     --idle2
        when idle_2=>
        
        reset<='0';
        
        if nxt='1' then
            if zero_bilete='0' then
                
                state<=selectare_distanta;
                --load<='1';
                
             end if;
         end if;
      ---selectare_distanta
        when selectare_distanta =>
        
        if sel_ok ='1' then
            state<=introducere_bacnota;
            --load<='0';      -- oprim ce i inainte
            --actualizare<='1';
            --en_reg_suma_part<='1';
        
        end if;
     ---introducere_bacnota
        when introducere_bacnota=>
            
        
        if valuta_corecta ='1' and nxt ='1' then
            state<=verificare_suma;
            en_comp_suma<='1';
            
            --actualizare<='0'; -- oprim ce i inainte
            --en_reg_suma_part<='0'; -- oprim ce i inainte
        
        end if;
    ---verificare suma
        when verificare_suma=>
        
        if gr_eq='0' then
            --actualizare<='1';
            --en_reg_suma_part<='1';
            
            state<=introducere_bacnota;
            suma_insuficienta<='1';
        else
            en_comp_suma<='0'; -- oprim ce i inainte
            --en_scazator<='1';
            state<=scazator_rest;
            suma_insuficienta<='0';
        end if;
        
        
    ------ scazator_rest
        
        when scazator_rest=>
             
        if scazator_gata='1' then
            
            state<=verificare_rest;
            --en_scazator<='0'; -- oprim ce i inainte
            --en_verificator<='1';
            
        end if;
    
    
    ----verificare rest
        when verificare_rest=>
        
        rest_insuficient<= not(Rest_ok);
        --en_verificator<='0'; -- oprim ce i inainte
        if done_rest='1' then
            if rest_ok='1' then
            state<=ofer_bilet;
            else
            state<=renuntarea_operatiei;
            end if;
        end if;
        
     ---- renuntarea operatiei
         when renuntarea_operatiei=>
            
         if cancel='1' then
            state<=oferire_rest;
           -- rest_mode<='1';
        
          end if;
          
     --- bilet
        when ofer_bilet=>
            bilet<='1';
            state<=oferire_rest;
            --rest_mode<='1';
            
     --- oferire_rest
        when oferire_rest=>
            
        if gata='1' then 
            state<=final;
            --rest_mode<='0';    
        end if;
        
     ----final
        when final=>
        
        if nxt ='1' then
        reset<='1';
        state<=idle_2;
        bilet<='0';
        rest_insuficient<='0';
        suma_insuficienta<='0';
        canceled<='0';
        end if;
        
        end case;
         
            
    
        end if;--comanda
    end if;--enable mare
end if; --rising edge clk
end process;

incarcare<= '1' when state=incarcare_stoc else '0';
load<= '1' when state=selectare_distanta else '0';
--introduce bacnota
actualizare<= '1' when state=introducere_bacnota else '0';
en_reg_suma_part<= '1' when state=introducere_bacnota else '0';
--
en_scazator<='1' when state=scazator_rest else '0';
en_verificator<='1' when state=verificare_rest else '0';
rest_mode<='1' when state=oferire_rest else '0';

end Behavioral;
