---------------------------------------------------------------------------------
--                        Moon Patrol - Tang Nano 20K
--                              Code from MIST
--
--                        Modified for Tang Nano 20K 
--                            by pinballwiz.org 
--                               10/12/2025
---------------------------------------------------------------------------------
-- Keyboard inputs :
--   5 : Add coin
--   2 : Start 2 players
--   1 : Start 1 player
--   LEFT Ctrl   : Fire
--   UP arrow    : Jump
--   RIGHT arrow : Move Right
--   LEFT arrow  : Move Left
---------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.ALL;
use ieee.numeric_std.all;
---------------------------------------------------------------------------------
entity mpatrol_tn20k is
port(
	Clock_48    : in std_logic;
   	I_RESET     : in std_logic;
	O_VIDEO_R	: out std_logic_vector(2 downto 0); 
	O_VIDEO_G	: out std_logic_vector(2 downto 0);
	O_VIDEO_B	: out std_logic_vector(1 downto 0);
	O_HSYNC		: out std_logic;
	O_VSYNC		: out std_logic;
	O_AUDIO_L 	: out std_logic;
	O_AUDIO_R 	: out std_logic;
   	ps2_clk     : in std_logic;
	ps2_dat     : inout std_logic;
 	led         : out std_logic_vector(5 downto 0)
 );
end mpatrol_tn20k;
------------------------------------------------------------------------------
architecture struct of mpatrol_tn20k is

 signal clock_36        : std_logic;
 signal clock_24        : std_logic;
 signal clock_18        : std_logic;
 signal clock_12        : std_logic;
 signal clock_9         : std_logic;
 signal clock_7p5       : std_logic;
 signal clock_6         : std_logic;
 signal clock_3p58      : std_logic;
 --
 signal reset           : std_logic;
 signal pll_lock        : std_logic;
 --
 signal kbd_intr        : std_logic;
 signal kbd_scancode    : std_logic_vector(7 downto 0);
 signal joy_BBBBFRLDU   : std_logic_vector(8 downto 0);
 --
 constant CLOCK_FREQ    : integer := 27E6;
 signal counter_clk     : std_logic_vector(25 downto 0);
 signal clock_4hz       : std_logic;
 signal AD              : std_logic_vector(15 downto 0);
---------------------------------------------------------------------------
begin

 reset <= I_RESET;

---------------------------------------------------------------------------
Clock1: entity work.Gowin_rPLL1
    port map (
        clkout  => Clock_36,
        clkoutd => Clock_6,
        clkin   => Clock_48,
        lock    => pll_lock
    );
--
Clock2: entity work.Gowin_rPLL2
    port map (
        clkout => Clock_7p5,
        clkin => Clock_48
    );
---------------------------------------------------------------------------
--Divide
process (clock_48)
begin
 if rising_edge(clock_48) then
  clock_24  <= not clock_24;
 end if;
end process;
--
process (clock_36)
begin
 if rising_edge(clock_36) then
  clock_18  <= not clock_18;
 end if;
end process;
--
process (clock_24)
begin
 if rising_edge(clock_24) then
  clock_12  <= not clock_12;
 end if;
end process;
--
process (clock_18)
begin
 if rising_edge(clock_18) then
  clock_9  <= not clock_9;
 end if;
end process;
--
process (clock_7p5)
begin
 if rising_edge(clock_7p5) then
  clock_3p58  <= not clock_3p58;
 end if;
end process;
---------------------------------------------------------------------------
-- Main

mpatrol : entity work.mpatrol_top
  port map (
 clk_sys    => clock_36,
 clk_vid    => clock_6,
 clock_24   => clock_24,
 clk_aud    => clock_3p58,
 clock_12   => clock_12,
 reset      => reset,
 O_VIDEO_R  => O_VIDEO_R,
 O_VIDEO_G  => O_VIDEO_G,
 O_VIDEO_B  => O_VIDEO_B,
 O_HSYNC    => O_HSYNC,
 O_VSYNC    => O_VSYNC,
 audio_l    => O_AUDIO_L,
 audio_r    => O_AUDIO_R,
 IN0        => "1111" & not joy_BBBBFRLDU(7) & '1' & not joy_BBBBFRLDU(6) & not joy_BBBBFRLDU(5),
 IN1        => not joy_BBBBFRLDU(4) & '1' & not joy_BBBBFRLDU(0) & "111" & not joy_BBBBFRLDU(2) & not joy_BBBBFRLDU(3),
 IN2        => not joy_BBBBFRLDU(4) & '1' & not joy_BBBBFRLDU(0) & "111" & not joy_BBBBFRLDU(2) & not joy_BBBBFRLDU(3),
 AD         => AD
   );

--	.IN0							({4'b1111, ~m_coin1, ~service, ~m_two_players, ~m_one_player}),
--	.IN1							({~m_fireA, 1'b1, ~m_fireB, 3'b111, ~m_left, ~m_right}),
--	.IN2							({~m_fire2A, 1'b1, ~m_fire2B, 3'b111, ~m_left2, ~m_right2}),
------------------------------------------------------------------------------
-- get scancode from keyboard

keyboard : entity work.io_ps2_keyboard
port map (
  clk       => clock_9,
  kbd_clk   => ps2_clk,
  kbd_dat   => ps2_dat,
  interrupt => kbd_intr,
  scancode  => kbd_scancode
);
------------------------------------------------------------------------------
-- translate scancode to joystick

joystick : entity work.kbd_joystick
port map (
  clk           => clock_9,
  kbdint        => kbd_intr,
  kbdscancode   => std_logic_vector(kbd_scancode), 
  joy_BBBBFRLDU => joy_BBBBFRLDU 
);
------------------------------------------------------------------------------
-- debug

process(reset, clock_24)
begin
  if reset = '1' then
    clock_4hz <= '0';
    counter_clk <= (others => '0');
  else
    if rising_edge(clock_24) then
      if counter_clk = CLOCK_FREQ/8 then
        counter_clk <= (others => '0');
        clock_4hz <= not clock_4hz;
        led(5 downto 0) <= not AD(9 downto 4);
      else
        counter_clk <= counter_clk + 1;
      end if;
    end if;
  end if;
end process;
------------------------------------------------------------------------
end struct;