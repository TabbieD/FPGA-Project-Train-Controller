# FPGA-Project-Train-Controller
FPGA Tain VHDL Module - Train Control State Machine for Altera DE2 board

This project was initially done in 2018 and is just being migrated to this repo.

VGA output displays train and switch state
The project has train_control state machine (tcontrol.vhd) to control train
Key1 Pushbutton is run/stop 
Key2 Pushbutton is reset 
Sw1..2 is trainA speed
Sw3..4 is trainB speed
SensorX are track sensors for train, train near=1 (inputs for state machine)
SwitchX are track switches, Sw=0 connects to outside track
TrackX select power source A=0 or B=1 for track segment
DirX selects direction: 00-stop  01-counterclockwise  10-clockwise
Note: Screen blinks when trains crash or go through switch in wrong direction ,j
               -----------Sw3--------------
               | T1         \T4        T1 |
               |     -------|-------      |
               |     | T3   |   T3 |      |
               |     |      | S5   |      |
            S1 |   S2|             | S3   | S4
               |     \     T2      /      |
               ------Sw1---------Sw2-------

--                       Track Layout
