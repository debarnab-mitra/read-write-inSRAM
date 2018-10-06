library ieee;
use ieee.std_logic_1164.all;

entity Adder16 is 
   port (A, B: in std_logic_vector(15 downto 0); ---------------asuming a > b  -------------
   		 RESULT: out std_logic_vector(15 downto 0));
end entity;

architecture behave of Adder16 is
begin
   process(A,B)
     variable carry: std_logic;
   begin
     carry := '0';
     for I in 0 to 15 loop
        RESULT(I) <= (A(I) xor B(I)) xor carry;
        carry := (carry and (A(I) or B(I))) or (A(I) and B(I));
     end loop;
   end process;
end behave;
