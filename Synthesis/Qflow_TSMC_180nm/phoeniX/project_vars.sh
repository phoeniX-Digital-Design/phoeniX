#!/bin/tcsh -f
#------------------------------------------------------------
# project variables for project /home/arvin/Desktop/QFlow_test/phoeniX
#------------------------------------------------------------

# Synthesis command options:
# -------------------------------------------
# set hard_macros =
# set yosys_options =
# set yosys_script =
# set yosys_debug =
# set abc_script =
# set nobuffers =
# set inbuffers =
# set postproc_options =
# set xspice_options = "-io_time=1n -time=100p -idelay=10p -odelay=100p -cload=500f"
# set fill_ratios =
# set nofanout =
# set fanout_options = "-l 100 -c 20"
# set source_file_list =
# set is_system_verilog =

# Placement command options:
# -------------------------------------------
# set initial_density =
# set graywolf_options =
set addspacers_options = "-stripe 2.0 50.0 PG"

# Router command options:
# -------------------------------------------
set route_show = 1
# set route_layers =
# set via_use =
# set via_stacks = "1"
# set qrouter_options =

# STA command options:
# -------------------------------------------

# Minimum period of the clock use "--period value" (value in ps)
set vesta_options = "--long"
# set run_vesta = 1

# Other options:
# -------------------------------------------
# set migrate_options =
# set lef_options =
# set drc_gdsview =
# set drc_options =
# set gds_options =

#------------------------------------------------------------

