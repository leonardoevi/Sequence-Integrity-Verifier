library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity mem_addr_buffer is
    port(
        clk_MA : in std_logic;
        rst_MA : in std_logic;

        start_addr_MA          : in std_logic_vector(15 downto 0);
        read_input_mem_addr_MA : in std_logic;
        mem_addr_next_MA       : in std_logic;
        
        mem_addr_MA           : out std_logic_vector(15 downto 0)
    );
end entity;

architecture MA_arch of mem_addr_buffer is
    signal curr_addr_MA, next_addr_MA : std_logic_vector(15 downto 0);
	signal input_buffer_MA : std_logic_vector(15 downto 0);
begin
	
-- memorize input on clock rising edge
	buffer_reg_MA : process(clk_MA)
	begin
		if rising_edge(clk_MA) then
			input_buffer_MA <= start_addr_MA;
		end if;
	end process;

-- copy memorized input to output on clock falling edge
    state_reg_MA : process(rst_MA, clk_MA)
    begin
        if rst_MA = '1' then
            curr_addr_MA <= (others => '0');
        elsif falling_edge(clk_MA) then
            curr_addr_MA <= next_addr_MA;
        end if;
    end process;

    -- lambda function
    next_addr_MA <= input_buffer_MA when read_input_mem_addr_MA = '1' else
                std_logic_vector(unsigned(curr_addr_MA) + 1) when mem_addr_next_MA = '1' else
                curr_addr_MA;
    
    -- delta function
   mem_addr_MA <= curr_addr_MA;

end architecture;