extends Area2D

signal finish(curedDiseases:int, totalDiseases:int, potion:Node2D, client:Node2D, effects:String)

@export var disease:String = "FE"
var _elements_scene = preload("res://scene/elemento.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	show_features(disease)
	

func show_features(element_list:String):
	var i=0
	while(i<element_list.length()):
		var nodo_elemento:Node2D = _elements_scene.instantiate()
		var c = element_list.substr(i,1)
		
		nodo_elemento.set_type(c)
		nodo_elemento.position = $features/Marker2D.position
		nodo_elemento.position.x = $features/Marker2D.position.x + (i*50)
		
		$features.add_child(nodo_elemento)
		i += 1

func creaMask (stringa:String) -> String:
	var i = 0
	var res = ""
	while(i<stringa.length()):
		res += "0"
		i += 1
	return res

func _on_area_entered(area:Area2D):
	
	var potion:Node2D = null
	var i:int=0
	var j:int=0
	
	var howManyCured:int=0
	
	var effects=""
	
	var maskPozioniUsate = "0"
	var maskMalattieCurate = "0"
	
	if(area.name.to_lower().begins_with("pozione")):
		
		potion = area
		
		var pElements:String = potion.elements
		maskPozioniUsate = creaMask(pElements)
		maskMalattieCurate = creaMask(disease)
		
		print("Elementi pozione: " + pElements)
		print("Malattie: " + disease)
		
		while(i < disease.length()):
			var m = disease.substr(i,1)
			var c = ""
			j = 0
			
			while(j<pElements.length()):
				
				c = pElements.substr(j,1)
				if(maskPozioniUsate[j] == "0" and $helperElementi.is_stronger(c, m)):
					effects += ("Curo " + $helperElementi.get_type_name(m) + " con " + $helperElementi.get_type_name(c) + "...\n")
					
					maskMalattieCurate[i] = "1"
					maskPozioniUsate[j] = "1"
					
					howManyCured += 1
					
					#salta a prossima malattia
					break
				
				j+=1
			i+=1
			
		finish.emit(howManyCured, disease.length(), potion, self, effects)
