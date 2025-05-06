----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/18/2025 02:50:18 PM
-- Design Name: 
-- Module Name: ALU - Behavioral
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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
library UNISIM;
use UNISIM.VComponents.all;

entity ALU is
    Port ( i_A : in STD_LOGIC_VECTOR (7 downto 0);
           i_B : in STD_LOGIC_VECTOR (7 downto 0);
           i_op : in STD_LOGIC_VECTOR (2 downto 0);
           o_result : out STD_LOGIC_VECTOR (7 downto 0);
           o_flags : out STD_LOGIC_VECTOR (3 downto 0));
end ALU;

architecture Behavioral of ALU is
    signal result : signed(7 downto 0);
    signal zero, negative, overflow, carry : std_logic;
begin
    process(i_A, i_B, i_op)
    begin
         case i_op is
        when "000" => -- Add
            result <= signed(i_A) + signed(i_B);
        when "001" => -- Subtract
            result <= signed(i_A) - signed(i_B);
        when "010" => -- And
            result <= signed(i_A and i_B);
        when "011" => -- Or
            result <= signed(i_A or i_B);
        when others =>
            result <= (others => '0');
    end case;
    
    -- Flags
    if result = 0 then
        zero <= '1';
    else
        zero <= '0';
    end if;
    
    negative <= result(7);
    
    if (i_op = "000" and (i_A(7) = i_B(7) and result(7) /= i_A(7))) or
       (i_op = "001" and (i_A(7) /= i_B(7) and result(7) = i_A(7))) then
        overflow <= '1';
    else
        overflow <= '0';
    end if;
    
    carry <= '0'; -- Not applicable for 2's complement arithmetic
    
    o_flags <= zero & negative & overflow & carry;
    o_result <= std_logic_vector(result);
end process;
end Behavioral;
