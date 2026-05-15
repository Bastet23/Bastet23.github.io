----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/12/2025 11:53:41 AM
-- Design Name: 
-- Module Name: convertor_vector_to_cifre - Behavioral
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

entity convertor_vector_to_cifre is
Port (
        bin: in std_logic_vector(7 downto 0);
        C2: out std_logic_vector(3 downto 0):="0000";-- sute
        C1: out std_logic_vector(3 downto 0):="0000"; -- zeci
        C0: out std_logic_vector(3 downto 0):="0000"  -- unități
    );
end convertor_vector_to_cifre;

architecture Behavioral of convertor_vector_to_cifre is


begin

process(bin)

variable int: integer range 0 to 255;
variable sute,zeci,unitati: integer range 0 to 9;

begin
        int:=to_integer(unsigned(bin));

        sute:=(int/100)mod 10;
        zeci:=(int/10) mod 10;
        unitati:=int mod 10;
        
     c2<=std_logic_vector(to_unsigned(sute, 4));    
    
    c1<=std_logic_vector(to_unsigned(zeci, 4));
    c0<=std_logic_vector(to_unsigned(unitati, 4));
        
end process;


end Behavioral;
