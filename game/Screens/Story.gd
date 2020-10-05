extends Node2D

onready var animation_player := $AnimationPlayer
onready var text := $Text

var intro_done := false

func _ready() -> void:
	wait_for_anim_done()

func _input(event: InputEvent) -> void:
	if event.is_pressed():
		if intro_done:
			EventBus.emit_signal("story_done")
		else:
			animation_player.stop()
			text.visible_characters = -1
			intro_done = true

func wait_for_anim_done() -> void:
	yield(animation_player, "animation_finished")
	intro_done = true
