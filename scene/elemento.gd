extends AnimatedSprite2D

@export var tipo:String ="F"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	
func set_type(type:String):
	$".".animation = $helperElementi.get_type_name(type)
	tipo = type
