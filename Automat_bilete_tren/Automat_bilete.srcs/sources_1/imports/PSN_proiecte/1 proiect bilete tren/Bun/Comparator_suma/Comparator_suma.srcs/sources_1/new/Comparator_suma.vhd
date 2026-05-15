----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/21/2025 02:44:18 PM
-- Design Name: 
-- Module Name: Comparator_suma - Behavioral
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

entity Comparator_suma is
 port (Reset: in std_logic;
 Suma: in std_logic_vector(7 downto 0);
       Dist: in std_logic_vector(7 downto 0);
       Gr_Eq: out std_logic:='0';
       
       EN_Comp_suma: in std_logic);
end Comparator_suma;

architecture Behavioral of Comparator_suma is



signal Gr, Eq, Lw:  std_logic;
begin

process(en_comp_suma, reset,suma,dist)
begin

if reset ='1' then
Gr<='0';
Eq<='0';
Lw<='0';
elsif en_comp_suma ='1' then
    
    lw<='0';
    eq<='0';
    gr<='0';

    if to_integer(unsigned(Suma))< to_integer(unsigned(dist)) then
    lw<='1';
    eq<='0';
    gr<='0';
    
    elsif to_integer(unsigned(Suma))= to_integer(unsigned(dist)) then
    lw<='0';
    eq<='1';
    gr<='0';
    
    elsif to_integer(unsigned(Suma))> to_integer(unsigned(dist)) then
    lw<='0';
    eq<='0';
    gr<='1';

    end if;

end if;

end process;

gr_eq<=Gr or Eq;

end Behavioral;
