library std;
library ieee;
use ieee.std_logic_1164.all;
library work;
use work.Components.all;


entity ccu_test is

	port
	(
      		adcc_run: out std_logic;
     	 	adcc_output_ready: in std_logic;
      		capture, display: in std_logic;
      		adcc_data: in std_logic_vector(7 downto 0);
      	        dac_out: out std_logic_vector(7 downto 0);
		count_done_out: out std_logic;
      		
		ios_data :inout std_logic_vector (7 downto 0);
		address : out std_logic_vector(12 downto 0);
		cs_bar, we_bar, oe_bar : out std_logic;
      		clk, reset: in std_logic

	);
end entity;

architecture testerarch of ccu_test is

	signal zero : std_logic_vector (12 downto 0);
	signal mc_start, mc_write,mc_done : std_logic;
	signal mc_address : std_logic_vector ( 12 downto 0);
	signal mc_write_data, mc_read_data : std_logic_vector(7 downto 0);
	
	
	
begin
	
	zero <= "0000000000000";

	smc_instance : SMC port map
	(
		address => address, 
		ios_data => ios_data, 
		mc_start => mc_start, mc_write => mc_write,
		mc_done => mc_done,
		mc_address => mc_address,
		mc_write_data => mc_write_data,
		mc_read_data => mc_read_data,
		clk => clk, reset => reset,
		oe_bar => oe_bar, cs_bar => cs_bar,   we_bar => we_bar 
	);

	ccu_instance : ccu port map
	(
      		adcc_run => adcc_run,
     	 	adcc_output_ready => adcc_output_ready, 
      		mc_start => mc_start, mc_write => mc_write,
      		mc_done => mc_done,
      		capture => capture, display => display,
      		mc_read_data => mc_read_data,
      		mc_write_data => mc_write_data,
     	 	adcc_data => adcc_data,
      		mc_address => mc_address,
      		dac_out => dac_out,
      		count_done_out => count_done_out,
      		clk => clk, reset => reset
	);

	
end architecture;
