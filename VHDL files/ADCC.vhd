library ieee;
use ieee.std_logic_1164.all;
library work;
use work.Components.all;

entity ADCC is
	port (  din : in std_logic_vector(7 downto 0);
		cs_bar, wr_bar, rd_bar : out std_logic;
		intr_bar : in std_logic;
		adcc_run : in std_logic;
		adcc_output_ready : out std_logic;
		adcc_data : out std_logic_vector(7 downto 0);
		clk, reset : in std_logic );
end entity;

architecture behave of ADCC is
	type FsmState is (rst, write_state, wait_for_intr, read_state, wait_for_1ms);
	signal fsm_state : FsmState := rst;
	signal count : std_logic_vector(15 downto 0);
	signal RD : std_logic;
	signal bool, T, intr_bar_var : std_logic;
	signal count_reg, count_in : std_logic_vector(15 downto 0);
	signal reg_in, reg_out : std_logic_vector(7 downto 0);
	constant C15 : std_logic_vector(15 downto 0) := "0000000000000001";
begin
	reg1 : dataregister generic map (data_width => 8)
						port map (Din => reg_in, Dout => reg_out, enable => RD, clk => clk);
	reg2 : dataregister generic map (data_width => 16)
						port map (Din => count_in, Dout => count, enable => '1' , clk => clk);
	reg_in <= din when (RD = '1') else reg_out;	
	
	process(clk)
    	begin
       		if(clk'event and (clk  = '1')) then
               		intr_bar_var <= intr_bar;
       		end if;
    	end process;

	rd_bar <= not RD;
	adcc_data <= reg_in;
		
	add : Adder16 port map(A => count, B => C15, RESULT => count_reg);
	count_in <= C15 when (bool = '1') else count_reg;
	--bool <= adcc_run or reset;
	bool <= T or reset;
	process(fsm_state, adcc_run, clk, reset)
      	variable next_state: FsmState;
	variable cs_bar_var, wr_bar_var, read_state_var, adcc_output_ready_var, T_var : std_logic;
   	begin
	        next_state := fsm_state;
		wr_bar_var := '1';
		read_state_var := '0';
		adcc_output_ready_var := '0';
		T_var := '0';
	        case fsm_state is 
	          when rst =>
	                if(adcc_run = '1') then
	                	next_state := write_state;
				cs_bar_var := '0';
				T_var := '1';
			else 
				next_state := rst;
	        	end if;
		  when write_state =>
			if(count(5) = '1') then
				next_state := wait_for_intr;
			else 
				wr_bar_var := '0';
				next_state := write_state;
			end if;
		  when wait_for_intr =>
			if(intr_bar_var = '1') then
				next_state := wait_for_intr;
			else
				next_state := read_state;
				read_state_var := '1';
			end if;
		  when read_state =>
			if(count(14) = '1') then
				next_state := wait_for_1ms;
				read_state_var := '0';
			else 
				read_state_var := '1';
				next_state := read_state;		
			end if;
		  when wait_for_1ms =>
			if(count = "1100001101010000") then
				next_state := rst;
				adcc_output_ready_var := '1';
			else 
				next_state := wait_for_1ms;
			end if;
	     end case;

	     RD <= read_state_var;
	     cs_bar <= cs_bar_var;
	     wr_bar <= wr_bar_var;
	     T <= T_var;
	     adcc_output_ready <= adcc_output_ready_var;
		
	     if(clk'event and (clk = '1')) then
		if(reset = '1') then
             		fsm_state <= rst;
        	else
        	     	fsm_state <= next_state;
        	end if;
     	     end if;
	   end process;
	
end behave;
