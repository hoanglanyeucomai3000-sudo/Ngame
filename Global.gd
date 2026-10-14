extends Node

# --- TÍN HIỆU (SIGNALS) ---
signal energy_changed(current_energy: float, max_energy: float)
signal inventory_updated()

# --- TIỀN TỆ & NĂNG LƯỢNG ---
var player_money: int = 200

# Tạo biến alias 'money' liên kết trực tiếp với 'player_money' 
# Giúp money_ui.gd và shop_ui.gd trừ tiền cực kỳ đồng bộ
var money: int:
	get:
		return player_money
	set(value):
		player_money = value

var max_energy: float = 100.0
var current_energy: float = 100.0

# --- DANH SÁCH 8 MÓN ĂN TRONG SHOP ---
var bread_shop_items: Array = [
	{
		"name": "Bánh mì chả",
		"price": 15,
		"type": "food",
		"restore_amount": 25.0,
		"icon_path": "res://banh_my_cha.png"
	},
	{
		"name": "Bánh mì pate",
		"price": 15,
		"type": "food",
		"restore_amount": 25.0,
		"icon_path": "res://banh_my_pate.png"
	},
	{
		"name": "Bánh mì thịt",
		"price": 20,
		"type": "food",
		"restore_amount": 35.0,
		"icon_path": "res://banh_my_thit.png"
	},
	{
		"name": "Bánh tráng nướng",
		"price": 12,
		"type": "food",
		"restore_amount": 20.0,
		"icon_path": "res://banh_trang_nuong.png"
	},
	{
		"name": "Bánh tráng trộn",
		"price": 15,
		"type": "food",
		"restore_amount": 20.0,
		"icon_path": "res://banh_trang_tron.png"
	},
	{
		"name": "Xôi gà",
		"price": 25,
		"type": "food",
		"restore_amount": 40.0,
		"icon_path": "res://xoi_ga.png"
	},
	{
		"name": "Xôi thập cẩm",
		"price": 30,
		"type": "food",
		"restore_amount": 50.0,
		"icon_path": "res://xoi_thap_cam.png"
	},
	{
		"name": "Xôi xéo",
		"price": 20,
		"type": "food",
		"restore_amount": 30.0,
		"icon_path": "res://xoi_xeo.png"
	}
]

# --- KHO ĐỒ (INVENTORY) ---
var inventory_items: Array = []
var max_inventory_slots: int = 8

# Thêm vật phẩm vào Túi đồ (Cộng dồn số lượng nếu trùng món)
func add_to_inventory(item_data: Dictionary) -> bool:
	for item in inventory_items:
		if item.get("name") == item_data.get("name"):
			item["amount"] = item.get("amount", 1) + 1
			emit_signal("inventory_updated")
			return true
	
	if inventory_items.size() < max_inventory_slots:
		var new_item = item_data.duplicate()
		new_item["amount"] = 1
		inventory_items.append(new_item)
		emit_signal("inventory_updated")
		return true
		
	print("Túi đồ đã đầy (đủ 8 ô)!")
	return false

# Xóa hoặc giảm vật phẩm tại vị trí index
func remove_item_at_index(index: int) -> void:
	if index >= 0 and index < inventory_items.size():
		inventory_items.remove_at(index)
		emit_signal("inventory_updated")

# --- HÀM NĂNG LƯỢNG ---
func consume_energy(amount: float) -> void:
	current_energy = clampf(current_energy - amount, 0.0, max_energy)
	emit_signal("energy_changed", current_energy, max_energy)

func restore_energy(amount: float) -> void:
	current_energy = clampf(current_energy + amount, 0.0, max_energy)
	emit_signal("energy_changed", current_energy, max_energy)

func is_exhausted() -> bool:
	return current_energy <= 0.0
