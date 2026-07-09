extends Area2D

signal finish(curedDiseases:int, totalDiseases:int, potion:Node2D, client:Node2D, effects:String)

@export var disease:String = "FE"

# Called when the node enters the scene tree for the first time.
func _ready():
	$helperElementi.mostra_elementi(disease, $features/Marker2D, $features)
	var nodoSprite:AnimatedSprite2D = $grafica_cliente
	var casuale = randi_range(0, nodoSprite.sprite_frames.get_animation_names().size()-1)
	nodoSprite.animation = nodoSprite.sprite_frames.get_animation_names()[casuale]
	
	mostraConfermaCura(false)

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
