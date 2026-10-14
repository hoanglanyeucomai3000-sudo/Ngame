extends Control

@onready var texture_node: TextureRect = $TextureRect # Chỉnh tên nút TextureRect nếu tên khác
@onready var amount_label: Label = $AmountLabel       # Chỉnh tên nút Label nếu tên khác

# Biến lưu trữ thông tin item
var current_item_data: Dictionary = {}

func set_item(item_data: Dictionary) -> void:
	current_item_data = item_data
	
	if texture_node:
		if item_data.has("texture") and item_data["texture"] != null:
			texture_node.texture = item_data["texture"]
		elif item_data.has("icon_path"):
			texture_node.texture = load(item_data["icon_path"])
			
	if amount_label:
		var amount = item_data.get("amount", 1)
		if amount > 1:
			amount_label.text = "x" + str(amount)
			amount_label.show()
		else:
			amount_label.hide()

func clear_slot() -> void:
	current_item_data = {}
	if texture_node:
		texture_node.texture = null
	if amount_label:
		amount_label.hide()

# ====================================================
# HÀM MUA ĐỒ - KIỂM TRA ĐỦ TIỀN MỚI CHO MUA
# ====================================================
func buy_item() -> void:
	if current_item_data.is_empty():
		print("Slot này đang trống!")
		return
		
	# Lấy giá tiền của vật phẩm (mặc định nếu không ghi giá thì đặt là 50)
	var price: int = current_item_data.get("price", 50)
	
	# 1. KIỂM TRA: Nếu hết tiền (Global.money <= 0) hoặc không đủ tiền mua món hàng
	if Global.money < price or Global.money <= 0:
		print("Không đủ tiền! Bạn cần %d tiền nhưng chỉ có %d tiền." % [price, Global.money])
		return # Bắt buộc dừng lại, KHÔNG cho mua nữa!

	# 2. TRỪ TIỀN THỰC TẾ
	Global.money -= price
	print("Mua thành công! Trừ %d tiền. Số tiền còn lại: %d" % [price, Global.money])
	
	# 3. Code thêm vật phẩm vào túi đồ (Inventory) ở đây...
