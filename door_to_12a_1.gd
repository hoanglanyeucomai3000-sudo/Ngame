extends Area2D

# Đường dẫn chuyển đến cảnh 12a_1r.tscn
@export_file("*.tscn") var target_scene: String = "res://12a_1r.tscn"

var is_player_nearby: bool = false

func _ready() -> void:
	# Bắt sự kiện khi người chơi lại gần / đi ra xa cửa
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _unhandled_input(event: InputEvent) -> void:
	# Chỉ xử lý khi người chơi đang đứng ở cửa
	if not is_player_nearby:
		return
		
	# Bấm phím E hoặc phím tương tác để vào phòng
	if event.is_action_pressed("ui_interact") or event.is_action_pressed("interact") or (event is InputEventKey and event.pressed and event.keycode == KEY_E):
		if target_scene != "":
			get_tree().change_scene_to_file(target_scene)

func _on_body_entered(body: Node2D) -> void:
	if body.name == "player" or body.is_in_group("player") or body is CharacterBody2D:
		is_player_nearby = true

func _on_body_exited(body: Node2D) -> void:
	if body.name == "player" or body.is_in_group("player") or body is CharacterBody2D:
		is_player_nearby = false
