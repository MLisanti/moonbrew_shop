extends Node

#NOTA: non esiste più elettro
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
