----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/17/2025 12:03:12 PM
-- Design Name: 
-- Module Name: seven_segment_afis - Behavioral
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
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity seven_segment_afis is
      Port (
      clk: in std_logic; 
      anozi: out std_logic_vector (7 downto 0);
      catozi: out std_logic_vector (6 downto 0)
      );
end seven_segment_afis;

architecture Behavioral of seven_segment_afis is

component  bcd7segment is
Port ( BCDin : in STD_LOGIC_VECTOR (3 downto 0);
       Seven_Segment : out STD_LOGIC_VECTOR (6 downto 0);
       
       Anodout: out std_logic_vector(7 downto 0) ;
       Anodin: in std_logic_vector(7 downto 0) );
end component bcd7segment;


signal bcdin: std_logic_vector (3 downto 0);
signal anodin: std_logic_vector (7 downto 0);
signal cnt: std_logic_vector (16 downto 0):= (others=>'0');
signal state: std_logic_vector(1 downto 0):= (others=>'0');


begin

c1: bcd7segment port map (bcdin,catozi,anozi,anodin);

process(clk)

constant max:std_logic_vector (16 downto 0):="11000011010100000";

begin

if rising_edge(clk) then
        cnt<=cnt+1;
   if(cnt=max) then
        cnt<=(others=>'0');
        if state="00" then
            anodin<="01111111";
            bcdin<="0001";
            state<= state+1;
        elsif state="01" then
            anodin<="10111111";
            bcdin<="0010";
            state<= state+1;
        elsif state="10" then
            anodin<="11011111";
            bcdin<="0011";
            state<= state+1; 
        elsif state="11" then
            anodin<="11101111";
            bcdin<="0100";
            state<= "00";  
        end if;
    end if;
end if;
end process;

end Behavioral;
