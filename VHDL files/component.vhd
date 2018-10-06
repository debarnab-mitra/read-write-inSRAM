library std;
library ieee;
use ieee.std_logic_1164.all;

------------------------components for adcc----------------

package Components is

	component ADCC is 
		port ( din : in std_logic_vector(7 downto 0);
		cs_bar, wr_bar, rd_bar : out std_logic;
		intr_bar : in std_logic;
		adcc_run:in std_logic;
		adcc_output_ready : out std_logic;
		adcc_data : out std_logic_vector(7 downto 0);
		clk, reset : in std_logic );
	end component;

--------------------- adder for adcc-------------------
   component Adder16 is 
		 port (A, B: in std_logic_vector(15 downto 0); ---------------asuming a > b  -------------
   		 RESULT: out std_logic_vector(15 downto 0));
   end component adder16;
--------------------------------------------------
  
----------------------------components for SMC---------------
   component sram_test is
	port
	(
		address : out std_logic_vector(12 downto 0);
		ios_data :      inout std_logic_vector (7 downto 0);
		mc_start, mc_write  : in std_logic;
		mc_done : out std_logic;
		--mc_address : in std_logic_vector (12 downto 0);
		mc_write_data : in std_logic_vector(7 downto 0);
		mc_read_data : out std_logic_vector(7 downto 0);
		clk, reset : in std_logic;
		oe_bar, cs_bar, we_bar : out std_logic

	);
  end component;
  component SMC is 
	port(	
		mc_start : in std_logic;
		mc_write : in std_logic;
		mc_address : in std_logic_vector(12 downto 0);
		mc_write_data : in std_logic_vector(7 downto 0);
		mc_done : out std_logic;
		mc_read_data : out std_logic_vector(7 downto 0);
		ios_data : inout std_logic_vector(7 downto 0);
		address : out std_logic_vector(12 downto 0);
		cs_bar, we_bar, oe_bar : out std_logic;
		clk, reset : in std_logic
	    );
  end component;
-----------------------------

---------------------------------
 component DataRegister is
	generic (data_width:integer);
	port (Din: in std_logic_vector(data_width-1 downto 0);
	      Dout: out std_logic_vector(data_width-1 downto 0);
	      clk, enable: in std_logic);
  end component DataRegister;
------------------ components for ccu-------------
 component ccu_test is
	port
	(
      		adcc_run: out std_logic;
     	 	adcc_output_ready: in std_logic;
      		capture, display: in std_logic;
      		adcc_data: in std_logic_vector(7 downto 0);
      	        dac_out: out std_logic_vector(7 downto 0);
      		
		ios_data :	inout std_logic_vector(7 downto 0);
		address : out std_logic_vector(12 downto 0);
		cs_bar, we_bar, oe_bar : out std_logic;
      		clk, reset: in std_logic

	);
 end component ccu_test; 
 component ccu is 
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

	end component; 


 component CCUControl is
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
  end component CCUControl;

  component CCUData is
    port(
      mc_address: out std_logic_vector(12 downto 0);
      T0, T1, T2, T3, T4, T5: in std_logic;
      clk, reset: in std_logic
    );
  end component CCUData;

  component ClockCounter is
  port (
    clk, reset: in std_logic;
    count_done: out std_logic
  );
  end component;

  component ClockCounterControl is
  port (
    T0, T1: out std_logic;
    S: in std_logic;
    clk, reset: in std_logic;
    count_done: out std_logic
  );
  end component;

  component ClockCounterData is
  port (
    T0, T1: in std_logic;
    S: out std_logic;
    clk, reset: in std_logic
  );
  end component;

	component Decrement16 is
        port (A: in std_logic_vector(15 downto 0); B: out std_logic_vector(15 downto 0));
  end component Decrement16;

	component Decrement9 is
        port (A: in std_logic_vector(8 downto 0); B: out std_logic_vector(8 downto 0));
  end component Decrement9;

	component Increment13 is
        port (A: in std_logic_vector(12 downto 0); B: out std_logic_vector(12 downto 0));
  end component Increment13;

------------------------------------------------------------------------------------------
end package;
