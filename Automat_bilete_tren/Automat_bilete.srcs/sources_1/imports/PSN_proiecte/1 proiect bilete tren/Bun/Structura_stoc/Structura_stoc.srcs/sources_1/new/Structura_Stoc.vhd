----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/30/2025 12:46:07 PM
-- Design Name: 
-- Module Name: Structura_Stoc - Behavioral
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
use IEEE.std_logic_unsigned .ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Structura_Stoc is
      Port (
             Reset: in std_logic;
             clk: in std_logic;
             Big_reset: in std_logic;
             nxt: in std_logic;
             
             --moduri de functionare
             incarcare: in std_logic;
             actualizare: in std_logic;
             bilet: in std_logic;
             Rest_mode: in std_logic;
             
             -- led-uri/uc
             fin_initializare: out std_logic:='0';
             valuta_corecta: out std_logic:='0'; 
             zero_bilete: out std_logic:='0';
             Gata: out std_logic:='0';
             Rest1,Rest2,Rest5,Rest10, Rest20,Rest50: out std_logic:='0';
             
             --port bus pentru rest
             Rest:in std_logic_vector(7 downto 0);
             -- switchuri de intrare
             D_in_stoc: in std_logic_vector(7 downto 0);
              
             --registre de stoc
             Bilete: out std_logic_vector(7 downto 0):="00000000";
             M1:  out std_logic_vector(7 downto 0):="00000000";
             M2:  out std_logic_vector(7 downto 0):="00000000";
             M5:  out std_logic_vector(7 downto 0):="00000000";
             M10: out std_logic_vector(7 downto 0):="00000000";
             M20: out std_logic_vector(7 downto 0):="00000000";
             M50: out std_logic_vector(7 downto 0):="00000000"
            
      );
end Structura_Stoc;

architecture Behavioral of Structura_Stoc is

signal tmp: std_logic_vector(7 downto 0):="00000000";
signal rest_started: std_logic := '0';
 
    signal B1:  std_logic_vector(7 downto 0):=(others=>'0');
    signal  O1:   std_logic_vector(7 downto 0):=(others=>'0');
    signal O2:   std_logic_vector(7 downto 0):=(others=>'0');
    signal   O5:   std_logic_vector(7 downto 0):=(others=>'0');
    signal  O10:  std_logic_vector(7 downto 0):=(others=>'0');
    signal  O20:  std_logic_vector(7 downto 0):=(others=>'0');
    signal  O50:  std_logic_vector(7 downto 0) :=(others=>'0');
    signal nobilet: std_logic:='1';
    
    signal cnt: integer range 0 to 6:=0;
begin

process(clk, incarcare, actualizare, nxt, Big_Reset, Reset)

begin



if rising_edge(clk) then

if Big_reset='1' then

B1<=(others=>'0');
o1<=(others=>'0');
o2<=(others=>'0');
o5<=(others=>'0');
o10<=(others=>'0');
o20<=(others=>'0');
o50<=(others=>'0');

cnt<=0;

elsif Reset='1' then

fin_initializare<='0';
valuta_corecta<='1';
zero_bilete<='0';
Gata <='0';
Rest1<='0';
Rest2<='0';
Rest5<='0';
Rest10<='0';
Rest20<='0';
Rest50<='0';
rest_started<='0';
nobilet<='1';

elsif incarcare='1'  then
    if nxt='1' then
    case cnt is
                when 0 =>
                    B1 <= D_in_stoc;
                    if D_in_stoc = "00000000" then
                        zero_bilete <= '1';
                    end if;
                when 1 => O1 <= D_in_stoc;
                when 2 => O2 <= D_in_stoc;
                when 3 => O5 <= D_in_stoc;
                when 4 => O10 <= D_in_stoc;
                when 5 => O20 <= D_in_stoc;
                when 6 =>
                    O50 <= D_in_stoc;
                    fin_initializare <= '1';
                    cnt<=0;
                when others => null;
            end case;
            
            if cnt < 6 then
                cnt <= cnt + 1;
            end if;
    end if;
elsif actualizare='1' and nxt='1' then

    valuta_corecta<='1';

    if D_in_stoc="00000001"  then
    o1<=std_logic_vector(unsigned(o1)+1);
    
    elsif D_in_stoc="00000010"  then
    o2<=std_logic_vector(unsigned(o2)+1);
    
    elsif D_in_stoc="00000100" then
    o5<=std_logic_vector(unsigned(o5)+1);
    
    elsif D_in_stoc="00001000"  then
    o10<=std_logic_vector(unsigned(o10)+1);
    
    elsif D_in_stoc="00010000"  then
    o20<=std_logic_vector(unsigned(o20)+1);
    
    elsif D_in_stoc="00100000"  then
    o50<=std_logic_vector(unsigned(o50)+1);
    
    else
        valuta_corecta<='0';
    end if;

elsif bilet='1' and nobilet='1' then
B1<=std_logic_vector(unsigned(B1)-1);
nobilet<='0';

-- fac nxt='1' ca sa pot vizualiza pe placuta
elsif Rest_mode = '1' and nxt='1' then
    if rest_started = '0' then
            tmp <= Rest; -- copiere o singura data
            rest_started <= '1';
     else
    
    Rest1  <= '0';
    Rest2  <= '0';
    Rest5  <= '0';
    Rest10 <= '0';
    Rest20 <= '0';
    Rest50 <= '0';

    if unsigned(tmp) >= to_unsigned(50, 8) and unsigned(o50) > 0 then
        Rest50 <= '1';
        tmp <= std_logic_vector(unsigned(tmp) - to_unsigned(50, 8));
        o50 <= std_logic_vector(unsigned(o50) - 1);
         
    elsif unsigned(tmp) >= to_unsigned(20, 8) and unsigned(o20) > 0 then
        Rest20 <= '1';
        tmp <= std_logic_vector(unsigned(tmp) - to_unsigned(20, 8));
        o20 <= std_logic_vector(unsigned(o20) - 1);
         
    elsif unsigned(tmp) >= to_unsigned(10, 8) and unsigned(o10) > 0 then
        Rest10 <= '1';
        tmp <= std_logic_vector(unsigned(tmp) - to_unsigned(10, 8));
        o10 <= std_logic_vector(unsigned(o10) - 1);
        
    elsif unsigned(tmp) >= to_unsigned(5, 8) and unsigned(o5) > 0 then
        Rest5 <= '1';
        tmp <= std_logic_vector(unsigned(tmp) - to_unsigned(5, 8));
        o5 <= std_logic_vector(unsigned(o5) - 1);
         
    elsif unsigned(tmp) >= to_unsigned(2, 8) and unsigned(o2) > 0 then
        Rest2 <= '1';
        tmp <= std_logic_vector(unsigned(tmp) - to_unsigned(2, 8));
        o2 <= std_logic_vector(unsigned(o2) - 1);
        
     elsif unsigned(tmp) >= to_unsigned(1, 8) and unsigned(o1) > 0 then
        Rest1 <= '1';
        tmp <= std_logic_vector(unsigned(tmp) - to_unsigned(1, 8));
        o1 <= std_logic_vector(unsigned(o1) - 1);

    else
        Gata <= '1';
    end if;-- mecanism rest
   end if;-- rest_started
end if;-- if mare
end if; --rising edge
end process;

Bilete<=B1;
M1<=O1;
M2<=O2;
M5<=O5;
M10<=O10;
M20<=O20;
M50<=O50;


end Behavioral;
