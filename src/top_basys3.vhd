--+----------------------------------------------------------------------------
--|
--| NAMING CONVENSIONS :
--|
--|    xb_<port name>           = off-chip bidirectional port ( _pads file )
--|    xi_<port name>           = off-chip input port         ( _pads file )
--|    xo_<port name>           = off-chip output port        ( _pads file )
--|    b_<port name>            = on-chip bidirectional port
--|    i_<port name>            = on-chip input port
--|    o_<port name>            = on-chip output port
--|    c_<signal name>          = combinatorial signal
--|    f_<signal name>          = synchronous signal
--|    ff_<signal name>         = pipeline stage (ff_, fff_, etc.)
--|    <signal name>_n          = active low signal
--|    w_<signal name>          = top level wiring signal
--|    g_<generic name>         = generic
--|    k_<constant name>        = constant
--|    v_<variable name>        = variable
--|    sm_<state machine type>  = state machine type definition
--|    s_<signal name>          = state name
--|
--+----------------------------------------------------------------------------
library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;


entity top_basys3 is
    port(
        -- inputs
        clk     :   in std_logic; -- native 100MHz FPGA clock
        sw      :   in std_logic_vector(7 downto 0); -- operands and opcode
        btnU    :   in std_logic; -- reset
        btnC    :   in std_logic; -- fsm cycle
        
        -- outputs
        led :   out std_logic_vector(15 downto 0);
        -- 7-segment display segments (active-low cathodes)
        seg :   out std_logic_vector(6 downto 0);
        -- 7-segment display active-low enables (anodes)
        an  :   out std_logic_vector(3 downto 0)
    );
end top_basys3;

architecture top_basys3_arch of top_basys3 is 
    -- declare components
    component ALU is
        Port ( i_A : in STD_LOGIC_VECTOR (7 downto 0);
               i_B : in STD_LOGIC_VECTOR (7 downto 0);
               i_op : in STD_LOGIC_VECTOR (2 downto 0);
               o_result : out STD_LOGIC_VECTOR (7 downto 0);
               o_flags : out STD_LOGIC_VECTOR (3 downto 0));
    end component;
    
    component controller_fsm is
        Port ( i_reset : in STD_LOGIC;
               i_adv : in STD_LOGIC;
               o_cycle : out STD_LOGIC_VECTOR (3 downto 0));
    end component;
    
    -- declare signals
    signal cycle : std_logic_vector(3 downto 0);
    signal result : std_logic_vector(7 downto 0);
    signal flags : std_logic_vector(3 downto 0);
    signal operand1, operand2 : std_logic_vector(7 downto 0);
    signal opcode : std_logic_vector(2 downto 0);
    signal reset : std_logic;
    signal display_value : std_logic_vector(7 downto 0);
    signal display_anode : std_logic_vector(3 downto 0);
    
    -- 7-segment display encoding
    function to_segment(value : std_logic_vector(3 downto 0)) return std_logic_vector is
    begin
        case value is
            when "0000" => return "1000000"; -- 0
            when "0001" => return "1111001"; -- 1
            when "0010" => return "0100100"; -- 2
            when "0011" => return "0110000"; -- 3
            when "0100" => return "0011001"; -- 4
            when "0101" => return "0010010"; -- 5
            when "0110" => return "0000010"; -- 6
            when "0111" => return "1111000"; -- 7
            when "1000" => return "0000000"; -- 8
            when "1001" => return "0010000"; -- 9
            when others => return "1111111"; -- blank
        end case;
    end function;
    
begin
    -- PORT MAPS ----------------------------------------
    fsm: controller_fsm port map(
        i_reset => btnU,
        i_adv => btnC,
        o_cycle => cycle
    );
    
    alu_inst: ALU port map(
        i_A => operand1,
        i_B => operand2,
        i_op => opcode,
        o_result => result,
        o_flags => flags
    );
    
    -- CONCURRENT STATEMENTS ----------------------------
    opcode <= sw(2 downto 0);
    operand1 <= sw when cycle = "0010" else (others => '0');
    operand2 <= sw when cycle = "0100" else (others => '0');
    display_value <= operand1 when cycle = "0010" else
                     operand2 when cycle = "0100" else
                     result when cycle = "1000" else
                     (others => '0');
    
    -- 7-segment display logic
process(clk)
    variable count : integer range 0 to 50000000 := 0;
    variable digit : integer range 0 to 1 := 0;
begin
    if rising_edge(clk) then
        count := count + 1;
        if count = 50000000 then
            count := 0;
            digit := digit + 1;
            if digit > 1 then
                digit := 0;
            end if;
        end if;
        
        case digit is
            when 0 =>
                an <= "1110";
                if display_value(7) = '1' then
                    seg <= "0111111"; -- minus sign
                else
                    seg <= to_segment(display_value(7 downto 4));
                end if;
            when 1 =>
                an <= "1101";
                seg <= to_segment(display_value(3 downto 0));
        end case;
    end if;
end process;
    
    an <= display_anode;
    
    -- LED outputs
    led(3 downto 0) <= cycle;
    led(15 downto 12) <= flags;
end top_basys3_arch;
