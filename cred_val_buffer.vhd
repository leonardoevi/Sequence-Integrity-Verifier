library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity cred_val_buffer is
    port(
        clk_CV : in std_logic;
        rst_CV : in std_logic;

        cred_rst_CV        : in std_logic;
        cred_dec_CV        : in std_logic;
        
        cred_value_CV      : out std_logic_vector(4 downto 0)
    );
end entity;

architecture CV_arch of cred_val_buffer is 
    signal curr_val_CV, next_val_CV : std_logic_vector(4 downto 0);
begin

    state_reg_CV : process(rst_CV, clk_CV)
    begin
        if rst_CV = '1' then
            curr_val_CV <= (others => '0');
        elsif falling_edge(clk_CV) then
            curr_val_CV <= next_val_CV;
        end if;
    end process;

    -- lambda function
    next_val_CV <= "11111" when cred_rst_CV = '1' else
                std_logic_vector(unsigned(curr_val_CV) - 1) when cred_dec_CV = '1' and unsigned(curr_val_CV) > 0 else
                curr_val_CV;
    
    -- delta function
    cred_value_CV <= curr_val_CV;

end architecture;
