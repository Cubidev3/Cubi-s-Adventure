class_name PlayerState
extends State

var player: Player = null

func _ready():
	yield(owner, "ready")
	player = owner as Player
	assert(player != null)