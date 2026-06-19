extends Node

func scegli_elemento_casuale():
	var cas = randi_range(0, 3)
	match cas:
		0: return "F"
		1: return "A"
		2: return "V"
		3: return "E"
		_: return ""

func is_stronger(elem1, elem2):
	#V -> A -> F -> E
	return ((elem1 == "F" and elem2 == "E") or 
			(elem1 == "A" and elem2 == "F") or 
			(elem1 == "V" and elem2 == "A") or 
			(elem1 == "E" and elem2 == "V"))

func get_type_name(type:String):
	match type:
		"F":
			return "fuoco"
		"A":
			return "acqua"
		"V":
			return "vento"
		"E":
			return "elettro"
		_:
			return ""
