----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/14/2025 08:54:37 AM
-- Design Name: 
-- Module Name: bcd7segment - Behavioral
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

entity bcd7segment is
Port ( BCDin : in STD_LOGIC_VECTOR (3 downto 0);
       Seven_Segment : out STD_LOGIC_VECTOR (6 downto 0);
       
       Anodout: out std_logic_vector(7 downto 0) ;
       Anodin: in std_logic_vector(7 downto 0) );
end bcd7segment;

architecture Behavioral of bcd7segment is

begin
process(BCDin)
begin
 
case BCDin is
when "0000" =>
Seven_Segment <= "1000000"; ---0
when "0001" =>
Seven_Segment <= "1111001"; ---1
when "0010" =>
Seven_Segment <= "0100100"; ---2
when "0011" =>
Seven_Segment <= "0110000"; ---3
when "0100" =>
Seven_Segment <= "0011001"; ---4
when "0101" =>
Seven_Segment <= "0010010"; ---5
when "0110" =>
Seven_Segment <= "0000010"; ---6
when "0111" =>
Seven_Segment <= "1111000"; ---7
when "1000" =>
Seven_Segment <= "0000000"; ---8
when "1001" =>
Seven_Segment <= "0010000"; ---9
when others =>
Seven_Segment <= "1111111"; ---null
end case;

Anodout<=Anodin;
 
end process;

end Behavioral;