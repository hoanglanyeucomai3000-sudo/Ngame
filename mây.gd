extends CharacterBody2D

# Tham chiếu các nút con trong mây.tscn
@onready var dialogue_label: Label = $Label
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var follow: PathFollow2D = get_parent() as PathFollow2D
@onready var area_2d: Area2D = $Area2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

# Đặt mốc thời gian di chuyển
@export var go_start: float = 6.0    # 6h bắt đầu đi từ nhà
@export var go_end: float = 7.0    # 7h đến điểm cuối & biến mất
@export var back_start: float = 17.0 # 17h xuất hiện lại ở điểm cuối & bắt đầu đi về
@export var back_end: float = 18.0   # 18h về đến nhà

# Kích thước NPC chuẩn (Scale = 0.6)
@export var npc_scale: Vector2 = Vector2(0.6, 0.6)

var is_player_nearby: bool = false
var current_dialogue_index: int = 0
var dialogues: Array[String] = [
	"Tránh ra cho t đi học 🤬",
	"Tao đang bận, đừng làm phiền!",
	"Cút?",
	"Đang trên đường về nhà rồi..."
]

func _ready() -> void:
	if dialogue_label:
		dialogue_label.hide()
	
	if sprite:
		sprite.scale = npc_scale

	# TỰ ĐỘNG BẮT TÍN HIỆU PHÍM E / NGƯỜI CHƠI LẠI GẦN
	if area_2d:
		area_2d.body_entered.connect(_on_area_2d_body_entered)
		area_2d.body_exited.connect(_on_area_2d_body_exited)

func _process(_delta: float) -> void:
	var hour: float = float(DayNightManager.current_hour)

	if follow == null:
		return
	if not (follow.get_parent() is Path2D):
		return

	var ratio: float = 0.0
	var sign_dir: float = 1.0
	var is_walking: bool = false
	var in_school_hours: bool = (hour >= go_end and hour < back_start) # Bận ở điểm cuối (12h - 17h)

	# ===== XỬ LÝ ẨN / HIỆN NPC KHI Ở ĐIỂM CUỐI (12h - 17h) =====
	_set_active(not in_school_hours)
	if in_school_hours:
		return # Nếu trong khoảng 12h-17h thì ẩn đi và dừng xử lý tiếp

	# ===== TÍNH TOÁN VỊ TRÍ DI CHUYỂN THEO GIỜ =====
	if hour < go_start:
		# Trước 6h sáng: Ở nhà (Điểm 0.0)
		ratio = 0.0
	elif hour < go_end:
		# 6h -> 12h: Đi từ nhà đến điểm cuối
		ratio = inverse_lerp(go_start, go_end, hour)
		is_walking = true
	elif hour < back_end:
		# 17h -> 22h: Đi từ điểm cuối trở về nhà
		ratio = 1.0 - inverse_lerp(back_start, back_end, hour)
		sign_dir = -1.0
		is_walking = true
	else:
		# Sau 22h: Ở nhà
		ratio = 0.0

	# Cập nhật vị trí trên đường đi Path2D
	follow.progress_ratio = clampf(ratio, 0.0, 1.0)

	if sprite.scale != npc_scale:
		sprite.scale = npc_scale

	# ===== XỬ LÝ HOẠT ẢNH (ANIMATION) =====
	if is_walking:
		_update_animation(_get_direction(ratio) * sign_dir)
	else:
		sprite.stop()
		sprite.frame = 0

# Bật/tắt hiển thị và va chạm NPC (Tương tự code Khánh Toàn)
func _set_active(active: bool) -> void:
	visible = active
	if collision_shape:
		collision_shape.set_deferred("disabled", not active)
	if area_2d:
		area_2d.set_deferred("monitoring", active)
	if not active:
		is_player_nearby = false
		current_dialogue_index = 0
		if dialogue_label:
			dialogue_label.hide()

# Tính hướng di chuyển thực tế theo đường cong Path2D
func _get_direction(ratio: float) -> Vector2:
	var path := follow.get_parent() as Path2D
	var curve: Curve2D = path.curve
	var length: float = curve.get_baked_length()
	var a: Vector2 = curve.sample_baked(length * maxf(ratio - 0.005, 0.0))
	var b: Vector2 = curve.sample_baked(length * minf(ratio + 0.005, 1.0))
	return (b - a).normalized()

# Đổi hoạt ảnh đi bộ 4 hướng
func _update_animation(dir: Vector2) -> void:
	if dir == Vector2.ZERO:
		return

	var anim_name: String = "down"
	if abs(dir.x) > abs(dir.y):
		if dir.x > 0:
			anim_name = "right"
		else:
			anim_name = "left"
	else:
		if dir.y > 0:
			anim_name = "down"
		else:
			anim_name = "up"

	if sprite.animation != anim_name or not sprite.is_playing():
		sprite.play(anim_name)

# Tương tác bấm phím E
func _unhandled_input(event: InputEvent) -> void:
	if not is_player_nearby:
		return
	if event.is_action_pressed("ui_interact") or event.is_action_pressed("interact") or (event is InputEventKey and event.pressed and event.keycode == KEY_E):
		show_next_dialogue()

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body != self:
		is_player_nearby = true

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body != self:
		is_player_nearby = false
		current_dialogue_index = 0
		if dialogue_label:
			dialogue_label.hide()

func show_next_dialogue() -> void:
	if dialogue_label == null:
		return
	if current_dialogue_index < dialogues.size():
		dialogue_label.text = dialogues[current_dialogue_index]
		dialogue_label.show()
		current_dialogue_index += 1
	else:
		dialogue_label.hide()
		current_dialogue_index = 0
