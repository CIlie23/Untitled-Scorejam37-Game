extends Control


@onready var your_score: Label = $YourScore
@onready var lblPlayer_name: Label = $Control/PlayerName
@onready var submit_score: Button = $Control/HBoxContainer/SubmitScore
@onready var successs: Label = $Successs

@onready var userInput: LineEdit = $user

var final_score :int #this might create a bug
var player_name: String
# Called when the node enters the scene tree for the first time.

func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	player_name = userInput.text.strip_edges()
	Global.playerUserName = player_name
	final_score = Global.redScore
	your_score.text = "You scored " + str(Global.redScore) + " points!"


func _on_submit_score_pressed() -> void:
	Leaderboard.send_user_value(player_name, final_score)
	successs.visible = true
	await get_tree().create_timer(3).timeout
	Global.blueScore = 0
	Global.redScore = 0
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")
	#print("Score submitted!")


func _on_play_again_pressed() -> void:
	Global.blueScore = 0
	Global.redScore = 0
	get_tree().change_scene_to_file("res://Scenes/world.tscn")


func _on_user_text_changed(new_text: String) -> void:
	submit_score.disabled = false
