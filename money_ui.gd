extends CanvasLayer

@onready var money_label: Label = $MoneyLabel

func _process(_delta: float) -> void:
	if money_label != null:
		money_label.text = "%8d" % Global.player_money
