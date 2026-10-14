extends Area2D

# Đường dẫn quay trở lại bản đồ chính
@export_file("*.tscn") var target_scene: String = "res://main.tscn"

var is_player_nearby: bool = false

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _unhandled_input(event: InputEvent) -> void:
	# Khi player đứng ở cửa và bấm phím E (interact)
	if is_player_nearby and (event.is_action_pressed("ui_interact") or event.is_action_pressed("interact")):
		_change_map()

func _on_body_entered(body: Node2D) -> void:
	if body.name == "player" or body is CharacterBody2D:
		is_player_nearby = true

func _on_body_exited(body: Node2D) -> void:
	if body.name == "player" or body is CharacterBody2D:
		is_player_nearby = false

func _change_map() -> void:
	if target_scene != "":
		get_tree().change_scene_to_file(target_scene)
