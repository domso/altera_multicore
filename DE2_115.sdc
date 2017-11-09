# Created by Jörg Mische

create_clock -period 20 [get_ports CLOCK_50]
create_clock -period 20 [get_ports CLOCK2_50]
create_clock -period 20 [get_ports CLOCK3_50]

derive_pll_clocks

derive_clock_uncertainty

#set_input_delay -clock CLOCK_50 -max 3 [all_inputs]
#set_input_delay -clock CLOCK_50 -min 2 [all_inputs]
