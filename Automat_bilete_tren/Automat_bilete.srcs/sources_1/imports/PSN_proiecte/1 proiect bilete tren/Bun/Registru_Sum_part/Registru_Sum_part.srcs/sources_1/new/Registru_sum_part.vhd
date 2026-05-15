----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/30/2025 02:01:41 PM
-- Design Name: 
-- Module Name: Registru_sum_part - Behavioral
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

entity Registru_sum_part is
   Port ( clk: in std_logic;
          nxt: in std_logic;
          Reset: in std_logic;
          En_Reg_suma_part: in std_logic;
          D_in: in std_logic_vector(7 downto 0);
          Suma_part: out std_logic_vector(7 downto 0):="00000000"
   );
end Registru_sum_part;

architecture Behavioral of Registru_sum_part is


signal suma: std_logic_vector(7 downto 0):="00000000";
begin



process(clk,en_reg_suma_part,Reset,nxt,D_in,suma)

begin
if rising_edge (clk) then
if reset='1' then

suma<="00000000";

elsif(en_reg_suma_part ='1' and nxt='1') then

        if D_in="00000001" then
        suma<=suma+1;
        elsif D_in="00000010" then
        suma<=suma+2;
        elsif D_in="00000100" then
        suma<=suma+5;
        elsif D_in="00001000" then
        suma<=suma+10;
        elsif D_in="00010000" then
        suma<=suma+20;
        elsif D_in="00100000" then
        suma<=suma+50;
        
        end if;
end if;

end if;---clk
end process;

Suma_part<=suma;

end Behavioral;
