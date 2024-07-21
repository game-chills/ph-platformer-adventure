enum StateMachineEvflowKind {
	outside,
	in,
	inside,
	out,
}

function StateMachineEvflow() constructor {
    #region __constructor
	{
	    self._kind = StateMachineEvflowKind.outside;
	}
	#endregion
	
	function get_kind() {
		return self._kind;
	}
	
	function get_kind_name() {
		switch (self._kind) {
			case StateMachineEvflowKind.outside:
				return "outside";
			case StateMachineEvflowKind.in:
				return "in";
			case StateMachineEvflowKind.inside:
				return "inside";
			case StateMachineEvflowKind.out:
				return "out";
		}
	}
	
	function input(_has_emit) {
	    switch (self._kind) {
	        case StateMachineEvflowKind.outside: {
	            if (_has_emit) {
	                self._kind = StateMachineEvflowKind.in;
	            } else {
	            	self._kind = StateMachineEvflowKind.outside;
	            }
	            break;
	        }
	        case StateMachineEvflowKind.in: {
	            if (_has_emit) {
	                self._kind = StateMachineEvflowKind.inside;
	            } else {
	                self._kind = StateMachineEvflowKind.out;
	            }
	            break;
	        }
	        case StateMachineEvflowKind.inside: {
	        	if (_has_emit) {
	        		self._kind = StateMachineEvflowKind.inside;
	        	} else {
	                self._kind = StateMachineEvflowKind.out;
	            }
	            break;
	        }
	        case StateMachineEvflowKind.out: {
	        	if (_has_emit) {
	        		self._kind = StateMachineEvflowKind.in;
	        	} else {
	                self._kind = StateMachineEvflowKind.outside;
	            }
	            break;
	        }
	    }
	    return self._kind;
	}
	
	function is_outside() {
        return self._kind == StateMachineEvflowKind.outside;
    }
	
	function is_in() {
	    return self._kind == StateMachineEvflowKind.in;
	}
	
	function is_inside() {
	    return self._kind == StateMachineEvflowKind.inside;
	}
	
	function is_out() {
	    return self._kind == StateMachineEvflowKind.out;
	}
	
	function is_active() {
	    return
	        self._kind == StateMachineEvflowKind.in ||
	        self._kind == StateMachineEvflowKind.inside;
	}
	
	function is_inactive() {
	    return
	        self._kind == StateMachineEvflowKind.out ||
	        self._kind == StateMachineEvflowKind.outside;
	}
	
	function toString() {
		return string("StateMachineEvflow(\"{0}\")", self.get_kind_name());
	}
}
