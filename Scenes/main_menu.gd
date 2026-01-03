extends Node3D

@onready var animation_player: AnimationPlayer = $CameraAnim
@onready var main_menu: Control = $CanvasLayer/MainMenu
@onready var credits: Control = $CanvasLayer/Credits
@onready var hover_sound_player: AudioStreamPlayer2D = $HoverSoundPlayer
@onready var click_sound_player: AudioStreamPlayer2D = $ClickSoundPlayer
@onready var fade: AnimationPlayer = $Fade
@onready var options: Control = $CanvasLayer/Options

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	animation_player.play("pan")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_play_pressed() -> void:
	click_sound_player.play()
	fade.play("FadeIn")

# OPTIONS
func _on_tutorial_pressed() -> void:
	main_menu.visible = false
	options.visible = true

func _on_credits_pressed() -> void:
	click_sound_player.play()
	main_menu.visible = false
	credits.visible = true

func _on_close_pressed() -> void:
	click_sound_player.play()
	main_menu.visible = true
	credits.visible = false
	options.visible = false

# --------------------------------------------------
func _on_play_mouse_entered() -> void:
	hover_sound_player.play()

# OPTIONS
func _on_tutorial_mouse_entered() -> void:
	hover_sound_player.play()

func _on_credits_mouse_entered() -> void:
	hover_sound_player.play()
# --------------------------------------------------
func changeScene():
	get_tree().change_scene_to_file("res://Scenes/world.tscn")
