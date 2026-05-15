----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/21/2025 01:59:02 PM
-- Design Name: 
-- Module Name: Dist_select_registru - Behavioral
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

entity Dist_select_registru is
port(         D_in : in std_logic_vector(7 downto 0);
              Reset: in std_logic;
              clk: in std_logic;
              load: in std_logic;
              nxt: in std_logic;
              sel_ok: out std_logic:='0';
              D_out: out std_logic_vector (7 downto 0)
              );
end Dist_select_registru;

architecture Behavioral of Dist_select_registru is

signal dist: std_logic_vector (7 downto 0):="00000000";
begin


process(clk, Reset,nxt,load)
begin

if reset='1' then
dist<="00000000";
sel_ok<='0';

elsif rising_edge(clk) then
    
    if load='1'and nxt='1' then
        sel_ok<='1';
        
        if D_in>"01100100" then
            Dist<="01100100";
        
         else
            Dist<=D_in;
        end if;
    end if;
    
end if;--clk

end process;

D_out<=dist;

end Behavioral;
