library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity controller is
    port(
        clk     : in  std_logic;
        reset_n : in  std_logic;
        read    : out std_logic;
        write   : out std_logic;
        address : out std_logic_vector(15 downto 0);
        rddata  : in  std_logic_vector(31 downto 0);
        wrdata  : out std_logic_vector(31 downto 0)
    );
end controller;

architecture synth of controller is

    signal ROMaddr = std_logic_vector(15 downto 0);
    signal length = std_logic_vector(15 downto 0);
    signal rdaddr = std_logic_vector(15 downto 0);
    signal wraddr = std_logic_vector(15 downto 0);

    TYPE State_type IS (S0, S1, S2, S3, S4, S5);  
	SIGNAL state : State_Type; 
    
    begin

    finite_state_machine : process(clk, reset_n)
     begin
        if(reset_n = '1') then
            state <= S0;
            ROMaddr <= 
            length <= (others => (others => '0'));
            rdaddr <= (others => (others => '0'));
            wraddr <= (others => (others => '0'));
        elsif(rising_edge(clk)) then
            
            case state is 
               when S0 =>  ROMaddr <= for i in 0 to 15 loop
                address <= std_logic_vector(to_unsigned(i + 4, 16)
               when S1 => 
               when S2 => 
               when S3 => 
               when S4 => 
               when S5 => 




     end process;   



end synth;
