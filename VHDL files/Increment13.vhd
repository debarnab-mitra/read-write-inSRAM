library ieee;
use ieee.std_logic_1164.all;
entity Increment13 is
   port (A: in std_logic_vector(12 downto 0); B: out std_logic_vector(12 downto 0));
end entity Increment13;
architecture Serial of Increment13 is
begin
  process(A)
    variable borrow: std_logic;
  begin
    borrow := '1';
    for I in 0 to 12 loop
       B(I) <= A(I) xor borrow;
       borrow := borrow and A(I);
    end loop;
  end process;
end Serial;
