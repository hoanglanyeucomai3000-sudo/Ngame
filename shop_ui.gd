extends Control

@onready var grid_container = $Panel/GridContainer

var slot_scene = preload("res://item_slot.tscn")

func _ready():
	hide()

func open_shop():
	show()
	generate_shop_items()

func generate_shop_items():
	if not grid_container:
		return
		
	for child in grid_container.get_children():
		child.queue_free()
	
	for item in Global.bread_shop_items:
		var slot_instance = slot_scene.instantiate()
		grid_container.add_child(slot_instance)
		
		var texture_node = slot_instance.get_node_or_null("TextureRect")
		var price_label = slot_instance.get_node_or_null("PriceLabel")
		
		if texture_node and ResourceLoader.exists(item["icon_path"]):
			texture_node.texture = load(item["icon_path"])
		
		if price_label:
			price_label.text = str(item["price"]) + "k"
		
		# Kết nối sự kiện bấm mua
		if slot_instance.has_signal("pressed"):
			slot_instance.pressed.connect(func(): _on_buy_item(item))

func _on_buy_item(item):
	# Đổi từ Global.player_money thành Global.money cho đồng bộ
	var price = item.get("price", 0)
	
	if Global.money < price:
		print("Không đủ tiền mua món này! Giá: ", price, " | Tiền hiện có: ", Global.money)
		return
		
	# Giả định thêm vào túi đồ (nếu hàm add_to_inventory có sẵn)
	var success = true
	if Global.has_method("add_to_inventory"):
		success = Global.add_to_inventory(item)
		
	if success:
		# TRỪ TIỀN THỰC TẾ
		Global.money -= price
		
		# Đồng bộ lại player_money nếu trong Global anh dùng cả 2 biến
		if "player_money" in Global:
			Global.player_money = Global.money
			
		print("Đã mua thành công: ", item["name"], " | Tiền còn lại: ", Global.money)
		
		# Làm mới túi đồ UI nếu có
		get_tree().call_group("inventory_ui", "update_inventory_ui")
	else:
		print("Túi đồ đã đầy!")

# Nhấn ESC hoặc E để đóng Shop
func _input(event):
	if visible and event is InputEventKey and event.pressed:
		if event.keycode == KEY_ESCAPE or event.keycode == KEY_E:
			hide()
