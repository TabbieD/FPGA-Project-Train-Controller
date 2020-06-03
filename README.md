# FPGA-Project-Train-Controller
FPGA Tain VHDL Module - Train Control State Machine for Altera DE2 board

This project was initially done in 2018 and is just being migrated to this repo.

* VGA output displays train and switch state.
* The project has train_control state machine (tcontrol.vhd) to control train.
* Key1 Pushbutton is run/stop. 
* Key2 Pushbutton is reset. 
* Sw1..2 is trainA speed.
* Sw3..4 is trainB speed.
* SensorX are track sensors for train, train near=1 (inputs for state machine).
* SwitchX are track switches, Sw=0 connects to outside track.
* TrackX select power source A=0 or B=1 for track segment.
* DirX selects direction: 00-stop  01-counterclockwise  10-clockwise.
* Note: Screen blinks when trains crash or go through switch in wrong direction.
* **xxxxxxxxxxxxSw3xxxxxxxxxxxxx**
* **x T1         xT4        T1 x**
* **x     xxxxxxx!xxxxxxx      x**
* **x     x T3   x   T3 x      x**
* **x     x      x S5   x      x**
***S1 x   S2x             x S3   x S4**
* **x     \     T2      /      x**
* **xxxxxxSw1xxxxxxxxxxSw2xxxxxx**

*                     Track Layout.
