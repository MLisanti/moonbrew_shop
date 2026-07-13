extends Node2D

#https://www.youtube.com/watch?v=YGqq58-CN-A

"""
bugs:
	- ad inizio livello controllare se esiste almeno una combinazione possibile
	
	V)- una pozione può essere posata su più clienti e li cura tutti e due:
		  spostare pozione ed evidenziare cliente che cura.
		NOTA: l'evento di cura parte dalla pozione e non dal cliente
		
	- UI:
		- grafica
		- suoni
		- musica
"""

@export var moneyGoal:float = 100
var moneyGain:float = 0
var _scena_pozione = preload("res://scene/pozione.tscn")
var _scena_cliente = preload("res://scene/cliente.tscn")

var maskGrab = ""


const LIVELLO_INIZIO = 1
var _livello = 0
var _clienti_mancanti_prossimo_livello = 0
const POZIONI_CREABILI_PER_LIVELLO = 1
var pozioni_buttate = 0

enum statiLivello {INIZIO, IN_CORSO, FINITO_LIVELLO, GAME_OVER_PERSO, GAME_OVER_VINTO}
var statoLivello:statiLivello = statiLivello.IN_CORSO

func imposta_variabili_livello(livello:int) -> Dictionary:
	var dict:Dictionary = { "potionElements": 2, "clientElements": 2, "goalPrice": 200.0 }
	match livello:
		
		1: dict = { "potionElements": 1, "potionElementsDetail": "FAFA", "clientElements": 1, "clientElementsDetail": "FLFL", "goalPrice": 100.0 }
		2: dict = { "potionElements": 1, "potionElementsDetail": "LVLV", "clientElements": 1, "clientElementsDetail": "AVAV", "goalPrice": 100.0 }
		3: dict = { "potionElements": 1, "potionElementsDetail": "FAVL", "clientElements": 1, "clientElementsDetail": "FAVL", "goalPrice": 100.0 }
		4: dict = { "potionElements": 1, "clientElements": 1, "goalPrice": 50.0 }
		5: dict = { "potionElements": 1, "clientElements": 1, "goalPrice": 100.0 }
		6: dict = { "potionElements": 2, "clientElements": 1, "goalPrice": 100.0 }
		7: dict = { "potionElements": 2, "clientElements": 2, "goalPrice": 100.0 }
		8: dict = { "potionElements": 2, "clientElements": 3, "goalPrice": 150.0 }
		9: dict = { "potionElements": 3, "clientElements": 3, "goalPrice": 200.0 }
		10: dict= { "potionElements": 3, "clientElements": 3, "goalPrice": 250.0 }
		_: dict = { "potionElements": 3, "clientElements": 3, "goalPrice": 200.0 }
	return dict
	

# Called when the node enters the scene tree for the first time.
func _ready():
	cambia_stato_livello(statiLivello.INIZIO)
	$strega_oggetti/farmacista.mostraConfermaCambio(false)
	$UI/sotto/VBoxContainer/lblVersion.text = "Version: " +  ProjectSettings.get_setting("application/config/version")

func _input(event):
	if not ((event is InputEventMouseButton or event is InputEventScreenTouch) and event.pressed):
		return
	
	#processa eventi solo se sono Mouse o touch
	
	if(statoLivello == statiLivello.INIZIO and event.pressed and $tmrCooldown.time_left <= 0):
		cambia_stato_livello(statiLivello.IN_CORSO)
		_livello = LIVELLO_INIZIO
		imposta_livello(_livello)
	
	if(statoLivello == statiLivello.FINITO_LIVELLO and event.pressed):
		if(moneyGain < moneyGoal):
			cambia_stato_livello(statiLivello.GAME_OVER_PERSO)
		else:
			cambia_stato_livello(statiLivello.IN_CORSO)
			_livello += 1
			imposta_livello(_livello)
	
	if((statoLivello == statiLivello.GAME_OVER_PERSO or statoLivello == statiLivello.GAME_OVER_VINTO) 
			and event.pressed):
		cambia_stato_livello(statiLivello.INIZIO)
		$tmrCooldown.start(1.0)

