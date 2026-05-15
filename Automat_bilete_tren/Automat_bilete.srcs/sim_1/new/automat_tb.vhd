----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/09/2025 06:31:44 PM
-- Design Name: 
-- Module Name: automat - Behavioral
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

entity automat_tb is
 
end automat_tb;

architecture Behavioral of automat_tb is

signal D_in: std_logic_vector(7 downto 0):="00000000";
signal Enable_mare: std_logic:='0';
signal clk: std_logic:='0';
signal Big_reset: std_logic:='0';
signal nxt: std_logic:='0';
signal cancel: std_logic:='0';
signal zero_bilete: std_logic;
signal gata: std_logic:='0';
signal bilet: std_logic;
signal suma_insuficienta: std_logic;
signal rest_insuficient: std_logic;
signal rest1: std_logic;
signal rest2: std_logic;
signal rest5: std_logic;
signal rest10: std_logic;
signal rest20: std_logic;
signal rest50: std_logic;
signal incarcare: std_logic;
signal load: std_logic;
signal anozi: std_logic_vector(7 downto 0);
signal catozi: std_logic_vector(6 downto 0);


component automat is
  Port ( 
        D_in: in std_logic_vector(7 downto 0); 
        Enable_mare: in std_logic;
        clk: in std_logic;
        Big_reset: in std_logic;
        nxt: in std_logic;
        Cancel: in std_logic;
        
         -- led-uri/uc                         
   
    zero_bilete: out std_logic;   --inout         
    Gata: out std_logic;   --inout                
     bilet: out std_logic;            
     suma_insuficienta: out std_logic;
    Rest_insuficient: out std_logic; 
    Rest1,Rest2,Rest5,Rest10, Rest20,Rest50: out std_logic;
    
    
    incarcare: out std_logic; --inout
    
    load: out std_logic;--inout
    -- afisor
            anozi: out std_logic_vector (7 downto 0);
            catozi: out std_logic_vector (6 downto 0)
  );
end component automat;


begin

C1: automat port map(D_in,Enable_mare,clk,Big_reset,nxt,Cancel,zero_bilete,Gata,bilet,suma_insuficienta,
                    Rest_insuficient,Rest1,Rest2,Rest5,Rest10,Rest20,Rest50,incarcare, load, anozi, catozi);
                    
  
 --proces de clock                  
 process
 begin
 clk<='0';
 wait for 10ns;
 clk<='1';
 wait for 10ns;
 end process;

process
begin
wait for 20 ns;
-- initiez functionarea
Enable_mare<='1';
wait for 10 ns;
Big_Reset<='1'; wait for 20 ns;
Big_Reset<='0'; wait for 20 ns;
---

--incarcare
 D_in<="00000011";
 
 
 --ies din idle
 wait until rising_edge(clk);
 nxt<='1'; 
 wait until rising_edge(clk);
 nxt<='0'; 
 
 --bilete
 wait until rising_edge(clk);
 nxt<='1'; 
 wait until rising_edge(clk);
 nxt<='0'; 
 

 --m1
 wait until rising_edge(clk);
 nxt<='1'; 
 wait until rising_edge(clk);
 nxt<='0'; 
 --m2
 wait until rising_edge(clk);
 nxt<='1'; 
 wait until rising_edge(clk);
 nxt<='0'; 
 --m5
 wait until rising_edge(clk);
 nxt<='1'; 
 wait until rising_edge(clk);
 nxt<='0'; 
 --m10
 wait until rising_edge(clk);
 nxt<='1'; 
 wait until rising_edge(clk);
 nxt<='0'; 
 --m20
 wait until rising_edge(clk);
 nxt<='1'; 
 wait until rising_edge(clk);
 nxt<='0'; 
 --m50
 wait until rising_edge(clk);
 nxt<='1'; 
 wait until rising_edge(clk);
 nxt<='0'; 
 
 wait for 40 ns;
 --ies din idle 2
 wait until rising_edge(clk);
 nxt<='1'; 
 wait until rising_edge(clk);
 nxt<='0';
 
 D_in<="00100000";
 
 --incarc distanta 32
 wait for 50 ns;
 --se face load
 wait until rising_edge(clk);
 nxt<='1'; 
 wait until rising_edge(clk);
 nxt<='0';
 
 
 wait for 50 ns;
 
 D_in<="00100000";
wait for 20 ns;

wait until rising_edge(clk);
 nxt<='1'; 
 wait until rising_edge(clk);
 nxt<='0';

D_in<="00000000";
wait for 50 ns;

--cancel<='1'; wait for 50 ns;

--verificicari
wait until rising_edge(clk);
 nxt<='1'; 
 wait until rising_edge(clk);
 nxt<='0';
wait for 50 ns;


---rest 10
wait until rising_edge(clk);
 nxt<='1'; 
 wait until rising_edge(clk);
 nxt<='0';
wait for 50 ns;
--rest 5
wait until rising_edge(clk);
 nxt<='1'; 
 wait until rising_edge(clk);
 nxt<='0';
wait for 50 ns;
-- rest 2
wait until rising_edge(clk);
 nxt<='1'; 
 wait until rising_edge(clk);
 nxt<='0';
 
 
 wait until rising_edge(clk);
 nxt<='1'; 
 wait until rising_edge(clk);
 nxt<='0';
 wait until rising_edge(clk);
 nxt<='1'; 
 wait until rising_edge(clk);
 nxt<='0';
wait for 50 ns;

wait until rising_edge(clk);
 nxt<='1'; 
 wait until rising_edge(clk);
 nxt<='0';
 wait until rising_edge(clk);
 nxt<='1'; 
 wait until rising_edge(clk);
 nxt<='0';
 wait until rising_edge(clk);
 nxt<='1'; 
 wait until rising_edge(clk);
 nxt<='0';
wait for 500 ns;
end process;

end Behavioral;
