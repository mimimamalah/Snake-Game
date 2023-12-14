library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity RAM is
    port(
        clk     : in  std_logic;
        cs      : in  std_logic;
        read    : in  std_logic;
        write   : in  std_logic;
        address : in  std_logic_vector(9 downto 0);
        wrdata  : in  std_logic_vector(31 downto 0);
        rddata  : out std_logic_vector(31 downto 0));
end RAM;

architecture synth of RAM is
    type reg_type is array(0 to 1023) of std_logic_vector(31 downto 0); 
    signal reg: reg_type := (others => (others => '0'));
begin

    myProcessRead : process(clk)
    begin 
    if(rising_edge(clk)) then 
     rddata <= (others => 'Z');
       if(read = '1' and cs = '1') then 
       rddata <= reg(to_integer(unsigned(address)));
       end if;
     end if;

    end process; 

    myProcessWrite : process(clk)
    begin 
    if(rising_edge(clk)) then 
       if(write = '1' and cs = '1') then 
       reg(to_integer(unsigned(address))) <= wrdata;
       end if;
    end if;

    end process; 

end synth;
