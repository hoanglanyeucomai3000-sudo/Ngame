extends Area2D

# Đường dẫn tới cảnh nhà của Hiếu
@export_file("*.tscn") var target_scene: String = "res://hieuhouse.tscn"

var is_player_nearby: bool = false

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _unhandled_input(event: InputEvent) -> void:
	# Khi nhân vật đứng trước cửa nhà Hiếu và nhấn phím E
	if is_player_nearby and (event.is_action_pressed("ui_interact") or event.is_action_pressed("interact")):
		_enter_hieu_house()

func _on_body_entered(body: Node2D) -> void:
	if body.name == "player" or body is CharacterBody2D:
		is_player_nearby = true

func _on_body_exited(body: Node2D) -> void:
	if body.name == "player" or body is CharacterBody2D:
		is_player_nearby = false

func _enter_hieu_house() -> void:
	if target_scene != "":
		get_tree().change_scene_to_file(target_scene)
