extends CanvasLayer

@onready var texture_progress_bar: TextureProgressBar = $TextureProgressBar
@onready var energy_label: Label = $EnergyLabel

func _ready() -> void:
	if energy_label:
		energy_label.hide()

	if texture_progress_bar:
		texture_progress_bar.mouse_entered.connect(_on_mouse_entered)
		texture_progress_bar.mouse_exited.connect(_on_mouse_exited)

	if Global.has_signal("energy_changed"):
		Global.energy_changed.connect(_on_energy_changed)

	_update_bar(Global.current_energy, Global.max_energy)

func _on_mouse_entered() -> void:
	if energy_label:
		energy_label.show()

func _on_mouse_exited() -> void:
	if energy_label:
		energy_label.hide()

func _on_energy_changed(current: float, max_val: float) -> void:
	_update_bar(current, max_val)

func _update_bar(current: float, max_val: float) -> void:
	if texture_progress_bar:
		texture_progress_bar.max_value = max_val
		texture_progress_bar.value = current

	if energy_label:
		energy_label.text = "%d/%d" % [int(current), int(max_val)]
