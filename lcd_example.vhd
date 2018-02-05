--------------------------------------------------------------------------------
--
--   FileName:         lcd_example.vhd
--   Dependencies:     none
--   Design Software:  Quartus II 32-bit Version 11.1 Build 173 SJ Full Version
--
--   HDL CODE IS PROVIDED "AS IS."  DIGI-KEY EXPRESSLY DISCLAIMS ANY
--   WARRANTY OF ANY KIND, WHETHER EXPRESS OR IMPLIED, INCLUDING BUT NOT
--   LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
--   PARTICULAR PURPOSE, OR NON-INFRINGEMENT. IN NO EVENT SHALL DIGI-KEY
--   BE LIABLE FOR ANY INCIDENTAL, SPECIAL, INDIRECT OR CONSEQUENTIAL
--   DAMAGES, LOST PROFITS OR LOST DATA, HARM TO YOUR EQUIPMENT, COST OF
--   PROCUREMENT OF SUBSTITUTE GOODS, TECHNOLOGY OR SERVICES, ANY CLAIMS
--   BY THIRD PARTIES (INCLUDING BUT NOT LIMITED TO ANY DEFENSE THEREOF),
--   ANY CLAIMS FOR INDEMNITY OR CONTRIBUTION, OR OTHER SIMILAR COSTS.
--
--   Version History
--   Version 1.0 6/13/2012 Scott Larson
--     Initial Public Release
--
--   Prints "123456789" on a HD44780 compatible 8-bit interface character LCD 
--   module using the lcd_controller.vhd component.
--
--------------------------------------------------------------------------------

library IEEE;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

ENTITY lcd_example IS
  PORT(
      
		data 		 : in  std_logic_vector(31 downto 0);
		set       : in  std_logic;
		nRst      : IN  STD_LOGIC;  --system clock
		clk       : IN  STD_LOGIC;  --system clock
		
      rw, rs, e : OUT STD_LOGIC;  --read/write, setup/data, and enable for lcd
      lcd_data  : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
		lcd_in    : out std_LOGIC := '1'
		
		
		); --data signals for lcd
END lcd_example;

ARCHITECTURE behavior OF lcd_example IS
  SIGNAL   lcd_enable : STD_LOGIC;
  SIGNAL   lcd_bus    : STD_LOGIC_VECTOR(9 DOWNTO 0);
  SIGNAL   lcd_busy   : STD_LOGIC;
  COMPONENT lcd_controller IS
    PORT(
       clk        : IN  STD_LOGIC; --system clock
       reset_n    : IN  STD_LOGIC; --active low reinitializes lcd
       lcd_enable : IN  STD_LOGIC; --latches data into lcd controller
       lcd_bus    : IN  STD_LOGIC_VECTOR(9 DOWNTO 0); --data and control signals
       busy       : OUT STD_LOGIC; --lcd controller busy/idle feedback
       rw, rs, e  : OUT STD_LOGIC; --read/write, setup/data, and enable for lcd
       lcd_data   : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)); --data signals for lcd
  END COMPONENT;
BEGIN

  --instantiate the lcd controller
  dut: lcd_controller
    PORT MAP(clk => clk, reset_n => '1', lcd_enable => lcd_enable, lcd_bus => lcd_bus, 
             busy => lcd_busy, rw => rw, rs => rs, e => e, lcd_data => lcd_data);
  
  PROCESS(clk)
    VARIABLE char  :  INTEGER := 0;
	 
	 TYPE Tdata IS array (0 to 31) of std_logic_vector(7 downto 0);
	 variable stored_data : Tdata;
  BEGIN
	if nRst = '0' then
		for i in 0 to 31 loop
			stored_data(i) := "00100000";
		end loop;
  
    elsIF(rising_edge(Clk)) THEN
		if (set = '1') then			
			stored_data(to_integer(unsigned(data(12 downto 8)))) := data(7 downto 0);
		end if;
	 
      IF(lcd_busy = '0' AND lcd_enable = '0') THEN
        lcd_enable <= '1';

        char := char + 1;

		  if (char = 1) then
				lcd_bus <= "0010000000";
		  elsif (char < 18) then
				lcd_bus <= "10" & stored_data(char - 2);				
		  elsif (char = 18) then
				lcd_bus <= "0011000000";
		  elsif (char < 35) then
				lcd_bus <= "10" & stored_data(char - 3);				
		  else
				lcd_enable <= '0';
				char := 0;
		  end if;
		  
--        CASE char IS
--          WHEN 1 => lcd_bus <= "10" & stored_data(7 downto 0);
--          WHEN 2 => lcd_bus <= "1000110010";
--          WHEN 3 => lcd_bus <= "1000110011";
--          WHEN 4 => lcd_bus <= "1000110100";
--          WHEN 5 => lcd_bus <= "1000110101";
--          WHEN 6 => lcd_bus <= "1000110110";
--          WHEN 7 => lcd_bus <= "1000110111";
--          WHEN 8 => lcd_bus <= "1000111000";
--          WHEN 9 => lcd_bus <= "1000111001";
--          WHEN OTHERS => 
--        END CASE;
      ELSE
        lcd_enable <= '0';
      END IF;
    END IF;
  END PROCESS;
  
END behavior;
