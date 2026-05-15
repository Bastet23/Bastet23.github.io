----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/03/2025 12:00:59 PM
-- Design Name: 
-- Module Name: Verificator_stoc_rest - Behavioral
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

entity Verificator_stoc_rest is
    Port (  clk: in std_logic;
            Reset: in std_logic;
            M1, M2, M5, M10, M20, M50: in std_logic_vector (7 downto 0);
            Rest: in std_logic_vector(7 downto 0);
            En_verificator:in std_logic;
           Rest_ok:out std_logic:='1';
           done_rest:out std_logic:='0'
    );
end Verificator_stoc_rest;

architecture Behavioral of Verificator_stoc_rest is


signal started: std_logic:='0';
signal gata: std_logic:='0';
signal tmp: integer:=0;
signal o1: integer:=0;
signal o2: integer:=0;
signal o5: integer:=0;
signal o10: integer:=0;
signal o20: integer:=0;
signal o50: integer:=0;
begin


process(En_verificator, reset,started, gata,clk)
    
begin

if rising_edge(clk) then
    if reset ='1' then
        rest_ok<='1';
        gata<='0';
        started<='0';
        tmp<=0;
        o1<=0;
        o2<=0;
        o5<=0;
        o10<=0;
        o20<=0;
        o50<=0;
        
    elsif En_verificator = '1' and gata='0' then
        
    if started='0' then
            rest_ok<='1';
            
            tmp<= to_integer(unsigned(Rest));
            o1<= to_integer(unsigned(M1));
            o2<= to_integer(unsigned(M2));
            o5<= to_integer(unsigned(M5));
            o10<= to_integer(unsigned(M10));
            o20<= to_integer(unsigned(M20));
            o50<= to_integer(unsigned(M50));
            
            started<='1';     
     elsif tmp=0 then
     gata<='1';
    elsif started='1' then
       
       
        if tmp >= 50 and o50 > 0 then
            tmp <= tmp - 50;
            o50 <= o50 - 1;
        elsif tmp >= 20 and o20 > 0 then
            tmp <= tmp - 20;
            o20 <= o20 - 1;
        elsif tmp >= 10 and o10 > 0 then
            tmp <= tmp - 10;
            o10 <= o10 - 1;
        elsif tmp >= 5 and o5 > 0 then
            tmp <= tmp - 5;
            o5 <= o5 - 1;
        elsif tmp >= 2 and o2 > 0 then
            tmp <= tmp - 2;
            o2 <= o2 - 1;
        elsif tmp >= 1 and o1 > 0 then
            tmp <= tmp - 1;
            o1 <= o1 - 1;
           
        else
            Rest_ok <= '0';
            gata<='1';
        end if;

       

    end if;
   
 
end if;
end if;---clk
end process;

done_rest<=gata;
end Behavioral;
