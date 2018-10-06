library std;
library ieee;
use ieee.std_logic_1164.all;
library work;
use work.Components.all;

entity ccu is 	
	 port(
      		adcc_run: out std_logic;
     	 	adcc_output_ready: in std_logic;
      		mc_start, mc_write: out std_logic;
      		mc_done: in std_logic;
      		capture, display: in std_logic;
      		mc_read_data: in std_logic_vector(7 downto 0);
      		mc_write_data: out std_logic_vector(7 downto 0);
     	 	adcc_data: in std_logic_vector(7 downto 0);
      		mc_address: out std_logic_vector(12 downto 0);
      		dac_out: out std_logic_vector(7 downto 0);
      		count_done_out: out std_logic;
      		clk, reset: in std_logic
    		);
end entity;

architecture Struct of ccu is
    signal count_done, T0, T1, T2, T3, T4, T5: std_logic;
begin
    CP: CCUControl
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
        	count_done => count_done,
        	dac_out => dac_out,
        	T0 => T0,
        	T1 => T1,
        	T2 => T2,
        	T3 => T3,
        	T4 => T4,
        	T5 => T5,
        	clk => clk,
        	reset => reset
      		);

    DP: CCUData
      port map(
        	mc_address => mc_address,
        	T0 => T0,
        	T1 => T1,
        	T2 => T2,
        	T3 => T3,
        	T4 => T4,
        	T5 => T5,
        	clk => clk,
        	reset => reset
      		);

    CD: ClockCounter
      port map(
        	clk => clk,
        	reset => reset,
        	count_done => count_done
      		);

    count_done_out <= count_done;
end Struct;


library ieee;
use ieee.std_logic_1164.all;
library work;
use work.Components.all;
entity ClockCounter is
  port (
    	clk, reset: in std_logic;
    	count_done: out std_logic
  	);
end entity ClockCounter;

architecture Struct of ClockCounter is
   signal T0,T1,S: std_logic;
begin

    CP: ClockCounterControl
      port map(
        	T0 => T0,
        	T1 => T1,
        	S => S,
        	count_done => count_done,
        	reset => reset,
        	clk => clk
      		);	

    DP: ClockCounterData
      port map (
        	T0 => T0,
        	T1 => T1,
        	S => S,
        	reset => reset,
        	clk => clk
      		);	
end Struct;

library ieee;
use ieee.std_logic_1164.all;
entity ClockCounterControl is
  port (
    T0, T1: out std_logic;
    S: in std_logic;
    clk, reset: in std_logic;
    count_done: out std_logic
  );
end entity;

architecture Behave of ClockCounterControl is
   type FsmState is (rst, decrement);
   signal fsm_state : FsmState;