func ui_mostra_tutorial(val:bool):
	var lblMoneyGoal:Control = $UI/sopra/VBoxContainer/MarginContainer/HBoxContainer/lbl_money_goal
	$UI/sopra/VBoxContainer/lbl_levelNumber.text = "Day 0 / 10"
	lblMoneyGoal.set("theme_override_colors/font_color", Color.WHITE)
	lblMoneyGoal.text = "GAIN / GOAL"
	$UI/sopra/VBoxContainer/lbl_effects.text = "Effects of potion"
	$strega_oggetti/farmacista.mostraTutorial(val)

func imposta_livello(livello):
	var levelVar: Dictionary = imposta_variabili_livello(livello)
	var nElementi = levelVar["potionElements"]
	var nMalattie = levelVar["clientElements"]
	moneyGain = 0
	moneyGoal = levelVar["goalPrice"]
	pozioni_buttate = 0
	
	ui_update()
	$UI/sopra/VBoxContainer/lbl_effects.text = ""
	$UI/sopra/VBoxContainer/lbl_levelNumber.text = "Day "+ str(livello) + " / 10"
	
	maskGrab = ""
	
	var i=0
	var pos = $pos_start_pozioni.position
	
	while(i<4):
		var elementi = ""
		
		if(levelVar.has("potionElementsDetail")):
			elementi = levelVar["potionElementsDetail"][i]
		else:
			for j in range(nElementi):
				elementi += $helperElementi.scegli_elemento_casuale()
		
		var importanza = randi_range(1, 3)
		crea_pozione(i, importanza, elementi, importanza * 50, pos)
		pos.x += 120
		
		maskGrab += "0"
		
		i+=1
		
	
	i=0
	pos = $pos_start_clienti.position
	_clienti_mancanti_prossimo_livello = 4
	while(i<4):
		var elementi = ""
		
		if(levelVar.has("clientElementsDetail")):
			elementi = levelVar["clientElementsDetail"][i]
		else:
			for j in range(nMalattie):
				elementi += $helperElementi.scegli_elemento_casuale()
		crea_cliente(elementi, pos)
		pos.x += 140
		
		i+=1

func _on_grab_start(nodo:Node2D):
	if(not maskGrab.contains("1") ):
		maskGrab[nodo.grabIndex] = "1"
		nodo.set_grab_permission(true)
		$suoni/glass_clink.play()
		
func _on_grab_end(nodo:Node2D):
	maskGrab[nodo.grabIndex] = "0"
	nodo.set_grab_permission(false)

func _on_crea_nuova_pozione(pozioneDaButtare:Node2D):
	
	if(pozioni_buttate < POZIONI_CREABILI_PER_LIVELLO):
		print("Ora creo una nuova pozione!!")
		
		var pos = $pos_start_pozioni.position
	
		var elementi = ""
		for j in range(pozioneDaButtare.elements.length()):
			elementi += $helperElementi.scegli_elemento_casuale()
		
		var importanza = randi_range(1, 3)
		crea_pozione(pozioneDaButtare.grabIndex, importanza, elementi, importanza * 50, pozioneDaButtare.position)
		pos.x += 120
		
		pozioneDaButtare.queue_free()
		pozioni_buttate += 1
		
		$suoni/give_client_ok.play()
	else:
		print("Non puoi ...")
		$suoni/give_client_ko.play()
	

func _on_client_finish(curedDiseases:int, totalDiseases:int, potion:Node2D, client:Node2D, effects:String):
	var guadagno = (potion.price / totalDiseases) * curedDiseases
	var descGuadagno = "You deserve nothing..."
	if(curedDiseases > 0):
		descGuadagno = "You gain " + str(round(guadagno)) + " over " + str(potion.price)
		$suoni/give_client_ok.play()
	else:
		$suoni/give_client_ko.play()
	
	$UI/sopra/VBoxContainer/lbl_effects.text = effects + descGuadagno
	
	
	moneyGain += guadagno
	ui_update()
	
	maskGrab[potion.grabIndex] = "0"
	
	potion.queue_free()
	client.queue_free()
	
	_clienti_mancanti_prossimo_livello -= 1
	
	if(_clienti_mancanti_prossimo_livello == 0):
		if(moneyGain < moneyGoal):
			cambia_stato_livello(statiLivello.GAME_OVER_PERSO)
			$suoni/day_lost.play()
		else:
			if(_livello < 10):
				cambia_stato_livello(statiLivello.FINITO_LIVELLO)
			else:
				cambia_stato_livello(statiLivello.GAME_OVER_VINTO)
			$suoni/day_win.play()
		

