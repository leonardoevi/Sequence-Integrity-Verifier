library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity project_reti_logiche is
    port (
                i_clk : in std_logic;
                i_rst : in std_logic;
                i_start : in std_logic;
                i_add : in std_logic_vector(15 downto 0);
                i_k   : in std_logic_vector(9 downto 0);
                
                o_done : out std_logic;
                
                o_mem_addr : out std_logic_vector(15 downto 0);
                i_mem_data : in  std_logic_vector(7 downto 0);
                o_mem_data : out std_logic_vector(7 downto 0);
                o_mem_we   : out std_logic;
                o_mem_en   : out std_logic
        );
end entity;

architecture struct of project_reti_logiche is

			-- DECLARING COMPONENTS --
	
	component fsm is
		port(
			clk_FSM : in std_logic;
			rst_FSM : in std_logic;
			start_FSM : in std_logic;

			-- data readings
			mem_data_FSM : in std_logic_vector(7 downto 0);

			
			done_FSM : out std_logic;
			mem_en_FSM : out std_logic;
			mem_we_FSM : out std_logic;

			-- squence left control
			read_input_k_FSM : out std_logic;
			dec_k_FSM : out std_logic;
			seq_left_FSM : in std_logic_vector(9 downto 0);

			-- memory address control
			read_input_mem_addr_FSM : out std_logic;
			mem_addr_next_FSM : out std_logic;

			-- last valid value control
			update_valid_val_FSM : out std_logic;

			-- credibility value control
			cred_rst_FSM : out std_logic;
			cred_dec_FSM : out std_logic;

			-- output control
			out_sel_FSM : out std_logic;
			
			-- reset propagate
			reset_prop_FSM : out std_logic
		);
	end component;
	
	component seq_left_buffer is
		port(
			clk_SL : in std_logic;
			rst_SL : in std_logic;

			k_in_SL            : in std_logic_vector(9 downto 0);
			read_input_k_SL    : in std_logic;
			dec_k_SL           : in std_logic;
			
			seq_left_SL           : out std_logic_vector(9 downto 0)
		);
	end component;
	
	component mem_addr_buffer is
		port(
			clk_MA : in std_logic;
			rst_MA : in std_logic;

			start_addr_MA          : in std_logic_vector(15 downto 0);
			read_input_mem_addr_MA : in std_logic;
			mem_addr_next_MA       : in std_logic;
			
			mem_addr_MA           : out std_logic_vector(15 downto 0)
		);
	end component;

	component last_valid_val_buffer is
		port(
			clk_LV : in std_logic;
			rst_LV : in std_logic;

			update_valid_val_LV    : in std_logic;
			mem_data_LV            : in std_logic_vector(7 downto 0);
			
			valid_value_LV         : out std_logic_vector(7 downto 0)
		);
	end component;
	
	component cred_val_buffer is
		port(
			clk_CV : in std_logic;
			rst_CV : in std_logic;

			cred_rst_CV        : in std_logic;
			cred_dec_CV        : in std_logic;
			
			cred_value_CV      : out std_logic_vector(4 downto 0)
		);
	end component;
	
	signal int_reset_prop			: std_logic;
	signal int_read_input_k 		: std_logic;
	signal int_seq_left 			: std_logic_vector(9 downto 0);
	signal int_dec_k 				: std_logic;
	signal int_read_input_mem_addr	: std_logic;
	signal int_mem_addr_next 		: std_logic;
	signal int_update_valid_val 	: std_logic;
	signal int_valid_value			: std_logic_vector(7 downto 0);
	signal int_cred_value			: std_logic_vector(4 downto 0);
	signal int_cred_rst 			: std_logic;
	signal int_cred_dec 			: std_logic;
	signal int_out_sel 				: std_logic;

