library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity seq_left_buffer is
    port(
        clk_SL : in std_logic;
        rst_SL : in std_logic;

        k_in_SL            : in std_logic_vector(9 downto 0);
        read_input_k_SL    : in std_logic;
        dec_k_SL           : in std_logic;
        
        seq_left_SL           : out std_logic_vector(9 downto 0)
    );
end entity;

architecture SL_arch of seq_left_buffer is 
    signal curr_val_SL, next_val_SL : std_logic_vector(9 downto 0);
	signal input_buffer_SL : std_logic_vector(9 downto 0);
begin
	
-- memorize input on clock rising edge
	buffer_reg_SL : process(clk_SL)
	begin
		if rising_edge(clk_SL) then
			input_buffer_SL <= k_in_SL;
		end if;
	end process;

-- copy memorized input to output on clock falling edge
    state_reg_SL : process(rst_SL, clk_SL)
    begin
        if rst_SL = '1' then
            curr_val_SL <= (others => '0');
        elsif falling_edge(clk_SL) then
            curr_val_SL <= next_val_SL;
        end if;
    end process;

    -- lambda function
    next_val_SL <= input_buffer_SL when read_input_k_SL = '1' else
                std_logic_vector(unsigned(curr_val_SL) - 1) when unsigned(curr_val_SL) > 0 and dec_k_SL = '1' else
                curr_val_SL;
    
    -- delta function
    seq_left_SL <= curr_val_SL;

end architecture;
