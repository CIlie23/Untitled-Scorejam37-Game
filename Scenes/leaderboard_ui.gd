extends Control

@onready var entries_container: VBoxContainer= $Panel/VBoxContainer/ScrollContainer/Enteries
@onready var refresh_button: Button = $Panel/VBoxContainer/Refresh

@export var entry_scene: PackedScene

func _ready():
	Leaderboard.on_received_entries.connect(_on_entries_received)
	
	Leaderboard.on_sent_user_value.connect(func(success):
		if success:
			refresh()
	)
	refresh()

func refresh():
	clear_entries()
	Leaderboard.request_entries(1, 10) # top 10 scores

func clear_entries():
	for c in entries_container.get_children():
		c.queue_free()

func _on_entries_received(entries: Array):
	for entry in entries:
		var row = entry_scene.instantiate()
		entries_container.add_child(row)

		row.get_node("Container/Name").text = entry.name
		row.get_node("Container/Score").text = str(entry.value)


func _on_refresh_pressed() -> void:
	refresh()
