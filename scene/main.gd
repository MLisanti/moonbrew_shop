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
	ui_mostra_tutorial_passo_passo(0)
	$farma_oggetti/farmacista.mostraConfermaCambio(false)
	$UI/UI_gioco/sotto/vbox/lblVersion.text = "Version: " +  ProjectSettings.get_setting("application/config/version")

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

func imposta_livello(livello):
	var levelVar: Dictionary = imposta_variabili_livello(livello)
	var nElementi = levelVar["potionElements"]
	var nMalattie = levelVar["clientElements"]
	moneyGain = 0
	moneyGoal = levelVar["goalPrice"]
	$farma_oggetti/farmacista.azzeraCambiPozione()
	
	ui_update()
	
	$UI/UI_gioco/sopra/vbox/lblEffects.text = ""
	$UI/UI_gioco/sopra/vbox/lblLevelNumber.text = "Day "+ str(livello) + " / 10"
	
	if(_livello == 1):
		abilita_tutorial = true
		passo_tutorial = 1
		ui_mostra_tutorial_passo_passo(passo_tutorial)
	elif(_livello == 2):
		abilita_tutorial = true
		passo_tutorial = 6
		ui_mostra_tutorial_passo_passo(passo_tutorial)
	else:
		abilita_tutorial = false
	
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
	
	print("Ora creo una nuova pozione!!")
	
	var pos = $pos_start_pozioni.position

	var elementi = ""
	for j in range(pozioneDaButtare.elements.length()):
		elementi += $helperElementi.scegli_elemento_casuale()
	
	var importanza = randi_range(1, 3)
	crea_pozione(pozioneDaButtare.grabIndex, importanza, elementi, importanza * 50, pozioneDaButtare.position)
	pos.x += 120
	
	pozioneDaButtare.queue_free()
	$suoni/potion_brew.play()
	

func _on_client_finish(curedDiseases:int, totalDiseases:int, potion:Node2D, client:Node2D, effects:String):
	var guadagno = (potion.price / totalDiseases) * curedDiseases
	var descGuadagno = "You deserve nothing..."
	if(curedDiseases > 0):
		descGuadagno = "You gain " + str(round(guadagno)) + " over " + str(potion.price)
		$suoni/give_client_ok.play()
	else:
		$suoni/give_client_ko.play()
	
	$UI/UI_gioco/sopra/vbox/lblEffects.text = effects + descGuadagno
	
	
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
		

@onready var controlCentroMessaggi:Control = $UI/UI_gioco/centro

func ui_mostra_fine_livello():
	controlCentroMessaggi.visible = true
	$UI/UI_gioco/centro/vbox/lblAzione.text = "Touch to continue..."
	$UI/UI_gioco/centro/vbox/lblMessaggio.text = "You got enough money!"
	

func ui_mostra_inizio():
	controlCentroMessaggi.visible = true
	$UI/UI_gioco/centro/vbox/lblMessaggio.text = "Touch to start!"
	$UI/UI_gioco/centro/vbox/lblAzione.text = "Sell the right potions\nand gain the minimum to continue!"

func ui_mostra_game_over_perso():
	controlCentroMessaggi.visible = true
	$UI/UI_gioco/centro/vbox/lblAzione.text = "Touch to restart"
	$UI/UI_gioco/centro/vbox/lblMessaggio.text = "You went bankrupt... rawr..."
	
func ui_mostra_game_over_vinto():
	controlCentroMessaggi.visible = true
	$UI/UI_gioco/centro/vbox/lblAzione.text = "Touch to restart"
	$UI/UI_gioco/centro/vbox/lblMessaggio.text = "You cured everyone!! :rawr: !!"

func ui_mostra_tutorial_base(val:bool):
	var lblMoneyGoal:Control = $UI/UI_gioco/sopra/vbox/cont/hbox/lblMoneyGoal
	$UI/UI_gioco/sopra/vbox/lblLevelNumber.text = "Day 0 / 10"
	lblMoneyGoal.set("theme_override_colors/font_color", Color.WHITE)
	lblMoneyGoal.text = "GAIN / GOAL"
	$UI/UI_gioco/sopra/vbox/lblEffects.text = "Effects of potion"
	$farma_oggetti/farmacista.mostraTutorial(val)