begin

			-- CONNECTING COMPONENTS --

	finite_state_machine_component : fsm
		port map(	
					clk_FSM 				=> i_clk,
					rst_FSM 				=> i_rst,
					start_FSM 				=> i_start,
					read_input_k_FSM 		=> int_read_input_k,
					seq_left_FSM 			=> int_seq_left,
					dec_k_FSM 				=> int_dec_k,
					read_input_mem_addr_FSM => int_read_input_mem_addr,
					mem_addr_next_FSM 		=> int_mem_addr_next,
					mem_data_FSM 			=> i_mem_data,
					update_valid_val_FSM 	=> int_update_valid_val,
					cred_rst_FSM 			=> int_cred_rst,
					cred_dec_FSM 			=> int_cred_dec,
					out_sel_FSM 			=> int_out_sel,
					mem_we_FSM 				=> o_mem_we,
					mem_en_FSM 				=> o_mem_en,
					done_FSM 				=> o_done,
					reset_prop_FSM			=> int_reset_prop
				);
				
	sequence_left_component : seq_left_buffer
		port map(	
					clk_SL 			=> i_clk,
					rst_SL 			=> int_reset_prop,
					k_in_SL 		=> i_k,
					read_input_k_SL	=> int_read_input_k,
					seq_left_SL 	=> int_seq_left,
					dec_k_SL 		=> int_dec_k
				);
				
	memory_address_component : mem_addr_buffer
		port map(
					clk_MA					=> i_clk,
					rst_MA 					=> int_reset_prop,
					start_addr_MA 			=> i_add,
					read_input_mem_addr_MA	=> int_read_input_mem_addr,
					mem_addr_next_MA 		=> int_mem_addr_next,
					mem_addr_MA 			=> o_mem_addr
				);
				
	last_valid_value_component : last_valid_val_buffer
		port map(
					clk_LV				=> i_clk,
					rst_LV 				=> int_reset_prop,
					mem_data_LV 		=> i_mem_data,
					update_valid_val_LV	=> int_update_valid_val,
					valid_value_LV 		=> int_valid_value
				);
	
	credibility_value_component : cred_val_buffer
		port map(
					clk_CV 			=> i_clk,
					rst_CV 			=> int_reset_prop,
					cred_rst_CV		=> int_cred_rst,
					cred_dec_CV 	=> int_cred_dec,
					cred_value_CV	=> int_cred_value
				);

	o_mem_data <= int_valid_value when int_out_sel = '0' else
					"000" & int_cred_value;

end architecture;

			-- COMPONENTS ARCHITECTURE --
			
	-- SEQUENCE LEFT BUFFER --			
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



	-- MEMORY ADDRESS BUFFER --
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


	-- LAST VALID VALUE BUFFER --
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


	-- CREDIBILITY VALUE BUFFER --
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



	-- FSM --
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fsm is
    port(
        clk_FSM : in std_logic;
        rst_FSM : in std_logic;
        start_FSM : in std_logic;

        -- data readings
        mem_data_FSM : in std_logic_vector(7 downto 0);

        
        done_FSM : out std_logic;
        mem_en_FSM : out std_logic;
        mem_we_FSM : out std_logic;

        -- squence left control
        read_input_k_FSM : out std_logic;
        dec_k_FSM : out std_logic;
        seq_left_FSM : in std_logic_vector(9 downto 0);

        -- memory address control
        read_input_mem_addr_FSM : out std_logic;
        mem_addr_next_FSM : out std_logic;

        -- last valid value control
        update_valid_val_FSM : out std_logic;

        -- credibility value control
        cred_rst_FSM : out std_logic;
        cred_dec_FSM : out std_logic;

        -- output control
        out_sel_FSM : out std_logic;
		
		-- reset propagate
		reset_prop_FSM : out std_logic
    );
end entity;

architecture FSM_arch of fsm is
    type S is   (     
                    reset,					--0000
                    read_input_data,		--0001
					wait_for_mem_1,			--0010
                    read_first_val,			--0011
                    set_cred_zero,			--0100
                    ask_next_val_1,			--0101
                    set_cred_31,			--0110
                    ask_next_val_2,			--0111
					wait_for_mem_2,			--1000
                    evaluate_mem_input,		--1001
                    replace_invalid_value,	--1010
                    set_cred_val,			--1011
                    seq_complete,			--1100
					
					invalid					--XXXX
                );
    signal  curr_state_FSM, next_state_FSM : S;
