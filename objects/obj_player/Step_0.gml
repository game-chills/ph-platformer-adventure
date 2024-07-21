
//
var _key_press_left = keyboard_check(ord("A"));
var _key_press_right = keyboard_check(ord("D"));
var _key_press_jump = keyboard_check(vk_space);
var _key_press_down = keyboard_check(ord("S"));

//
self.ph_control_flow_left.input(_key_press_left);
self.ph_control_flow_right.input(_key_press_right);
self.ph_control_flow_jump.input(_key_press_jump);
self.ph_control_flow_down.input(_key_press_down);

#region

//
var _check_collision_block_soft = function(_x, _y) {
    var _dy = _y - self.y;
    var _bbox_bottom = self.bbox_bottom;
    
    var _list = ds_list_create();
    var _count = instance_place_list(_x, _y, obj_block_soft, _list, false);
    
    if (_count == 0) {
        ds_list_destroy(_list);
        return noone;
    }
    
    var _validate = [];
    var _instance;
    var _instance_bbox_top;
    for (var i = 0; i < ds_list_size(_list); ++i) {
        _instance = ds_list_find_value(_list, i);
        _instance_bbox_top = _instance.bbox_top + _dy;
        
        if (
            self.ph_it_skip_soft_block_instance && 
            _instance.id == self.ph_it_skip_soft_block_instance.id
        ) {
            continue;
        }
        
        if (_instance_bbox_top <= _bbox_bottom) {
            continue;
        }
        
        array_push(_validate, _instance);
    }
    
    ds_list_destroy(_list);
    
    if (array_length(_validate)) {
        return _validate[0];
    }
    
    return noone;
}

//
var _yborder = 2;
var _const_cf_on_floor = 0.2;
var _const_cf_on_air = 0.008;
var _const_max_speed = 5;

//
var _input_move_is_jump = self.ph_control_flow_jump.is_in();
var _input_move_is_down = self.ph_control_flow_down.is_active();
var _input_move_side_x =
    self.ph_control_flow_right.is_active() -
    self.ph_control_flow_left.is_active();

var _it_has_collision_floor_block = 
    place_meeting(self.x, self.y + _yborder, obj_block);
var _it_has_collision_floor_block_soft = 
    _check_collision_block_soft(self.x, self.y + _yborder);

var _it_has_collision_floor =
    sign(self.ph_speed_y) != -1 &&
   (_it_has_collision_floor_block || _it_has_collision_floor_block_soft)

if (_it_has_collision_floor) {
    if (_input_move_is_jump) {
        self.ph_speed_y = -20;
        
        // **
        _it_has_collision_floor = noone;
    }
}

if (_it_has_collision_floor) {
    var _is_available =
        !_it_has_collision_floor_block &&
        !self.ph_it_skip_soft_block_instance &&
        _it_has_collision_floor_block_soft;
    
    if (_input_move_is_down && _is_available) {
        self.ph_it_skip_soft_block_instance = _it_has_collision_floor_block_soft;
    
        // **
        _it_has_collision_floor = noone;
    }
}

if (_it_has_collision_floor) {
    self.ph_speed_y = 0;
    self.ph_it_skip_soft_block_instance = noone;
} else {
    self.ph_speed_y = 
        min(self.ph_speed_y + 0.2 + abs(self.ph_speed_y) * 0.07, 23);
}

if (_it_has_collision_floor) {
    if (_input_move_side_x != 0) {
        self.ph_speed_x = lerp(
            self.ph_speed_x, 
            _const_max_speed * _input_move_side_x,
            _const_cf_on_floor,
        );
    } else {
        self.ph_speed_x = lerp(self.ph_speed_x, 0, _const_cf_on_floor);
    }
} else {
   if (_input_move_side_x != 0) {
        self.ph_speed_x = lerp(
            self.ph_speed_x, 
            _const_max_speed * _input_move_side_x,
            _const_cf_on_air,
        );
    } 
}

