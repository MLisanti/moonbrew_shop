extends AnimatedSprite2D

@export var tipo:String ="F"
	
func set_type(type:String):
	$".".animation = $helperElementi.get_type_name(type)
	tipo = type
