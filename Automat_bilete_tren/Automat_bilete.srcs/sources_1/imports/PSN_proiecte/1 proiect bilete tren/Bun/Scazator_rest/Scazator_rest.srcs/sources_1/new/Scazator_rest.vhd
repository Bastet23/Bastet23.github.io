----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/03/2025 12:45:18 PM
-- Design Name: 
-- Module Name: Scazator_rest - Behavioral
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

entity Scazator_rest is
  Port (Cancel: in std_logic;
        Reset: in std_logic; 
        En_Scazator: in std_logic; 
        Suma, Distanta: in std_logic_vector(7 downto 0);
        Rest: out std_logic_vector(7 downto 0):="00000000";
        Scazator_gata: out std_logic:='0'
   );
end Scazator_rest;

architecture Behavioral of Scazator_rest is

begin
process(en_scazator, Reset,cancel,suma,distanta)
begin
if reset ='1' then
Rest<=(others=>'0');
scazator_gata<='0';
elsif cancel='1' then
    Rest <= std_logic_vector(unsigned(Suma));
    
elsif en_scazator ='1' then
        Rest <= std_logic_vector(unsigned(Suma) - unsigned(Distanta));
        Scazator_gata<='1';

end if;
end process;
end Behavioral;