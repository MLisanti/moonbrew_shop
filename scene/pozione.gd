extends Area2D

signal grab_start(node:Node2D)
signal grab_end(node:Node2D)
signal crea_nuova_pozione(pozione:Node2D)

var _dragging = false
const _radius_drag:int = 100
const _radius_drag_dragging:int = 200
var _grabPermission = false
var grabIndex = 0


var rand=RandomNumberGenerator.new()
var farmacista:Node2D = null
var audio1 = preload("res://suoni/glass_clink_1.mp3")

var _numClientiPresi = 0
var _clienteDaCurare:Area2D = null
var cambiaPozione = false


@export var price:float = 100.0
@export var elements:String = "FA"

# Called when the node enters the scene tree for the first time.
func _ready():
	$helperElementi.mostra_elementi(elements, $features/Marker2D, $features)
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

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if(_dragging):
		self.global_position = get_global_mouse_position()

func audio_glass_clink():
	$audio_clink.stream = audio1
	$audio_clink.play()

func set_grab_permission(value:bool):
	_grabPermission = value

func _on_input_event(_viewport, event:InputEvent, _shape_idx):
	#touch
	if(event is InputEventScreenTouch):
		if((event.position - self.global_position).length() < _radius_drag):
			grab_start.emit(self)
			if(_grabPermission):
				if(not _dragging and event.pressed):
					_dragging = true
					
				if(_dragging and not event.pressed):
					_dragging = false
					grab_end.emit(self)
	
	#mouse
	
	if(event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT):
		if((self.global_position - event.position).length() < _radius_drag):
			grab_start.emit(self)
			if(_grabPermission):
				if(not _dragging and event.pressed):
					_dragging = true
					
				if(_dragging and not event.pressed):
					_dragging = false
					grab_end.emit(self)
	
	#drag
	if(_dragging):
		# se non viene più intercettato l'evento di movimento non viene posizionato l'oggetto
		#self.global_position = event.position
		pass
	
	#cura il cliente solo se ne hai selezionato uno e non di piu
	if(_dragging == false and _numClientiPresi == 1 and _clienteDaCurare != null):
		_clienteDaCurare.curaCliente(self)
		_numClientiPresi = 0
		_clienteDaCurare = null
	
	if(_dragging == false and cambiaPozione and farmacista != null):
		crea_nuova_pozione.emit(self)
		farmacista.aumentaCambiPozione()
		
func _on_area_entered(area):
	if(area.is_in_group("clienti")):
		var cliente:Area2D = area
		cliente.mostraConfermaCura(true)
		_numClientiPresi += 1
		
		#il cliente da curare è sempre l'ultimo selezionato
		_clienteDaCurare = cliente
		cambiaPozione = false
	
	print(area.name)
	if(area.name=="farmacista"):
		farmacista = area
		cambiaPozione = false
		if(not farmacista.puoCrearePozioni()):
			return
			
		farmacista.mostraConfermaCambio(true)
		
		_clienteDaCurare = null
		cambiaPozione = true


func _on_area_exited(area):
	if(area.is_in_group("clienti")):
		var cliente:Area2D = area
		cliente.mostraConfermaCura(false)
		_numClientiPresi -= 1
		
		if(_numClientiPresi == 0):
			_clienteDaCurare = null
	
	if(area.name=="farmacista"):
		var farma = area
		farma.mostraConfermaCambio(false)
		cambiaPozione = false
