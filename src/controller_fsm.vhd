----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/18/2025 02:42:49 PM
-- Design Name: 
-- Module Name: controller_fsm - FSM
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity controller_fsm is
    Port ( i_reset : in STD_LOGIC;
           i_adv : in STD_LOGIC;
           o_cycle : out STD_LOGIC_VECTOR (3 downto 0));
end controller_fsm;

architecture FSM of controller_fsm is
    type state_type is (S0, S1, S2, S3);
    signal state : state_type;
begin
    process(i_reset, i_adv)
    begin
        if i_reset = '1' then
            state <= S0;
        elsif rising_edge(i_adv) then
            case state is
                when S0 => 
                    state <= S1;
                when S1 => 
                    state <= S2;
                when S2 => 
                    state <= S3;
                when S3 => 
                    state <= S0;
            end case;
        end if;
    end process;
    
    -- Output logic
    with state select
        o_cycle <= "0001" when S0,  -- Clear display
                   "0010" when S1,  -- Store 1st operand
                   "0100" when S2,  -- Store 2nd operand
                   "1000" when S3;  -- Display result
end FSM;
