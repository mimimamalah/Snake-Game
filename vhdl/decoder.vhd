library ieee;
use ieee.std_logic_1164.all;

entity decoder is
    port(
        address : in  std_logic_vector(15 downto 0);
        cs_LEDS : out std_logic;
        cs_RAM  : out std_logic;
        cs_ROM  : out std_logic
    );
end decoder;

architecture synth of decoder is

    constant c1 : std_logic_vector(15 downto 0) := x"0000";
    constant c2 : std_logic_vector(15 downto 0) := x"0FFC";
    constant c3 : std_logic_vector(15 downto 0) := x"1000";
    constant c4 : std_logic_vector(15 downto 0) := x"1FFC";
    constant c5 : std_logic_vector(15 downto 0) := x"2000";
    constant c6 : std_logic_vector(15 downto 0) := x"200C";

begin

    cs_ROM <= '1' when (c1 <= address and address <= c2) else '0';
    cs_RAM <= '1' when (c3 <= address and address <= c4) else '0';
    cs_LEDS <= '1' when (c5 <= address and address <= c6) else '0';


end synth;
