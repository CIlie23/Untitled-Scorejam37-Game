extends Node

var redScore: int = 0
var blueScore: int = 0
var playerUserName: String

#var path = OS.get_environment("HOME") + "/Desktop/screenshot.png"
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("Screenshot"):
		var img = get_viewport().get_texture().get_image()
		var desktop_path = OS.get_environment("HOME") + "/Desktop/screenshot.png"
		img.save_png(desktop_path)
