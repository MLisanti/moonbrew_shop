extends Node2D

@export var moneyGoal:float = 100
var moneyGain:float = 0
var _scena_pozione = preload("res://scene/pozione.tscn")
var _scena_cliente = preload("res://scene/cliente.tscn")

var maskGrab = ""

# Called when the node enters the scene tree for the first time.
func _ready():
	update_ui()
	
	var i=0
	var pos = $pos_start_pozioni.position
	while(i<4):
		var elementi = $helperElementi.scegli_elemento_casuale() + $helperElementi.scegli_elemento_casuale()
		crea_pozione(i, elementi, 100.0, pos)
		pos.x += 120
		
		i+=1
	
	i=0
	pos = $pos_start_clienti.position
	while(i<4):
		var elementi = $helperElementi.scegli_elemento_casuale() + $helperElementi.scegli_elemento_casuale()
		crea_cliente(elementi, pos)
		pos.x += 140
		
		i+=1
	
	for cliente:Node2D in $clienti.get_children():
		cliente.connect("finish", _on_client_finish)
	
	i=0
	for pozione:Node2D in $pozioni.get_children():
		pozione.grabIndex = i
		
		maskGrab += "0"
		pozione.connect("grab_start", _on_grab_start)
		pozione.connect("grab_end", _on_grab_end)
		i+=1

func _on_grab_start(nodo:Node2D):
	
	if(not maskGrab.contains("1")):
		maskGrab[nodo.grabIndex] = "1"
		nodo.grabPermission = true

func _on_grab_end(nodo:Node2D):
	maskGrab[nodo.grabIndex] = "0"

func _on_client_finish(curedDiseases:int, totalDiseases:int, potion:Node2D, client:Node2D, effects:String):
	var guadagno = (potion.price / totalDiseases) * curedDiseases
	var descGuadagno = "Ti meriti " + str(guadagno) + " su " + str(potion.price)
	if(curedDiseases == 0):
		descGuadagno = "Non ti meriti niente"
	else:
		descGuadagno = "Ti meriti " + str(guadagno) + " su " + str(potion.price)
	
	$UI/MarginContainer/VBoxContainer/lbl_effects.text = effects + descGuadagno
	
	moneyGain += guadagno
	update_ui()
	
	maskGrab[potion.grabIndex] = "0"
	
	potion.queue_free()
	client.queue_free()

func crea_pozione(indice:int, elementi:String, prezzo:float, posizione:Vector2):
	var nodoPozione:Node2D = _scena_pozione.instantiate()
	nodoPozione.name = "pozione" + str(indice)
	nodoPozione.elements = elementi
	nodoPozione.price = prezzo
	nodoPozione.position = posizione
	$pozioni.add_child(nodoPozione)

func crea_cliente(elementi:String, posizione:Vector2):
	var nodoCliente:Node2D = _scena_cliente.instantiate()
	nodoCliente.disease = elementi
	nodoCliente.position = posizione
	$clienti.add_child(nodoCliente)

func update_ui():
	$UI/MarginContainer/VBoxContainer/lbl_money_goal.text = str(moneyGain) + "  //  " + str(moneyGoal)