begin

   process(fsm_state, S, clk, reset)
      variable next_state: FsmState;
      variable Tvar: std_logic_vector(0 to 1);
      variable count_done_var: std_logic;
  begin
     -- defaults
    Tvar := (others => '0');
    next_state := fsm_state;
    count_done_var := '0';

    case fsm_state is
      	when rst =>
          Tvar(0) := '1';
          next_state := decrement;
      	when decrement =>
          Tvar(1) := '1';
          if (S = '1') then
            count_done_var := '1';
            Tvar(0) := '1';
            Tvar(1) := '0';
          else
            count_done_var := '0';
          end if;
    end case;

    T0 <= Tvar(0); T1 <= Tvar(1);
    count_done <= count_done_var;

    if(clk'event and (clk = '1')) then
      if(reset = '1') then
        fsm_state <= rst;
      else
        fsm_state <= next_state;
      end if;
    end if;

  end process;

end Behave;


library ieee;
use ieee.std_logic_1164.all;
library work;
use work.Components.all;
entity ClockCounterData is
  port (
    T0,T1: in std_logic;
    S: out std_logic;
    clk, reset: in std_logic
  );
end entity;

architecture Mixed of ClockCounterData is
    signal COUNT: std_logic_vector(15 downto 0);
    signal COUNT_in: std_logic_vector(15 downto 0);
    signal decrOut: std_logic_vector(15 downto 0);
    constant C_start : std_logic_vector(15 downto 0) := "1100001101010000";
    signal count_enable: std_logic;

begin
    -- predicate
    S <= '1' when (COUNT = "0000000000000000") else '0';
    --------------------------------------------------------
    --  count-related logic
    --------------------------------------------------------
    -- decrementer
    decr: Decrement16  port map (A => COUNT, B => decrOut);

    -- count register.
    count_enable <=  (T0 or T1);
    COUNT_in <= decrOut when T1 = '1' else C_start;
    count_reg: DataRegister
                   generic map (data_width => 16)
                   port map (Din => COUNT_in,
                             Dout => COUNT,
                             Enable => count_enable,
                             clk => clk);
end Mixed;

library ieee;
use ieee.std_logic_1164.all;
entity CCUControl is
    port(
      	adcc_run: out std_logic;
      	adcc_output_ready: in std_logic;
      	mc_start, mc_write: out std_logic;
      	mc_done: in std_logic;
      	capture, display: in std_logic;
      	mc_read_data: in std_logic_vector(7 downto 0);
      	mc_write_data: out std_logic_vector(7 downto 0);
      	adcc_data: in std_logic_vector(7 downto 0);
      	count_done: in std_logic;
      	dac_out: out std_logic_vector(7 downto 0);
      	T0, T1, T2, T3, T4, T5: out std_logic;
      	clk, reset: in std_logic
    	);
end entity;

architecture Behave of CCUControl is
   type FsmState is (initialize, wait_state, adc_read, write_memory, end_write, end_read, smc_read);
   signal fsm_state : FsmState;
begin

   process(fsm_state, clk, reset)
      variable next_state: FsmState;
      variable Tvar: std_logic_vector(0 to 5);
      variable nadc_run, nmc_start, nmc_write: std_logic;
      variable nmc_write_data, ndac_out: std_logic_vector(7 downto 0);
  begin
     -- defaults
    Tvar := (others => '0');
    next_state := fsm_state;
    case fsm_state is
      	when initialize =>
      		Tvar(0) := '1';
        	Tvar(2) := '1';
        	next_state := wait_state;
        	nadc_run := '0';
        	nmc_start := '0';
        	nmc_write := '0';
      	when wait_state =>
        	if (capture = '1') then
          		nadc_run := '1';
          		next_state := adc_read;
        	elsif (display = '1') then
          		nmc_start := '1';
          		nmc_write := '0';
          		next_state := smc_read;
          		Tvar(4) := '1';
        	end if;
      	when adc_read =>
        	if (adcc_output_ready = '1') then
          		nadc_run := '0';
          		nmc_start := '1';
          		nmc_write := '1';
          		nmc_write_data := adcc_data;
          		Tvar(5) := '1';
          		next_state := write_memory;
        	end if;
     	when write_memory =>
        	if (mc_done = '1') then
          		nmc_start := '0';
          		Tvar(3) := '1';
          		next_state := end_write;
        	end if;
      	when end_write =>
        	if (count_done = '1') then
          		next_state := wait_state;
        	end if;
      	when smc_read =>
        	if (mc_done = '1') then
          		nmc_start := '0';
          		Tvar(1) := '1';
          		next_state := end_read;
        	end if;
      	when end_read =>
      	  	if (count_done = '1') then
          		next_state := wait_state;
          		ndac_out := mc_read_data;
        	end if;
    end case;

    T0 <= Tvar(0); T1 <= Tvar(1); T2 <= Tvar(2);
    T3 <= Tvar(3); T4 <= Tvar(4); T5 <= Tvar(5);

    if(reset = '1') then
      	adcc_run <= '0';
      	mc_write <= '0';
      	mc_start <= '0';
      	mc_write_data <= "00000000";
      	dac_out <= "11111110";
    else
      	adcc_run <= nadc_run;
      	mc_write <= nmc_write;
      	mc_start <= nmc_start;
      	mc_write_data <= nmc_write_data;
      	dac_out <= ndac_out;
     end if;
    if(clk'event and (clk = '1')) then
      	if(reset = '1') then
        	fsm_state <= initialize;
      	else
      		fsm_state <= next_state;
      	end if;
    end if;
  end process;
end Behave;


library ieee;
use ieee.std_logic_1164.all;
library work;
use work.Components.all;
library work;
use work.Components.all;
entity CCUData is
  port (
    T0,T1,T2,T3,T4, T5: in std_logic;
    clk, reset: in std_logic;
    mc_address: out std_logic_vector(12 downto 0)
  );
end entity;

architecture Mixed of CCUData is
    signal addr_read, addr_write: std_logic_vector(12 downto 0);
    signal addr_read_in, addr_write_in, mc_address_in: std_logic_vector(12 downto 0);
    signal incr_out1: std_logic_vector(12 downto 0);
    signal incr_out2: std_logic_vector(12 downto 0);
    constant C_start : std_logic_vector(12 downto 0) := "0000000000000";
    signal addr_read_enable, addr_write_enable, mc_address_enable: std_logic;

begin
    --------------------------------------------------------
    --  count-related logic
    --------------------------------------------------------
    -- decrementer
    --decr: Decrement16  port map (A => COUNT, B => decrOut);
    incr1: Increment13 port map(A => addr_read, B => incr_out1);
    incr2: Increment13 port map(A => addr_write, B => incr_out2);

    -- addr_read register.
    addr_read_enable <=  (T0 or T1);
    addr_read_in <= incr_out1 when T1 = '1' else C_start;
    addr_read_reg: DataRegister
                   generic map (data_width => 13)
                   port map (Din => addr_read_in,
                             Dout => addr_read,
                             Enable => addr_read_enable,
                             clk => clk);

    -- addr_read register.
    addr_write_enable <=  (T2 or T3);
    addr_write_in <= incr_out2 when T3 = '1' else C_start;
    addr_write_reg: DataRegister
                   generic map (data_width => 13)
                   port map (Din => addr_write_in,
                             Dout => addr_write,
                             Enable => addr_write_enable,
                             clk => clk);

    mc_address_in <= addr_read when T4 = '1' else addr_write;
    mc_address_enable <= (T4 or T5);

    rr: DataRegister generic map(data_width => 13)
      		port map(Din => mc_address_in, Dout => mc_address, Enable => mc_address_enable, clk => clk);

end Mixed;
