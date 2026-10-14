extends CharacterBody2D

# Tham chiếu đúng tên các nút con trong npc.tscn
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var follow: PathFollow2D = get_parent() as PathFollow2D
@onready var interaction_area: Area2D = $InteractionArea
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

# -------------------------------------------------------------
# CẤU HÌNH NPC CHO BẢNG NÓI CHUYỆN (DIALOGUE UI)
# -------------------------------------------------------------
@export var display_name: String = "Khánh Toàn"  # Tên hiển thị trên khung thoại
@export var npc_code_name: String = "khanh_toan" # Mã NPC viết thường để trùng với tên folder res://khanh_toan/

# Danh sách câu thoại kèm biểu cảm ("biểu_cảm: Nội dung câu thoại")
@export var first_meet_lines: Array[String] = [
	"happy: Chào bạn, mình là Khánh Toàn 🤩!",
	"normal: Bạn mới chuyển đến Kỳ Anh đúng không?"
]

@export var low_friendship_lines: Array[String] = [
	"happy: Trường học ở ngay phía trước kìa!",
	"sad: Đang trên đường đi học...",
	"embarrassed: À... ừm, tớ hơi ngại nói chuyện một chút."
]

@export var high_friendship_lines: Array[String] = [
	"happy: Trời hôm nay đẹp nhỉ? Đi chơi không bạn thân!",
	"surprised: Ồ, gặp lại bạn thích thật đấy!",
	"angry: Đừng có trêu tớ nữa đấy nhé!"
]

# Quản lý trạng thái thân thiết
var has_met: bool = false
var friendship_points: int = 0
var talked_today: bool = false

# -------------------------------------------------------------
# LỊCH TRÌNH VÀ CẤU HÌNH DI CHUYỂN PATH2D
# -------------------------------------------------------------
@export var go_start: float = 6.0    # 6h00 bắt đầu đi
@export var go_end: float = 7.1      # 7h10 đến trường (ẩn khỏi map main)
@export var back_start: float = 16.5 # 16h30 tan học (bắt đầu đi về)
@export var back_end: float = 18.0   # 18h00 về đến nhà

@export var npc_scale: Vector2 = Vector2(0.7, 0.7)
var is_player_nearby: bool = false

func _ready() -> void:
	if sprite:
		sprite.scale = npc_scale

	# Lắng nghe vùng tương tác
	if interaction_area:
		interaction_area.body_entered.connect(_on_interaction_area_body_entered)
		interaction_area.body_exited.connect(_on_interaction_area_body_exited)

	# Lắng nghe chuyển ngày để reset khả năng nói chuyện cộng điểm
	if DayNightManager:
		DayNightManager.day_changed.connect(_on_day_changed)

func _on_day_changed(_day_count: int) -> void:
	talked_today = false

func _process(_delta: float) -> void:
	if not DayNightManager:
		return
		
	var hour: float = float(DayNightManager.current_hour)

	if follow == null or not (follow.get_parent() is Path2D):
		return

	var ratio: float = 0.0
	var sign_dir: float = 1.0
	var is_walking: bool = false
	var in_school_hours: bool = (hour >= go_end and hour < back_start)

	# Ẩn NPC trong giờ học
	_set_active(not in_school_hours)
	if in_school_hours:
		return

	# Tính toán vị trí di chuyển theo giờ
	if hour < go_start:
		ratio = 0.0
	elif hour < go_end:
		ratio = inverse_lerp(go_start, go_end, hour)
		is_walking = true
	elif hour < back_start:
		ratio = 1.0
	elif hour < back_end:
		ratio = 1.0 - inverse_lerp(back_start, back_end, hour)
		sign_dir = -1.0
		is_walking = true
	else:
		ratio = 0.0

	follow.progress_ratio = clampf(ratio, 0.0, 1.0)

	if sprite.scale != npc_scale:
		sprite.scale = npc_scale

	# Hoạt ảnh đi bộ 4 hướng
	if is_walking:
		_update_animation(_get_direction(ratio) * sign_dir)
	else:
		sprite.stop()
		sprite.frame = 0

func _set_active(active: bool) -> void:
	visible = active
	if collision_shape:
		collision_shape.set_deferred("disabled", not active)
	if interaction_area:
		interaction_area.set_deferred("monitoring", active)
	if not active:
		is_player_nearby = false
		if DialogueUI and DialogueUI.is_active:
			DialogueUI.close_dialogue()

func _get_direction(ratio: float) -> Vector2:
	var path := follow.get_parent() as Path2D
	var curve: Curve2D = path.curve
	var length: float = curve.get_baked_length()
	var a: Vector2 = curve.sample_baked(length * maxf(ratio - 0.005, 0.0))
	var b: Vector2 = curve.sample_baked(length * minf(ratio + 0.005, 1.0))
	return (b - a).normalized()

func _update_animation(dir: Vector2) -> void:
	if dir == Vector2.ZERO:
		return

	var anim_name: String = "dow"
	if abs(dir.x) > abs(dir.y):
		if dir.x > 0:
			anim_name = "right"
		else:
			anim_name = "left"
	else:
		if dir.y > 0:
			anim_name = "dow"
		else:
			anim_name = "up"

	if sprite.animation != anim_name or not sprite.is_playing():
		sprite.play(anim_name)

# -------------------------------------------------------------
# XỬ LÝ NÓI CHUYỆN MỞ DIALOGUE UI KHI BẤM E
# -------------------------------------------------------------
func _unhandled_input(event: InputEvent) -> void:
	if not is_player_nearby:
		return
		
	if event.is_action_pressed("ui_interact") or event.is_action_pressed("interact") or (event is InputEventKey and event.pressed and event.keycode == KEY_E):
		if DialogueUI and not DialogueUI.is_active:
			get_viewport().set_input_as_handled()
			speak()

func speak() -> void:
	var lines_to_show: Array[String] = []
	
	# Lần đầu gặp mặt
	if not has_met:
		lines_to_show = first_meet_lines
		has_met = true
		friendship_points += 10
	else:
		# Các lần sau: Lọc thoại theo mức thân thiết
		if friendship_points >= 50:
			lines_to_show = high_friendship_lines
		else:
			lines_to_show = low_friendship_lines
			
		if not talked_today:
			friendship_points += 10
			talked_today = true

	# Gọi DialogueUI mở bảng trò chuyện và load ảnh avatar từ folder res://khanh_toan/
	DialogueUI.start_dialogue(display_name, npc_code_name, lines_to_show)

func _on_interaction_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") or body.name == "player" or body.name == "Player":
		is_player_nearby = true

func _on_interaction_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("player") or body.name == "player" or body.name == "Player":
		is_player_nearby = false
		if DialogueUI and DialogueUI.is_active:
			DialogueUI.close_dialogue()
