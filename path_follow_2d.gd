extends PathFollow2D

func _ready() -> void:
	# Tắt tự xoay góc để NPC không bị nằm nghiêng khi qua khúc cua
	rotates = false
	loop = false