func ui_mostra_tutorial_passo_passo(val:int):
	$UI/UI_tutorial/tut_1_prendiPozioni.visible = val == 1
	$UI/UI_tutorial/tut_2_fuoco_legno.visible = val == 2
	$UI/UI_tutorial/tut_3_acqua_fuoco.visible = val == 3
	$UI/UI_tutorial/tut_4_brew.visible = val == 4
	$UI/UI_tutorial/tut_5_completa_giorno1.visible = val == 5
	$UI/UI_tutorial/tut_6_giorno2_legno_acqua.visible = val == 6
	$UI/UI_tutorial/tut_7_giorno2_completa.visible = val == 7
	
	$UI/UI_tutorial.visible = val > 0

func cambia_stato_livello (nuovoStato:statiLivello):
	var precedente = statoLivello
	statoLivello = nuovoStato
	
	if(nuovoStato == statiLivello.IN_CORSO):
		ui_mostra_tutorial_base(false)
		controlCentroMessaggi.visible = false
		$farma_oggetti/farmacista.impostaAnimazione("in_corso")
	
	if(nuovoStato == statiLivello.INIZIO):
		ui_mostra_inizio()
		ui_mostra_tutorial_base(true)
		$farma_oggetti/farmacista.impostaAnimazione("in_corso")
	
	if(nuovoStato == statiLivello.FINITO_LIVELLO and precedente == statiLivello.IN_CORSO):
		ui_mostra_fine_livello()
		$farma_oggetti/farmacista.impostaAnimazione("finito_livello")
		
		if(abilita_tutorial and _livello == 1):
			passo_tutorial = 0
			abilita_tutorial = false
			ui_mostra_tutorial_passo_passo(passo_tutorial)
	
	if(nuovoStato == statiLivello.GAME_OVER_VINTO and precedente == statiLivello.IN_CORSO ):
		ui_mostra_game_over_vinto()
		$farma_oggetti/farmacista.impostaAnimazione("game_over_vinto")
		
	if(nuovoStato == statiLivello.GAME_OVER_PERSO and precedente == statiLivello.IN_CORSO):
		ui_mostra_game_over_perso()
		$farma_oggetti/farmacista.impostaAnimazione("game_over_perso")
	
	if(nuovoStato == statiLivello.GAME_OVER_VINTO or nuovoStato == statiLivello.GAME_OVER_PERSO):
		abilita_tutorial = false
		passo_tutorial = 0
		ui_mostra_tutorial_passo_passo(passo_tutorial)

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
	nodoPozione.connect("crea_nuova_pozione", _on_crea_pozione_tutorial)
	
	

func crea_cliente(elementi:String, posizione:Vector2):
	var nodoCliente:Node2D = _scena_cliente.instantiate()
	nodoCliente.add_to_group("clienti")
	nodoCliente.disease = elementi
	nodoCliente.position = posizione
	$clienti.add_child(nodoCliente)
	
	nodoCliente.connect("finish", _on_client_finish)
	nodoCliente.connect("finish", _on_client_tutorial)

var passo_tutorial = 0
var abilita_tutorial = false
func _on_client_tutorial(_curedDiseases:int, _totalDiseases:int, _potion:Node2D, _client:Node2D, _effects:String):
	if(not abilita_tutorial):
		return
	passo_tutorial += 1		
	ui_mostra_tutorial_passo_passo(passo_tutorial)

func _on_crea_pozione_tutorial(_pozione:Node2D):
	if(not abilita_tutorial):
		return
		
	if(passo_tutorial != 4):
		return
		
	passo_tutorial += 1
	ui_mostra_tutorial_passo_passo(passo_tutorial)

func ui_gameOver():
	pass
	
func ui_roundWon():
	pass
	
func ui_update():
	var lblMoney:Control = $UI/UI_gioco/sopra/vbox/cont/hbox/lblMoneyGoal
	
	lblMoney.text = str(round(moneyGain)) + " c //  " + str(moneyGoal) + " c"
	if(moneyGain < moneyGoal):
		lblMoney.set("theme_override_colors/font_color", Color.RED)
	else:
		lblMoney.set("theme_override_colors/font_color", Color.WHITE)
