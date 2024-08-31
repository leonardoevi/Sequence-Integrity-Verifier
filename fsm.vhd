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
	
--	signal curr_state_debug : std_logic_vector(3 downto 0);

--  trnsition counter
--	signal transitions : std_logic_vector (31 downto 0);

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
	
	-- debug
--	with curr_state_FSM select
--		curr_state_debug <= "0000" when reset,
--							"0001" when read_input_data,
--							"0010" when wait_for_mem_1,
--							"0011" when read_first_val,
--							"0100" when set_cred_zero,
--							"0101" when ask_next_val_1,
--							"0110" when set_cred_31,
--							"0111" when ask_next_val_2,
--							"1000" when wait_for_mem_2,
--							"1001" when evaluate_mem_input,
--							"1010" when replace_invalid_value,
--							"1011" when set_cred_val,
--							"1100" when	seq_complete,
--							"XXXX" when others;

--	trnsition counter

--    trans_count : process(rst_FSM, clk_FSM, next_state_FSM)
--    begin
--        if rst_FSM = '1' then
--            transitions <= (others => '0');
--        elsif rising_edge(clk_FSM) and next_state_FSM /= curr_state_FSM  then
--            transitions <= std_logic_vector(unsigned(transitions) + 1);
--       end if;
--    end process;

end architecture;