extends CanvasLayer

var step_intro:int = 1

func _ready():
	$UI_gioco/tmrIntroStep.stop()

@onready var controlMessaggioPrincipale:Control = $UI_gioco/centro
@onready var lblMessaggio:Control = $UI_gioco/centro/vbox/lblMessaggio
@onready var lblAzione:Control = $UI_gioco/centro/vbox/lblAzione
@onready var lblVersion:Control = $UI_gioco/sotto/vbox/lblVersion

func ui_nascondi_centro_messaggi():
	controlMessaggioPrincipale.visible = false
	lblVersion.visible = false
	$UI_gioco/tmrIntroStep.stop()
	
func ui_mostra_fine_livello():
	controlMessaggioPrincipale.visible = true
	lblAzione.text = "Touch to continue..."
	lblMessaggio.text = "You got enough money!"
	
func ui_mostra_inizio_gioco(step_messaggio:int):
	controlMessaggioPrincipale.visible = true
	lblVersion.visible = true
	$UI_gioco/tmrIntroStep.start()
	
	lblMessaggio.text = "Touch to start!"
	lblAzione.text = "Sell the right potions\nand gain the minimum to continue!"
	
	if(step_messaggio == 2):
		lblAzione.text = "Kolore! (programming, graphics)\nSir the Lancelot (testing)"
	
	if(step_messaggio == 3):
		lblAzione.text = "Sound effects:\n- pixabay (freesound_community)"
	

func ui_mostra_game_over_perso():
	controlMessaggioPrincipale.visible = true
	lblAzione.text = "Touch to restart"
	lblMessaggio.text = "You went bankrupt... rawr..."
	
func ui_mostra_game_over_vinto():
	controlMessaggioPrincipale.visible = true
	lblAzione.text = "Touch to restart"
	lblMessaggio.text = "You cured everyone!! :rawr: !!"

func ui_mostra_tutorial_base():
	var lblMoneyGoal:Control = $UI_gioco/sopra/vbox/cont/hbox/lblMoneyGoal
	$UI_gioco/sopra/vbox/lblLevelNumber.text = "Day 0 / 10"
	lblMoneyGoal.set("theme_override_colors/font_color", Color.WHITE)
	lblMoneyGoal.text = "GAIN / GOAL"
	$UI_gioco/sopra/vbox/lblEffects.text = "Effects of potion"

func ui_prepara_tutorial_passo_passo():
	print($UI_tutorial.get_children(true))
	for nodoTutorial:Control in $UI_tutorial.get_children(true):
		nodoTutorial.visible = true
	$UI_tutorial.visible = false

func ui_mostra_tutorial_passo_passo(val:int):	
	for nodoTutorial in $UI_tutorial.get_children():
		nodoTutorial.visible = false
		if(nodoTutorial.name.begins_with("tut_" + str(val))):
			nodoTutorial.visible = true
	
	$UI_tutorial.visible = val > 0
	
func ui_update(moneyGain, moneyGoal):
	var lblMoney:Control = $UI_gioco/sopra/vbox/cont/hbox/lblMoneyGoal
	
	lblMoney.text = str(round(moneyGain)) + " c //  " + str(moneyGoal) + " c"
	if(moneyGain < moneyGoal):
		lblMoney.set("theme_override_colors/font_color", Color.RED)
	else:
		lblMoney.set("theme_override_colors/font_color", Color.WHITE)

func _on_tmr_intro_step_timeout():
	step_intro += 1
	
	if(step_intro >= 4 or  step_intro <= 0):
		step_intro = 1
	ui_mostra_inizio_gioco(step_intro)
