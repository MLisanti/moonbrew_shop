extends Area2D

var _elements_scene = preload("res://scene/elemento.tscn")


signal grab_start(node:Node2D)
signal grab_end(node:Node2D)

var _dragging = false
const _radius_drag:int = 50
var grabPermission = false
var grabIndex = 0


var rand=RandomNumberGenerator.new()

var audio1 = preload("res://suoni/glass_clink_1.mp3")

var _numClientiPresi = 0
var _clienteDaCurare:Area2D = null


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
	pass

func audio_glass_clink():
	var i = rand.randi_range(1, 3)
	$audio_clink.stream = audio1
	$audio_clink.play()

func _on_input_event(_viewport, event:InputEvent, _shape_idx):
	
	#touch
	if(event is InputEventScreenTouch):
		if((event.position - self.global_position).length() < _radius_drag):
			if(not _dragging and event.pressed):
				_dragging = true
				grab_start.emit(self)
			if(_dragging and not event.pressed):
				_dragging = false
				grab_end.emit(self)
	
	#mouse
	if(event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT):
		if((self.global_position - event.position).length() < _radius_drag):
			if(not _dragging and event.pressed):
				_dragging = true
				grab_start.emit(self)
			if(_dragging and not event.pressed):
				_dragging = false
				grab_end.emit(self)
				
	#drag
	if(_dragging):
		self.global_position = event.position
	
	#cura il cliente solo se ne hai selezionato uno e non di piu
	if(_dragging == false and _numClientiPresi == 1 and _clienteDaCurare != null):
		_clienteDaCurare.curaCliente(self)
		print("effettua cura...")
		_numClientiPresi = 0
		_clienteDaCurare = null
		
#TODO: non si capisce bene il cliente che verrà curato ....

func _on_area_entered(area):
	if(area.is_in_group("clienti")):
		var cliente:Area2D = area
		cliente.mostraConfermaCura(true)
		_numClientiPresi += 1
		
		#il cliente da curare è sempre l'ultimo selezionato
		_clienteDaCurare = cliente


func _on_area_exited(area):
	if(area.is_in_group("clienti")):
		var cliente:Area2D = area
		cliente.mostraConfermaCura(false)
		_numClientiPresi -= 1
		
		if(_numClientiPresi == 0):
			_clienteDaCurare = null
