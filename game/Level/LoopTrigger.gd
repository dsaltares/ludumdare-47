extends Area

signal player_entered
signal ghost_entered

func _ready() -> void:
	connect("body_entered", self, "on_body_entered")
	
func on_body_entered(node : Node) -> void:
	if node.is_in_group("player"):
		emit_signal("player_entered")
	
	if node.is_in_group("ghosts"):
		emit_signal("ghost_entered", node)
