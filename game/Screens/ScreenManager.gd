extends Spatial

onready var MainMenuScene := preload("res://Screens/MainMenu.tscn")
onready var GameScene := preload("res://Screens/Game.tscn")
onready var GameOverScene := preload("res://Screens/GameOver.tscn")
onready var animation_player := $AnimationPlayer

var current_scene = null
var next_scene = null

func _ready() -> void:
	EventBus.connect("main_menu_done", self, "_change_scene", [GameScene])
	EventBus.connect("player_entered_exit_portal", self, "_change_scene", [GameOverScene])
	
	_change_scene(MainMenuScene)

func _change_scene(NextScene) -> void:
	if next_scene:
		return
		
	next_scene = NextScene.instance()
	if current_scene:
		animation_player.play("fade_out")
		yield(animation_player, "animation_finished")
		current_scene.queue_free()
	add_child(next_scene)
	if current_scene:
		animation_player.play("fade_in")
	else:
		animation_player.play("fade_in", -1, 0.5)
	yield(animation_player, "animation_finished")
	current_scene = next_scene
	next_scene = null
