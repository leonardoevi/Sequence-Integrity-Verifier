library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity last_valid_val_buffer is
    port(
        clk_LV : in std_logic;
        rst_LV : in std_logic;

        update_valid_val_LV    : in std_logic;
        mem_data_LV            : in std_logic_vector(7 downto 0);
        
        valid_value_LV         : out std_logic_vector(7 downto 0)
    );
end entity;

architecture LV_arch of last_valid_val_buffer is 
    signal curr_val_LV, next_val_LV : std_logic_vector(7 downto 0);
	signal input_buffer_LV : std_logic_vector(7 downto 0);
begin

-- memorize input on clock rising edge
	buffer_reg_LV : process(clk_LV)
	begin
		if rising_edge(clk_LV) then
			input_buffer_LV <= mem_data_LV;
		end if;
	end process;

-- copy memorized input to output on clock falling edge
    state_reg_LV : process(rst_LV, clk_LV)
    begin
        if rst_LV = '1' then
            curr_val_LV <= (others => '0');
        elsif falling_edge(clk_LV) then
            curr_val_LV <= next_val_LV;
        end if;
    end process;

    -- lambda function
    next_val_LV <= input_buffer_LV when update_valid_val_LV = '1' and input_buffer_LV /= "00000000" else
                curr_val_LV;
    
    -- delta function
    valid_value_LV <= curr_val_LV;

end architecture;