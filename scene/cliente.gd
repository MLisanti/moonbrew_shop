extends Area2D

signal finish(curedDiseases:int, totalDiseases:int, potion:Node2D, client:Node2D, effects:String)

@export var disease:String = "FE"
var _elements_scene = preload("res://scene/elemento.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	show_features(disease)
	var nodoSprite:AnimatedSprite2D = $grafica_cliente
	var casuale = randi_range(0, nodoSprite.sprite_frames.get_animation_names().size()-1)
	nodoSprite.animation = nodoSprite.sprite_frames.get_animation_names()[casuale]
	
	
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

func creaMask (stringa:String) -> String:
	var i = 0
	var res = ""
	while(i<stringa.length()):
		res += "0"
		i += 1
	return res

func curaCliente(objPozione:Area2D):
	var potion:Node2D = null
	var i:int=0
	var j:int=0
	
	var effects=""
	
	var maskPozioniUsate = "0"
	var maskMalattieCurate = "0"
	
	if(objPozione.name.to_lower().begins_with("pozione")):
		
		potion = objPozione
		
		var pElements:String = potion.elements
		maskPozioniUsate = creaMask(pElements)
		maskMalattieCurate = creaMask(disease)
		
		print("Elementi pozione: " + pElements)
		print("Malattie: " + disease)
		
		while(i < disease.length()):
			var dis = disease.substr(i,1)
			var cure = ""
			j = 0
			
			while(j<pElements.length()):
				
				cure = pElements.substr(j,1)
				if(maskPozioniUsate[j] == "0" and $helperElementi.is_stronger(cure, dis)):
					effects += ($helperElementi.get_type_name_for_UI(cure) + " cures " + $helperElementi.get_type_name_for_UI(dis) + "...\n")
					
					maskMalattieCurate[i] = "1"
					maskPozioniUsate[j] = "1"
					
					#salta a prossima malattia
					break
				
				j+=1
			i+=1
		
		finish.emit(maskMalattieCurate.count("1"), disease.length(), potion, self, effects)

func mostraConfermaCura(val:bool):
	if(val):
		$lblAzione.text = "Give!"
	else:
		$lblAzione.text = ""
