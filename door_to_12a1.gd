extends Area2D

# Đường dẫn tới file cảnh lớp 12a1 (Anh nhớ kiểm tra lại đúng tên file .tscn trong máy nhé)
@export_file("*.tscn") var target_scene: String = "res://12a_1.tscn"

func _ready() -> void:
	# Tự động kết nối tín hiệu khi có vật thể bước vào vùng Area2D
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	# Kiểm tra nếu đúng là người chơi (player) đi vào
	if body.name == "player" or body.is_in_group("player") or body is CharacterBody2D:
		if target_scene != "":
			get_tree().change_scene_to_file(target_scene)
