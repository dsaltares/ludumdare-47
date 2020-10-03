extends Spatial

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	print(translation)

func _on_Area_body_entered(body):
	$AnimationPlayer.play("Activation")

func _on_Area_body_exited(body):
	$AnimationPlayer.play_backwards("Activation")
