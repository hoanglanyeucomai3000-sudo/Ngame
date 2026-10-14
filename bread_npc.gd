extends Area2D

var player_in_area = false

func _ready():
	# Phát animation bán hàng nếu có AnimatedSprite2D
	if has_node("AnimatedSprite2D"):
		$AnimatedSprite2D.play("Sell")
		
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body):
	if body.name == "player" or body.name == "Player" or body.is_in_group("player"):
		player_in_area = true
		print("Nhấn E để mở Cửa hàng Bánh mì!")

func _on_body_exited(body):
	if body.name == "player" or body.name == "Player" or body.is_in_group("player"):
		player_in_area = false

func _unhandled_input(event):
	# Khi người chơi đứng ở quầy và nhấn phím E
	if player_in_area and (event.is_action_pressed("ui_accept") or (event is InputEventKey and event.pressed and event.keycode == KEY_E)):
		var shop_ui = get_tree().get_first_node_in_group("shop_ui")
		if shop_ui:
			shop_ui.open_shop()
		else:
			# Tìm theo tên nếu chưa add group
			var shop_node = get_node_or_null("../ShopUI")
			if shop_node:
				shop_node.open_shop()
