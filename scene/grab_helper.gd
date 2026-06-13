extends Node2D

var _mouseInPosition:bool = false
signal grab_start(node:Node2D)
signal grab_end(node:Node2D)
var _grabStarted = false
var grabPermission = false
var grabIndex = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	var mouse_position = get_viewport().get_mouse_position()
	if(_grabStarted == false and _mouseInPosition and Input.is_action_pressed("click")):
		_grabStarted = true
		grab_start.emit(self)
	
	if(_grabStarted and grabPermission):
		self.position = mouse_position
	
	if(_grabStarted and Input.is_action_just_released("click")):
		_grabStarted = false
		grabPermission = false
		grab_end.emit(self)
