
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


entity top is
generic(
c_clkfreq		:integer :=100_000_000;
c_pwmfreq		:integer :=10_000
);
port(
clk			:in std_logic;
pwm_led_i	:in std_logic_vector(5 downto 0);
pwm_led_o	:out std_logic_vector(5 downto 0)
);
end top;

architecture Behavioral of top is

-----Component tanımlama:
component pwm is
generic(
c_clkfreq		:integer :=100_000_000;
c_pwmfreq		:integer :=1000
);
port(
clk				:in std_logic;
duty_cycle_i	:in std_logic_vector(6 downto 0);
pwm_o			:out std_logic
);
end component;


---constant:
constant c_timerlim		:integer :=100;
constant c_timer50hzlim	:integer := c_clkfreq/50;

-------------------------------signal
signal led1_duty_cycle		:std_logic_vector(6 downto 0) := (others =>'0');
signal led2_duty_cycle		:std_logic_vector(6 downto 0) := (others =>'0');
signal pwm_o_1				:std_logic:='0';
signal pwm_o_2				:std_logic:='0';
signal timer				:integer range 0 to c_timerlim;
signal timer50hz			:integer range 0 to c_timer50hzlim;


begin
-----------------comp ins:
pwmled1: pwm
generic map(
c_clkfreq		=> c_clkfreq,
c_pwmfreq		=> c_pwmfreq
)
port map(
clk				=> clk,					
duty_cycle_i	=> led1_duty_cycle,				
pwm_o			=> pwm_o_1					
);

pwmled2: pwm
generic map(
c_clkfreq		=> c_clkfreq,
c_pwmfreq		=> c_pwmfreq
)
port map(
clk				=> clk,					
duty_cycle_i	=> led2_duty_cycle,				
pwm_o			=> pwm_o_2					
);

led2_duty_cycle <= CONV_STD_LOGIC_VECTOR((50-CONV_INTEGER(led1_duty_cycle)),7);


-------------------
P_MAIN: process(clk) begin
if(rising_edge(clk)) then
	
	if(timer < c_timerlim/2) then
		
		if(timer50hz = c_timer50hzlim-1) then
			led1_duty_cycle <= led1_duty_cycle +1;
			timer50hz <= 0;
			timer <= timer+1;
		else 
			timer50hz <= timer50hz+1;
		end if;
	
	else
		
		if(timer50hz = c_timer50hzlim-1)then
			if(timer = c_timerlim-1) then
				timer <=0;
			else 
				timer <= timer +1;
				led1_duty_cycle <= led1_duty_cycle -1;
			end if;
			
			timer50hz <=0;
		else
			timer50hz <= timer50hz +1;
		end if;
	
	end if;

end if;
end process;

P_OUT : process(clk) begin
if(rising_edge(clk)) then
	
	pwm_led_o(5) <= pwm_led_i(5) and pwm_o_1;
	pwm_led_o(4) <= pwm_led_i(4) and pwm_o_1;
	pwm_led_o(3) <= pwm_led_i(3) and pwm_o_1;
	
	pwm_led_o(2) <= pwm_led_i(2) and pwm_o_2;
	pwm_led_o(1) <= pwm_led_i(1) and pwm_o_2;
	pwm_led_o(0) <= pwm_led_i(0) and pwm_o_2;

end if;
end process;

end Behavioral;
