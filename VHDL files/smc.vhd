library std;
library ieee;
use ieee.std_logic_1164.all;
library work;
use work.Components.all;

entity SMC is
    port(
      ios_data: inout std_logic_vector(7 downto 0);
      mc_read_data: out std_logic_vector(7 downto 0);
      mc_write_data: in std_logic_vector(7 downto 0);
      mc_done: out std_logic;
      mc_start, mc_write: in std_logic;
      oe_bar, we_bar, cs_bar: out std_logic;
      mc_address: in std_logic_vector(12 downto 0);
      address: out std_logic_vector(12 downto 0);
      clk, reset: in std_logic
    );
end entity SMC;

architecture Struct of SMC is   
    type FsmState is (rst, write_state1, write_state2, write_state3, write_state4, write_done,
                      read_state1, read_state2, read_state3, read_done);
    signal state : FsmState;

begin
    	process(clk, reset, state)
        variable next_state: FsmState;
        variable cs_bar_var: std_logic := '1';
        variable we_bar_var: std_logic := '1';
        variable oe_bar_var: std_logic := '1';
        variable mc_done_var: std_logic;
        variable mc_read_data_var: std_logic_vector(7 downto 0);
        variable ios_data_var: std_logic_vector(7 downto 0) ;
        variable address_var: std_logic_vector(12 downto 0);

    begin
      	-- default values.
      	next_state := state;
      	cs_bar_var := '1';
      	we_bar_var := '1';
      	oe_bar_var := '1';
      	address_var := mc_address;
      	mc_done_var := '0';
      	ios_data_var := "ZZZZZZZZ";
      	case state is
        	when rst =>
          		if (mc_start = '1') then
            			address_var := mc_address;
            			if (mc_write = '1') then
              				next_state := write_state1;
            			else
              				next_state := read_state1;
            			end if;
          		end if;
        	when write_state1 =>
          		oe_bar_var := '1';
          		next_state := write_state2;
        	when write_state2 =>
          		cs_bar_var := '0';
          		next_state := write_state3;
        	when write_state3 =>
          		cs_bar_var := '0';
          		we_bar_var := '0';
          		next_state := write_state4;
        	when write_state4 =>
          		cs_bar_var := '0';
          		we_bar_var := '0';
          		ios_data_var := mc_write_data;
          		next_state := write_done;
        	when write_done =>
          		cs_bar_var := '1';
          		we_bar_var := '1';
          		mc_done_var := '1';
          		next_state := rst;
        	when read_state1 =>
          		cs_bar_var := '0';
          		next_state := read_state2;
        	when read_state2 =>
          		cs_bar_var := '0';
          		oe_bar_var := '0';
          		next_state := read_state3;
        	when read_state3 =>
          		oe_bar_var := '0';
          		cs_bar_var := '0';
          		mc_read_data_var := ios_data;
          		next_state := read_done;
        	when read_done =>
          		mc_done_var := '1';
          		oe_bar_var := '1';
          		cs_bar_var := '1';
          		next_state := rst;
      end case;

      if(reset = '1') then
        	cs_bar <= '1';
        	we_bar <= '1';
        	oe_bar <= '1';
        	mc_done <= '0';
        	ios_data <= "ZZZZZZZZ";
        	mc_read_data <= "01010101";
        	address <= "0000000000000";
      else
        	cs_bar <= cs_bar_var;
        	we_bar <= we_bar_var;
        	oe_bar <= oe_bar_var;
        	ios_data <= ios_data_var;
        	mc_done <= mc_done_var;
        	mc_read_data <= mc_read_data_var;
        	address <= address_var;
      end if;

      if(clk'event and (clk = '1')) then
        	if(reset = '1') then
          		state <= rst;
        	else
          		state <= next_state;
        	end if;
      end if;

    end process;

end Struct;
