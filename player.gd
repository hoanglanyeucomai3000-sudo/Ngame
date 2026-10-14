extends CharacterBody2D

@export var normal_speed: float = 120.0
@export var exhausted_speed: float = 50.0
@export var energy_drain_rate: float = 2.0
@export var player_scale: Vector2 = Vector2(0.7, 0.7)

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var held_item_sprite: Sprite2D = $HeldItemSprite

var selected_slot_index: int = -1
var current_held_item: Dictionary = {}

func _ready() -> void:
	if sprite:
		sprite.scale = player_scale
	if held_item_sprite:
		held_item_sprite.hide()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		# Phím 1 đến 8 chọn ô đồ tương ứng
		if event.keycode >= KEY_1 and event.keycode <= KEY_8:
			var slot_idx = event.keycode - KEY_1
			_select_inventory_slot(slot_idx)

		# Phím E hoặc F để ăn món đồ đang cầm trên đầu
		if event.keycode == KEY_E or event.keycode == KEY_F:
			_use_held_item()

func _select_inventory_slot(slot_idx: int) -> void:
	# Bấm lại phím số đang chọn -> Cất đồ xuống
	if selected_slot_index == slot_idx:
		_clear_held_item()
		return

	selected_slot_index = slot_idx

	if Global and slot_idx < Global.inventory_items.size():
		var item = Global.inventory_items[slot_idx]
		if item and not item.is_empty():
			_hold_item(item)
		else:
			_clear_held_item()
	else:
		_clear_held_item()

func _hold_item(item_data: Dictionary) -> void:
	current_held_item = item_data
	if held_item_sprite:
		if item_data.has("texture") and item_data["texture"] != null:
			held_item_sprite.texture = item_data["texture"]
		elif item_data.has("icon_path"):
			held_item_sprite.texture = load(item_data["icon_path"])
		held_item_sprite.show()

func _clear_held_item() -> void:
	selected_slot_index = -1
	current_held_item = {}
	if held_item_sprite:
		held_item_sprite.texture = null
		held_item_sprite.hide()

func _use_held_item() -> void:
	if current_held_item.is_empty():
		return

	var is_food: bool = current_held_item.get("type", "food") == "food" or current_held_item.has("restore_amount")
	
	if is_food:
		var energy_amount: float = float(current_held_item.get("restore_amount", 20.0))
		
		# 1. Hồi năng lượng trong Global
		Global.restore_energy(energy_amount)
		print("Đã ăn %s -> Cộng %.0f Năng Lượng!" % [current_held_item.get("name", "Món ăn"), energy_amount])

		# 2. Giảm số lượng đồ ăn
		if current_held_item.has("amount"):
			current_held_item["amount"] -= 1
			
			if current_held_item["amount"] <= 0:
				if selected_slot_index != -1:
					Global.remove_item_at_index(selected_slot_index)
				_clear_held_item()
			else:
				Global.emit_signal("inventory_updated")
		else:
			if selected_slot_index != -1:
				Global.remove_item_at_index(selected_slot_index)
			_clear_held_item()

func _physics_process(delta: float) -> void:
	var input_dir := Vector2.ZERO

	if Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT):
		input_dir.x -= 1.0
	if Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT):
		input_dir.x += 1.0
	if Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP):
		input_dir.y -= 1.0
	if Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN):
		input_dir.y += 1.0

	if input_dir == Vector2.ZERO:
		input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")

	if input_dir != Vector2.ZERO:
		var current_speed = exhausted_speed if Global.is_exhausted() else normal_speed
		velocity = input_dir.normalized() * current_speed
		Global.consume_energy(energy_drain_rate * delta)
		_update_animation(input_dir)
	else:
		velocity = Vector2.ZERO
		if sprite:
			sprite.stop()
			sprite.frame = 0

	if sprite and sprite.scale != player_scale:
		sprite.scale = player_scale

	move_and_slide()

func _update_animation(dir: Vector2) -> void:
	if sprite == null:
		return

	var is_holding: bool = not current_held_item.is_empty()
	var anim_name: String = "down"

	if abs(dir.x) > abs(dir.y):
		if dir.x > 0:
			anim_name = "right_item" if is_holding else "right"
		else:
			anim_name = "left_item" if is_holding else "left"
	else:
		if dir.y > 0:
			anim_name = "down_item" if is_holding else "down"
		else:
			anim_name = "up_item" if is_holding else "up"

	if sprite.animation != anim_name or not sprite.is_playing():
		sprite.play(anim_name)
