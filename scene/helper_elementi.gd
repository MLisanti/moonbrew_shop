extends Node

var _scena_elemento = load("res://scene/elemento.tscn")

func _ready():
	pass

func scegli_elemento_casuale():
	var cas = randi_range(0, 3)
	match cas:
		0: return "F"
		1: return "A"
		2: return "V"
		3: return "L"
		_: return ""

func is_stronger(elem1, elem2):
	#V -> A -> F -> L -> V
	return ((elem1 == "V" and elem2 == "A") or 
			(elem1 == "A" and elem2 == "F") or 
			(elem1 == "F" and elem2 == "L") or 
			(elem1 == "L" and elem2 == "V"))

func get_type_name(type:String):
	match type:
		"F":
			return "fuoco"
		"A":
			return "acqua"
		"V":
			return "vento"
		"L":
			return "legno"
		_:
			return ""

func get_type_name_for_UI(type:String):
	match type:
		"F":
			return "fire"
		"A":
			return "water"
		"V":
			return "wind"
		"L":
			return "wood"
		_:
			return ""

func mostra_elementi(element_list:String, marker:Marker2D, nodoElementi:Node2D):
	var i=0
	var riga = 0
	var colonna = 0
	while(i < element_list.length()):
		#_scena_elemento = load("res://scene/elemento.tscn")
		var nodo_elemento:Node2D = _scena_elemento.instantiate()
		var c = element_list.substr(i,1)
		
		nodo_elemento.set_type(c)
		nodo_elemento.position = marker.position
		nodo_elemento.position.x = marker.position.x + (colonna*50)
		nodo_elemento.position.y = marker.position.y - (riga*50)
		
		nodoElementi.add_child(nodo_elemento)
		i += 1
		
		colonna += 1
		
		if(i>0 and i % 2 == 0): 
			riga += 1
			colonna = 0
