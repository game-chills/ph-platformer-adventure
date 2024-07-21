
self.ph_speed_x = 0;
self.ph_speed_y = 0;

self.ph_control_flow_left = new StateMachineEvflow();
self.ph_control_flow_right = new StateMachineEvflow();
self.ph_control_flow_jump = new StateMachineEvflow();
self.ph_control_flow_down = new StateMachineEvflow();

self.ph_it_skip_soft_block_instance = noone;

self.depth = -1;