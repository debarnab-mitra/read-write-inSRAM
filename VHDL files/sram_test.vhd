library ieee;
use ieee.std_logic_1164.all;
library work;
use work.Components.all;

entity sram_test is

	port
	(
		address : out std_logic_vector(12 downto 0);
		ios_data :      inout std_logic_vector (7 downto 0);
		mc_start, mc_write  : in std_logic;
		mc_done : out std_logic;
		mc_write_data : in std_logic_vector(7 downto 0);
		mc_read_data : out std_logic_vector(7 downto 0);
		clk, reset : in std_logic;
		oe_bar, cs_bar, we_bar : out std_logic

	);
end entity;

architecture testerarch of sram_test is

	signal zero : std_logic_vector (12 downto 0);

begin
	
	zero <= "0000000000000";
	smc_instance : SMC port map
	(
		address => address, 
		ios_data => ios_data, 
		mc_start => mc_start, mc_write => mc_write,
		mc_done => mc_done,
		mc_address => zero,
		mc_write_data => mc_write_data,
		mc_read_data => mc_read_data,
		clk => clk, reset => reset,
		oe_bar => oe_bar, cs_bar => cs_bar,   we_bar => we_bar 
	);
	
end architecture;
