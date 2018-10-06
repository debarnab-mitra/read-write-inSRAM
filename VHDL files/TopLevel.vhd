library std;
library ieee;
use ieee.std_logic_1164.all;
library work;
use work.Components.all;

entity TopLevel is
  port (
  	-- CCU outside world
    capture, display: in std_logic;
    dac_out: out std_logic_vector(7 downto 0);
    --count_done_out: out std_logic;
    -- ADCC outside world
    din: in std_logic_vector(7 downto 0);
    intr_bar: in std_logic;
    cs_bar, wr_bar, rd_bar: out std_logic;

    -- SMC outside world
    ios_data: inout std_logic_vector(7 downto 0);
    oe_bar, we_bar, cs_bar_smc: out std_logic;
    address: out std_logic_vector(12 downto 0);

    -- general
    clk, reset: in std_logic
  );
end entity TopLevel;

architecture Struct of TopLevel is
	-- ADCC signals
	signal adcc_run: std_logic;
	signal adcc_data: std_logic_vector(7 downto 0);
	signal adcc_output_ready: std_logic;
	-- SMC signals
	signal mc_start, mc_write, mc_done: std_logic;
	signal mc_read_data: std_logic_vector(7 downto 0);
	signal mc_write_data: std_logic_vector(7 downto 0);
	signal mc_address: std_logic_vector(12 downto 0);

begin
	adcc_control: ADCC
    port map(
      din => din,
      adcc_data => adcc_data,
      cs_bar => cs_bar, wr_bar => wr_bar, rd_bar => rd_bar,
      intr_bar => intr_bar,
      adcc_run => adcc_run,
      adcc_output_ready => adcc_output_ready,
      clk => clk, reset => reset
    );

    central_control: CCU
    port map(
      adcc_run => adcc_run,
      adcc_output_ready => adcc_output_ready,
      mc_start => mc_start,
      mc_write => mc_write,
      mc_done => mc_done,
      capture => capture,
      display => display,
      mc_read_data => mc_read_data,
      mc_write_data => mc_write_data,
      adcc_data => adcc_data,
      mc_address => mc_address,
      dac_out => dac_out,
      --count_done_out => count_done_out,
      clk => clk,
      reset => reset
    );

    memory_control: SMC
    port map(
      ios_data => ios_data,
      mc_read_data => mc_read_data,
      mc_write_data => mc_write_data,
      mc_done => mc_done,
      mc_start => mc_start,
      mc_write => mc_write,
      oe_bar => oe_bar,
      we_bar => we_bar,
      cs_bar => cs_bar_smc,
      mc_address => mc_address,
      address => address,
      clk => clk,
      reset => reset
    );

end Struct;
