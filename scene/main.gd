extends Node2D

@export var moneyGoal:float = 100
var moneyGain:float = 0
var _scena_pozione = preload("res://scene/pozione.tscn")
var _scena_cliente = preload("res://scene/cliente.tscn")

var maskGrab = ""
"""
bugs:
	- ad inizio livello controllare se esiste almeno una combinazione possibile
	- una pozione può essere posata su più clienti e li cura tutti e due
"""

var _livello = 1
const LIVELLO_INIZIO = 1
var _clienti_mancanti_prossimo_livello = 0

enum statiLivello {INIZIO, IN_CORSO, FINITO, GAME_OVER}
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

func rand_price():
	return randi_range(1, 3) * 50
	

# Called when the node enters the scene tree for the first time.
func _ready():
	cambia_stato_livello(statiLivello.INIZIO)

func _process(_delta):
	if(statoLivello == statiLivello.INIZIO and Input.is_action_just_released("conferma") and $tmrCooldown.time_left <= 0):
		cambia_stato_livello(statiLivello.IN_CORSO)
		_livello = LIVELLO_INIZIO
		imposta_livello(_livello)
	
	if(statoLivello == statiLivello.FINITO and Input.is_action_just_released("conferma")):
		if(moneyGain < moneyGoal):
			cambia_stato_livello(statiLivello.GAME_OVER)
		else:
			cambia_stato_livello(statiLivello.IN_CORSO)
			_livello += 1
			imposta_livello(_livello)
	
	if(statoLivello == statiLivello.GAME_OVER and Input.is_action_just_released("conferma")):
		cambia_stato_livello(statiLivello.INIZIO)
		$tmrCooldown.start(1.0)
	
func imposta_livello(livello):
	var levelVar: Dictionary = imposta_variabili_livello(livello)
	var nElementi = levelVar["potionElements"]
	var nMalattie = levelVar["clientElements"]
	moneyGain = 0
	moneyGoal = levelVar["goalPrice"]
	
	ui_update()
	
	var i=0
	var pos = $pos_start_pozioni.position
	
	while(i<4):
		var elementi = ""
		
		if(levelVar.has("potionElementsDetail")):
			elementi = levelVar["potionElementsDetail"][i]
		else:
			for j in range(nElementi):
				elementi += $helperElementi.scegli_elemento_casuale()
			
		crea_pozione(i, elementi, rand_price(), pos)
		pos.x += 120
		
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

func controlla_passaggio_livello(mancanti):
	return mancanti == 0

func _on_grab_start(nodo:Node2D):
	if(not maskGrab.contains("1")):
		maskGrab[nodo.grabIndex] = "1"
		nodo.grabPermission = true

func _on_grab_end(nodo:Node2D):
	maskGrab[nodo.grabIndex] = "0"

func _on_client_finish(curedDiseases:int, totalDiseases:int, potion:Node2D, client:Node2D, effects:String):
	var guadagno = (potion.price / totalDiseases) * curedDiseases
	var descGuadagno = "Non ti meriti niente"
	if(curedDiseases > 0):
		descGuadagno = "Ti meriti " + str(guadagno) + " su " + str(potion.price)
	
	$UI/sopra/VBoxContainer/lbl_effects.text = effects + descGuadagno
	
	moneyGain += guadagno
	ui_update()
	
	maskGrab[potion.grabIndex] = "0"
	
	potion.queue_free()
	client.queue_free()
	
	_clienti_mancanti_prossimo_livello -= 1
	
	if(_clienti_mancanti_prossimo_livello == 0):
		cambia_stato_livello(statiLivello.FINITO)
		

@onready var controlCentroMessaggi:Control = $UI/centro

func mostra_fine_livello():
	controlCentroMessaggi.visible = true
	
	$UI/centro/VBoxContainer/lblAzione.text = "Spazio per continuare"
	if(moneyGain < moneyGoal):
		$UI/centro/VBoxContainer/lblMessaggio.text = "Non sei riuscita a guadagnare il minimo..."
	else:
		$UI/centro/VBoxContainer/lblMessaggio.text = "Hai guadagnato abbastanza!"

func ui_mostra_inizio():
	controlCentroMessaggi.visible = true
	$UI/centro/VBoxContainer/lblAzione.text = "Vendi le pozioni e guadagna il minimo indispensabile"
	$UI/centro/VBoxContainer/lblMessaggio.text = "Premi spazio per iniziare"

func ui_mostra_game_over():
	controlCentroMessaggi.visible = true
	$UI/centro/VBoxContainer/lblAzione.text = "Spazio per continuare"
	$UI/centro/VBoxContainer/lblMessaggio.text = "Sei andata in bancarotta"

func cambia_stato_livello (nuovoStato:statiLivello):
	var precedente = statoLivello
	statoLivello = nuovoStato
	
	if(nuovoStato == statiLivello.IN_CORSO):
		controlCentroMessaggi.visible = false
	
	if(nuovoStato == statiLivello.INIZIO):
		ui_mostra_inizio()
	
	if(precedente == statiLivello.IN_CORSO and nuovoStato == statiLivello.FINITO):
		mostra_fine_livello()
		
	if(precedente == statiLivello.FINITO and nuovoStato == statiLivello.GAME_OVER):
		ui_mostra_game_over()

func crea_pozione(indice:int, elementi:String, prezzo:float, posizione:Vector2):
	var nodoPozione:Node2D = _scena_pozione.instantiate()
	nodoPozione.name = "pozione" + str(indice)
	nodoPozione.elements = elementi
	nodoPozione.price = prezzo
	nodoPozione.position = posizione
	$pozioni.add_child(nodoPozione)
	
	var i=0
	for pozione:Node2D in $pozioni.get_children():
		pozione.grabIndex = i
		
		maskGrab += "0"
		pozione.connect("grab_start", _on_grab_start)
		pozione.connect("grab_end", _on_grab_end)
		i+=1

func crea_cliente(elementi:String, posizione:Vector2):
	var nodoCliente:Node2D = _scena_cliente.instantiate()
	nodoCliente.disease = elementi
	nodoCliente.position = posizione
	$clienti.add_child(nodoCliente)
	
	for cliente:Node2D in $clienti.get_children():
		cliente.connect("finish", _on_client_finish)

func ui_gameOver():
	pass
	
func ui_roundWon():
	pass
	
func ui_update():
	var lblMoney:Control = $UI/sopra/VBoxContainer/lbl_money_goal
	
	lblMoney.text = str(round(moneyGain)) + " c //  " + str(moneyGoal) + " c"
	if(moneyGain < moneyGoal):
		lblMoney.set("theme_override_colors/font_color", Color.RED)
	else:
		lblMoney.set("theme_override_colors/font_color", Color.WHITE)
