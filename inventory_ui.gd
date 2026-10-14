extends Control

@onready var grid_container = $Panel/GridContainer
@onready var detect_area = $DetectPlayerArea

var slot_scene = preload("res://item_slot.tscn")

func _ready():
	add_to_group("inventory_ui")
	
	# 1. LẮNG NGHE TÍN HIỆU TỪ GLOBAL ĐỂ TỰ ĐỘNG VẼ LẠI GIAO DIỆN
	if Global.has_signal("inventory_updated"):
		Global.inventory_updated.connect(update_inventory_ui)
	
	update_inventory_ui()
	
	if detect_area:
		detect_area.body_entered.connect(_on_player_entered_area)
		detect_area.body_exited.connect(_on_player_exited_area)

func _on_player_entered_area(body):
	if body.is_in_group("player"):
		var tween = create_tween()
		tween.tween_property(self, "modulate:a", 0.2, 0.2)

func _on_player_exited_area(body):
	if body.is_in_group("player"):
		var tween = create_tween()
		tween.tween_property(self, "modulate:a", 1.0, 0.2)

# Cập nhật hiển thị luôn đúng 8 ô
func update_inventory_ui():
	if not grid_container:
		return
		
	# Xóa các node ô cũ trước khi vẽ lại
	for child in grid_container.get_children():
		child.queue_free()
		
	# Luôn tạo đủ 8 ô vuông
	for i in range(8):
		var slot_instance = slot_scene.instantiate()
		grid_container.add_child(slot_instance)
		
		var texture_node = slot_instance.get_node_or_null("TextureRect")
		var amount_label = slot_instance.get_node_or_null("AmountLabel")
		var price_label = slot_instance.get_node_or_null("PriceLabel")
		
		# Ẩn nhãn giá tiền trong túi đồ
		if price_label:
			price_label.hide()
			
		# Nếu ô thứ i này có vật phẩm trong Global.inventory_items
		if i < Global.inventory_items.size():
			var item = Global.inventory_items[i]
			
			# Kiểm tra item có hợp lệ và số lượng > 0 hay không
			if item and not item.is_empty() and item.get("amount", 0) > 0:
				# Hiện icon
				if texture_node:
					if item.has("icon_path") and ResourceLoader.exists(item["icon_path"]):
						texture_node.texture = load(item["icon_path"])
						texture_node.show()
					elif item.has("texture") and item["texture"] != null:
						texture_node.texture = item["texture"]
						texture_node.show()
					else:
						texture_node.texture = null
				
				# Hiện số lượng (x2, x3...)
				if amount_label:
					if item.get("amount", 1) > 1:
						amount_label.text = "x" + str(item["amount"])
						amount_label.show()
					else:
						amount_label.hide()
			else:
				# Nếu ô này bị rỗng/hết đồ
				_clear_slot_nodes(texture_node, amount_label)
		else:
			# Ô rỗng ngoài phạm vi mảng
			_clear_slot_nodes(texture_node, amount_label)

# Hàm phụ hỗ trợ xóa hình ảnh và số lượng của ô
func _clear_slot_nodes(texture_node, amount_label):
	if texture_node:
		texture_node.texture = null
	if amount_label:
		amount_label.hide()

# Hàm ăn/dùng vật phẩm trực tiếp
func use_item(item_data: Dictionary) -> void:
	if item_data.is_empty():
		return

	if item_data.get("type", "food") == "food" or item_data.has("restore_amount"):
		var energy_amount: float = float(item_data.get("restore_amount", 20.0))
		
		# 1. Hồi năng lượng trong Global
		Global.restore_energy(energy_amount)
		print("Đã ăn %s, hồi %.0f năng lượng!" % [item_data.get("name", "đồ ăn"), energy_amount])
		
		# 2. Giảm số lượng vật phẩm đi 1
		if item_data.has("amount"):
			item_data["amount"] -= 1
			
			# Nếu hết đồ -> Tìm vị trí và xóa khỏi mảng Global
			if item_data["amount"] <= 0:
				var idx = Global.inventory_items.find(item_data)
				if idx != -1:
					Global.remove_item_at_index(idx)
				else:
					Global.emit_signal("inventory_updated")
			else:
				# Nếu vẫn còn đồ -> Phát tín hiệu làm mới số lượng
				Global.emit_signal("inventory_updated")
		else:
			var idx = Global.inventory_items.find(item_data)
			if idx != -1:
				Global.remove_item_at_index(idx)
			else:
				Global.emit_signal("inventory_updated")
