extends Area2D

var _elements_scene = preload("res://scene/elemento.tscn")

var _mouseInPosition:bool = false
signal grab_start(node:Node2D)
signal grab_end(node:Node2D)
var _grabStarted = false
var grabPermission = false
var grabIndex = 0

@export var price:float = 100.0
@export var elements:String = "FA"

# Called when the node enters the scene tree for the first time.
func _ready():
	show_features(elements)
	$lblPrice.text = str(price) + " c"
	
	var nodoSprite:AnimatedSprite2D = $grafica_pozione
	var casuale = randi_range(0, nodoSprite.sprite_frames.get_animation_names().size()-1)
	nodoSprite.animation = nodoSprite.sprite_frames.get_animation_names()[casuale]

func imposta_scala(grandezza:int):
	match grandezza:
		1:	$grafica_pozione.scale = Vector2(0.36, 0.36)
		2:	$grafica_pozione.scale = Vector2(0.64, 0.64)
		3:	$grafica_pozione.scale = Vector2(0.83, 0.83)
		_:	$grafica_pozione.scale = Vector2(0.64, 0.64)

func show_features(element_list:String):
	var i=0
	var riga = 0
	var colonna = 0
	while(i < element_list.length()):
		var nodo_elemento:Node2D = _elements_scene.instantiate()
		var c = element_list.substr(i,1)
		
		nodo_elemento.set_type(c)
		nodo_elemento.position = $features/Marker2D.position
		nodo_elemento.position.x = $features/Marker2D.position.x + (colonna*50)
		nodo_elemento.position.y = $features/Marker2D.position.y - (riga*50)
		
		$features.add_child(nodo_elemento)
		i += 1
		
		colonna += 1
		
		if(i>0 and i % 2 == 0): 
			riga += 1
			colonna = 0

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
		
		

func _on_mouse_entered():
	_mouseInPosition = true

func _on_mouse_exited():
	_mouseInPosition = false


func _on_input_event(viewport, event, shape_idx):
	if(event is InputEventScreenTouch):
		print("Touch: ", event.is_pressed())
