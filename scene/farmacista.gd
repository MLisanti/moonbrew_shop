extends Area2D

var pozioniCambiate:int = 0
const POZIONI_CREABILI_PER_LIVELLO = 1

func puoCrearePozioni() -> bool:
	return pozioniCambiate < POZIONI_CREABILI_PER_LIVELLO

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	$lblTutorial.hide()
	mostraConfermaCambio(false)

func azzeraCambiPozione():
	pozioniCambiate = 0

func aumentaCambiPozione():
	pozioniCambiate += 1

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func mostraConfermaCambio(val:bool):
	$lblCambiaPozione.visible = val
	$grafica_brew.visible = val
	
	
func mostraTutorial(val:bool):
	$lblTutorial.visible = val

func impostaAnimazione(nome:String):
	$SpriteDragonessa.animation = nome
