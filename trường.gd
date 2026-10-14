
extends Sprite2D

var player_nearby: bool = false

func _ready() -> void:
	$Area2D.body_entered.connect(_on_body_entered)
	$Area2D.body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node2D) -> void:
	if body.name == "player":
		player_nearby = true
		print("Đã vào vùng cửa trường")

func _on_body_exited(body: Node2D) -> void:
	if body.name == "player":
		player_nearby = false
		print("Đã rời vùng cửa trường")

func _process(_delta: float) -> void:
	if player_nearby and Input.is_action_just_pressed("interact"):
		print("Đã nhấn E")
		get_tree().change_scene_to_file("res://truong_ben_trong.tscn")