var _it_handler_start = function(_prev_iter) {
    var _it_speed_vec_size = 
        point_distance(0, 0, self.ph_speed_x, self.ph_speed_y)
    var _it_speed_vec_direction = 
        point_direction(0, 0, self.ph_speed_x, self.ph_speed_y)

    var _it_speed_1x =
        lengthdir_x(1, _it_speed_vec_direction)
    var _it_speed_1y =
        lengthdir_y(1, _it_speed_vec_direction)
    
    var _lost_iters = 
        _prev_iter.it_count / _prev_iter.it_count_max;
    
    var _it_count = _it_speed_vec_size * _lost_iters;
    var _it_count_max = _it_speed_vec_size;
    
    var _next_iter = {
        it_count: _it_count,
        it_count_max: _it_count_max,
        it_speed_vec_size: _it_speed_vec_size,
        it_speed_vec_direction: _it_speed_vec_direction,
        it_speed_1x: _it_speed_1x,
        it_speed_1y: _it_speed_1y,
    }
    
    return _next_iter;
}

var _start_iter = {
    it_count: 1,
    it_count_max: 1,
    it_speed_vec_size: undefined,
    it_speed_vec_direction: undefined,
    it_speed_1x: undefined,
    it_speed_1y: undefined,
}
var _iter = _it_handler_start(_start_iter);

var _has_collision_to_move_block;
var _has_collision_to_move_block_soft;
var _has_collision_to_move;
var _has_collision_to_x;
var _has_collision_to_y;

while (_iter.it_count--) {
    _has_collision_to_move_block =
        place_meeting(
            self.x + _iter.it_speed_1x, 
            self.y + _iter.it_speed_1y, 
            obj_block
        );
    
    _has_collision_to_move_block_soft =
        sign(self.ph_speed_y) == 1 && 
        !_input_move_is_down &&
        _check_collision_block_soft(
            self.x + _iter.it_speed_1x, 
            self.y + _iter.it_speed_1y, 
        );
    
    _has_collision_to_move = 
        _has_collision_to_move_block || _has_collision_to_move_block_soft
    
    if (!_has_collision_to_move) {
        self.x += _iter.it_speed_1x;
        self.y += _iter.it_speed_1y;
        
        continue;
    }
    
    _has_collision_to_x =
        place_meeting(
            self.x + _iter.it_speed_1x, 
            self.y, 
            obj_block
        );
    
    _has_collision_to_y =
        place_meeting(
            self.x, 
            self.y + _iter.it_speed_1y, 
            obj_block
        );
    
    if (_has_collision_to_y && sign(_iter.it_speed_1y) == 1) {
        self.ph_speed_y = 0;
        self.ph_it_skip_soft_block_instance = noone;
        
        self.y += _iter.it_speed_1y;
        
        var _cool;
        for (var i = 0; i < 20; ++i) {
            _cool =
                place_meeting(
                    self.x, 
                    self.y, 
                    obj_block
                );
            
            if (!_cool) {
                break;
            }
            
            self.y -= 0.2;
        }

        break;
    }
    
    if (_has_collision_to_y) {
        self.ph_speed_y *= -0.2;
        self.ph_speed_x *= 0.8;
        
        _iter = _it_handler_start(_iter);
        continue;
    }
    
    if (_has_collision_to_x) {
        self.ph_speed_x *= -0.4;
        
        _iter = _it_handler_start(_iter);
        continue;
    }
    
    _has_collision_to_y =
        sign(_iter.it_speed_1y) == 1 &&
        !_input_move_is_down &&
        _check_collision_block_soft(
            self.x, 
            self.y + _iter.it_speed_1y,
        );
    
    if (_has_collision_to_y) {
        self.ph_speed_y = 0;
        self.ph_it_skip_soft_block_instance = noone;
        
        self.y += _iter.it_speed_1y;
        
        var _cool;
        for (var i = 0; i < 20; ++i) {
            _cool =
                place_meeting(
                    self.x, 
                    self.y, 
                    obj_block_soft
                );
            
            if (!_cool) {
                break;
            }
            
            self.y -= 0.2;
        }

        break;
    }
    
    self.ph_speed_y *= -0.2;
    self.ph_speed_x *= 0.8;
        
    _iter = _it_handler_start(_iter);
}

#endregion

if (keyboard_check_pressed(ord("R"))) {
    room_restart();
}