begin

    state_reg_FSM : process(rst_FSM, clk_FSM)
    begin
        if rst_FSM = '1' then
            curr_state_FSM <= reset;
        elsif rising_edge(clk_FSM) then
            curr_state_FSM <= next_state_FSM;
        end if;
    end process;

    -- lambda function						-- reset
    next_state_FSM <=   read_input_data 		when curr_state_FSM = reset and start_FSM = '1' else
											
											-- read_input_data
                    wait_for_mem_1 			when curr_state_FSM = read_input_data and unsigned(seq_left_FSM) /= 0 else
					seq_complete			when curr_state_FSM = read_input_data and unsigned(seq_left_FSM) = 0 else
					
											-- wait_for_mem_1
					read_first_val			when curr_state_FSM = wait_for_mem_1 else
											
											-- read_first_val
					set_cred_zero 			when curr_state_FSM = read_first_val and unsigned(mem_data_FSM) = 0 else
					set_cred_31 			when curr_state_FSM = read_first_val and unsigned(mem_data_FSM) /= 0 else
					
											-- set_cred_zero
					ask_next_val_1 			when curr_state_FSM = set_cred_zero and unsigned(seq_left_FSM) /= 0 else
					seq_complete			when curr_state_FSM = set_cred_zero and unsigned(seq_left_FSM) = 0 else
											
											-- ask_next_val_1
					wait_for_mem_1			when curr_state_FSM = ask_next_val_1 else
											
											-- set_cred_31
					ask_next_val_2 			when curr_state_FSM = set_cred_31 and unsigned(seq_left_FSM) /= 0 else
					seq_complete			when curr_state_FSM = set_cred_31 and unsigned(seq_left_FSM) = 0 else
											
											-- ask_next_val_2
					wait_for_mem_2 			when curr_state_FSM = ask_next_val_2 else
					
											-- wait_for_mem_2
					evaluate_mem_input		when curr_state_FSM = wait_for_mem_2 else
											
											-- evaluate_mem_input
					set_cred_31 			when curr_state_FSM = evaluate_mem_input and unsigned(mem_data_FSM) /= 0 else
					replace_invalid_value	when curr_state_FSM = evaluate_mem_input and unsigned(mem_data_FSM) = 0 else
											
											-- replace_invalid_value
					set_cred_val 			when curr_state_FSM = replace_invalid_value else
											
											-- set_cred_val
					ask_next_val_2			when curr_state_FSM = set_cred_val and unsigned(seq_left_FSM) /= 0 else
					seq_complete			when curr_state_FSM = set_cred_val and unsigned(seq_left_FSM) = 0 else
											
											-- seq_complete
					reset					when curr_state_FSM = seq_complete and start_FSM = '0' else
					
					curr_state_FSM;

	-- delta function
	df : process(curr_state_FSM)
	begin
		case curr_state_FSM is
			when reset =>
				done_FSM 				<= '0';
				mem_en_FSM 				<= '0';
				mem_we_FSM 				<= '0';
				read_input_k_FSM		<= '0';
				dec_k_FSM 				<= '0';
				read_input_mem_addr_FSM	<= '0';
				mem_addr_next_FSM 		<= '0';
				update_valid_val_FSM 	<= '0';
				cred_rst_FSM 			<= '0';
				cred_dec_FSM 			<= '0';
				out_sel_FSM 			<= '0';
				reset_prop_FSM			<= '1';
			
			when read_input_data =>
				done_FSM 				<= '0';
				mem_en_FSM 				<= '1';
				mem_we_FSM 				<= '0';
				read_input_k_FSM		<= '1';
				dec_k_FSM 				<= '0';
				read_input_mem_addr_FSM	<= '1';
				mem_addr_next_FSM 		<= '0';
				update_valid_val_FSM 	<= '0';
				cred_rst_FSM 			<= '0';
				cred_dec_FSM 			<= '0';
				out_sel_FSM 			<= '0';
				reset_prop_FSM			<= '0';
			
			when wait_for_mem_1 =>
				done_FSM 				<= '0';
				mem_en_FSM 				<= '0';
				mem_we_FSM 				<= '0';
				read_input_k_FSM		<= '0';
				dec_k_FSM 				<= '0';
				read_input_mem_addr_FSM	<= '0';
				mem_addr_next_FSM 		<= '0';
				update_valid_val_FSM 	<= '0';
				cred_rst_FSM 			<= '0';
				cred_dec_FSM 			<= '0';
				out_sel_FSM 			<= '0';
				reset_prop_FSM			<= '0';
				
			when read_first_val =>
				done_FSM 				<= '0';
				mem_en_FSM 				<= '0';
				mem_we_FSM 				<= '0';
				read_input_k_FSM		<= '0';
				dec_k_FSM 				<= '0';
				read_input_mem_addr_FSM	<= '0';
				mem_addr_next_FSM 		<= '0';
				update_valid_val_FSM 	<= '1';
				cred_rst_FSM 			<= '0';
				cred_dec_FSM 			<= '0';
				out_sel_FSM 			<= '0';
				reset_prop_FSM			<= '0';				
				
			when set_cred_zero =>
				done_FSM 				<= '0';
				mem_en_FSM 				<= '1';
				mem_we_FSM 				<= '1';
				read_input_k_FSM		<= '0';
				dec_k_FSM 				<= '1';
				read_input_mem_addr_FSM	<= '0';
				mem_addr_next_FSM 		<= '1';
				update_valid_val_FSM 	<= '0';
				cred_rst_FSM 			<= '0';
				cred_dec_FSM 			<= '0';
				out_sel_FSM 			<= '0';
				reset_prop_FSM			<= '0';
				
			when ask_next_val_1 =>
				done_FSM 				<= '0';
				mem_en_FSM 				<= '1';
				mem_we_FSM 				<= '0';
				read_input_k_FSM		<= '0';
				dec_k_FSM 				<= '0';
				read_input_mem_addr_FSM	<= '0';
				mem_addr_next_FSM 		<= '1';
				update_valid_val_FSM 	<= '0';
				cred_rst_FSM 			<= '0';
				cred_dec_FSM 			<= '0';
				out_sel_FSM 			<= '0';
				reset_prop_FSM			<= '0';
				
			when set_cred_31 =>
				done_FSM 				<= '0';
				mem_en_FSM 				<= '1';
				mem_we_FSM 				<= '1';
				read_input_k_FSM		<= '0';
				dec_k_FSM 				<= '1';
				read_input_mem_addr_FSM	<= '0';
				mem_addr_next_FSM 		<= '1';
				update_valid_val_FSM 	<= '0';
				cred_rst_FSM 			<= '1';
				cred_dec_FSM 			<= '0';
				out_sel_FSM 			<= '1';
				reset_prop_FSM			<= '0';
				
			when ask_next_val_2 =>
				done_FSM 				<= '0';
				mem_en_FSM 				<= '1';
				mem_we_FSM 				<= '0';
				read_input_k_FSM		<= '0';
				dec_k_FSM 				<= '0';
				read_input_mem_addr_FSM	<= '0';
				mem_addr_next_FSM 		<= '1';
				update_valid_val_FSM 	<= '0';
				cred_rst_FSM 			<= '0';
				cred_dec_FSM 			<= '1';
				out_sel_FSM 			<= '0';
				reset_prop_FSM			<= '0';
			
			when wait_for_mem_2 =>
				done_FSM 				<= '0';
				mem_en_FSM 				<= '0';
				mem_we_FSM 				<= '0';
				read_input_k_FSM		<= '0';
				dec_k_FSM 				<= '0';
				read_input_mem_addr_FSM	<= '0';
				mem_addr_next_FSM 		<= '0';
				update_valid_val_FSM 	<= '0';
				cred_rst_FSM 			<= '0';
				cred_dec_FSM 			<= '0';
				out_sel_FSM 			<= '0';
				reset_prop_FSM			<= '0';
				
			when evaluate_mem_input =>
				done_FSM 				<= '0';
				mem_en_FSM 				<= '0';
				mem_we_FSM 				<= '0';
				read_input_k_FSM		<= '0';
				dec_k_FSM 				<= '0';
				read_input_mem_addr_FSM	<= '0';
				mem_addr_next_FSM 		<= '0';
				update_valid_val_FSM 	<= '1';
				cred_rst_FSM 			<= '0';
				cred_dec_FSM 			<= '0';
				out_sel_FSM 			<= '0';
				reset_prop_FSM			<= '0';
				
			when replace_invalid_value =>
				done_FSM 				<= '0';
				mem_en_FSM 				<= '1';
				mem_we_FSM 				<= '1';
				read_input_k_FSM		<= '0';
				dec_k_FSM 				<= '0';
				read_input_mem_addr_FSM	<= '0';
				mem_addr_next_FSM 		<= '0';
				update_valid_val_FSM 	<= '0';
				cred_rst_FSM 			<= '0';
				cred_dec_FSM 			<= '0';
				out_sel_FSM 			<= '0';
				reset_prop_FSM			<= '0';
				
			when set_cred_val =>
				done_FSM 				<= '0';
				mem_en_FSM 				<= '1';
				mem_we_FSM 				<= '1';
				read_input_k_FSM		<= '0';
				dec_k_FSM 				<= '1';
				read_input_mem_addr_FSM	<= '0';
				mem_addr_next_FSM 		<= '1';
				update_valid_val_FSM 	<= '0';
				cred_rst_FSM 			<= '0';
				cred_dec_FSM 			<= '0';
				out_sel_FSM 			<= '1';
				reset_prop_FSM			<= '0';

			when seq_complete =>
				done_FSM 				<= '1';
				mem_en_FSM 				<= '0';
				mem_we_FSM 				<= '0';
				read_input_k_FSM		<= '0';
				dec_k_FSM 				<= '0';
				read_input_mem_addr_FSM	<= '0';
				mem_addr_next_FSM 		<= '0';
				update_valid_val_FSM 	<= '0';
				cred_rst_FSM 			<= '0';
				cred_dec_FSM 			<= '0';
				out_sel_FSM 			<= '0';
				reset_prop_FSM			<= '0';
				
			when others =>
				done_FSM 				<= 'X';
				mem_en_FSM 				<= 'X';
				mem_we_FSM 				<= 'X';
				read_input_k_FSM		<= 'X';
				dec_k_FSM 				<= 'X';
				read_input_mem_addr_FSM	<= 'X';
				mem_addr_next_FSM 		<= 'X';
				update_valid_val_FSM 	<= 'X';
				cred_rst_FSM 			<= 'X';
				cred_dec_FSM 			<= 'X';
				out_sel_FSM 			<= 'X';
				reset_prop_FSM			<= 'X';
				
		end case;
	end process;
	
end architecture;