@onready var controlCentroMessaggi:Control = $UI/centro

func ui_mostra_fine_livello():
	controlCentroMessaggi.visible = true
	$UI/centro/VBoxContainer/lblAzione.text = "Touch to continue..."
	$UI/centro/VBoxContainer/lblMessaggio.text = "You got enough money!"

func ui_mostra_inizio():
	controlCentroMessaggi.visible = true
	$UI/centro/VBoxContainer/lblMessaggio.text = "Touch to start!"
	$UI/centro/VBoxContainer/lblAzione.text = "Sell the right potions\nand gain the minimum to continue!"

func ui_mostra_game_over_perso():
	controlCentroMessaggi.visible = true
	$UI/centro/VBoxContainer/lblAzione.text = "Touch to restart"
	$UI/centro/VBoxContainer/lblMessaggio.text = "You went bankrupt... rawr..."
	
func ui_mostra_game_over_vinto():
	controlCentroMessaggi.visible = true
	$UI/centro/VBoxContainer/lblAzione.text = "Touch to restart"
	$UI/centro/VBoxContainer/lblMessaggio.text = "You cured everyone!! :rawr: !!"

func cambia_stato_livello (nuovoStato:statiLivello):
	var precedente = statoLivello
	statoLivello = nuovoStato
	
	if(nuovoStato == statiLivello.IN_CORSO):
		ui_mostra_tutorial(false)
		controlCentroMessaggi.visible = false
		$strega_oggetti/farmacista.impostaAnimazione("in_corso")
	
	if(nuovoStato == statiLivello.INIZIO):
		ui_mostra_inizio()
		ui_mostra_tutorial(true)
		$strega_oggetti/farmacista.impostaAnimazione("in_corso")
	
	if(precedente == statiLivello.IN_CORSO and nuovoStato == statiLivello.FINITO_LIVELLO):
		ui_mostra_fine_livello()
		$strega_oggetti/farmacista.impostaAnimazione("finito_livello")
	
	if(precedente == statiLivello.IN_CORSO and nuovoStato == statiLivello.GAME_OVER_VINTO):
		ui_mostra_game_over_vinto()
		$strega_oggetti/farmacista.impostaAnimazione("game_over_vinto")
		
	if(precedente == statiLivello.IN_CORSO and nuovoStato == statiLivello.GAME_OVER_PERSO):
		ui_mostra_game_over_perso()
		$strega_oggetti/farmacista.impostaAnimazione("game_over_perso")

func crea_pozione(indice:int, importanza:int, elementi:String, prezzo:float, posizione:Vector2):
	var nodoPozione:Node2D = _scena_pozione.instantiate()
	nodoPozione.name = "pozione" + str(indice)
	nodoPozione.elements = elementi
	nodoPozione.price = prezzo
	nodoPozione.position = posizione
	nodoPozione.imposta_scala(importanza)
	$pozioni.add_child(nodoPozione)
	
	nodoPozione.grabIndex = indice
	nodoPozione.connect("grab_start", _on_grab_start)
	nodoPozione.connect("grab_end", _on_grab_end)
	nodoPozione.connect("crea_nuova_pozione", _on_crea_nuova_pozione)
	
	

func crea_cliente(elementi:String, posizione:Vector2):
	var nodoCliente:Node2D = _scena_cliente.instantiate()
	nodoCliente.add_to_group("clienti")
	nodoCliente.disease = elementi
	nodoCliente.position = posizione
	$clienti.add_child(nodoCliente)
	
	nodoCliente.connect("finish", _on_client_finish)

func ui_gameOver():
	pass
	
func ui_roundWon():
	pass
	
func ui_update():
	var lblMoney:Control = $UI/sopra/VBoxContainer/MarginContainer/HBoxContainer/lbl_money_goal
	
	lblMoney.text = str(round(moneyGain)) + " c //  " + str(moneyGoal) + " c"
	if(moneyGain < moneyGoal):
		lblMoney.set("theme_override_colors/font_color", Color.RED)
	else:
		lblMoney.set("theme_override_colors/font_color", Color.WHITE)


func _on_area_2d_input_event(viewport, event: InputEvent, shape_idx):
	$Area2D/lblStatoInput.text = event.as_text()
