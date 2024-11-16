extends Control


var brightness :int = 0

var r:int = 0 
var g:int = 0
var b:int = 0

var boot:bool = false
var awake:bool = false
var sleep:bool = false

var mode:int = 0
var speed:int = 0

var config = ConfigFile.new()

var colors :Array[Color]
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	colors = _load_colors()
	for c in colors:
		$MarginContainer/VBoxContainer/ColorPicker.add_preset(c)
	_load_scores()
	

func _on_color_picker_preset_added(color: Color) -> void:
	colors.append(color)
	_save_colors(colors)


func _on_color_picker_preset_removed(color: Color) -> void:
	colors.erase(color)
	_save_colors(colors)


func _on_color_picker_color_changed(color: Color) -> void:
	r = color.r8
	g = color.g8
	b = color.b8
	set_kbd_rgb_mode(mode , r, g, b, speed)
	_save_scores()


func _on_brightness_value_changed(value: float) -> void:
	brightness = int(value)
	set_brightness(brightness)
	_save_scores()


func _on_speed_value_changed(value: float) -> void:
	speed = int(value)
	set_kbd_rgb_mode(mode , r, g, b, speed)
	_save_scores()


func _on_mode_item_selected(index: int) -> void:
	mode = index
	set_kbd_rgb_mode(mode , r, g, b, speed)
	_save_scores()


func _on_boot_toggled(toggled_on: bool) -> void:
	boot = toggled_on
	set_kbd_rgb_state(boot, awake, sleep)
	_save_scores()


func _on_awake_toggled(toggled_on: bool) -> void:
	awake = toggled_on
	set_kbd_rgb_state(boot, awake, sleep)
	_save_scores()


func _on_sleep_toggled(toggled_on: bool) -> void:
	sleep = toggled_on
	set_kbd_rgb_state(boot, awake, sleep)
	_save_scores()
	

func set_kbd_rgb_mode(mode:int, r:int, g:int, b:int, speed:int) -> void:
	var ok = OS.execute("bash", ["-c", "echo '1 %d %d %d %d %d' > /sys/class/leds/asus::kbd_backlight/kbd_rgb_mode " % [mode, r, g, b, speed]])

func set_brightness(brightness:int) -> void:
	var ok = OS.execute("bash", ["-c", "echo '%d' > /sys/class/leds/asus::kbd_backlight/brightness " % [brightness]])


func set_kbd_rgb_state(boot:bool, awake:bool, sleep:bool) -> void:
	var boot_int := int(boot)
	var awake_int := int(awake)
	var sleep_int := int(sleep)
	var ok = OS.execute("bash", ["-c", "echo '1 %d %d %d 1' > /sys/class/leds/asus::kbd_backlight/kbd_rgb_state " % [boot_int, awake_int, sleep_int]])
	
	
func _load_scores():
	var err = config.load("user://scores.cfg")
	if err != OK:
		config.save("user://scores.cfg")
		return
	r = config.get_value("settings", "r", 120)
	g = config.get_value("settings", "g", 120)
	b = config.get_value("settings", "b", 120)
	boot = config.get_value("settings", "boot", true)
	awake = config.get_value("settings", "awake", true)
	sleep = config.get_value("settings", "sleep", false)
	mode = config.get_value("settings", "mode", 0)
	speed = config.get_value("settings", "speed", 0)
	brightness = config.get_value("settings", "brightness", 1)
	_save_scores()
	var _color = Color()
	_color.r8 = r
	_color.g8 = g
	_color.b8 = b
	$MarginContainer/VBoxContainer/ColorPicker.set("color", _color)
	$MarginContainer/VBoxContainer/cont/boot.set("button_pressed", boot)
	$MarginContainer/VBoxContainer/cont/awake.set("button_pressed", awake)
	$MarginContainer/VBoxContainer/cont/sleep.set("button_pressed", sleep)
	$MarginContainer/VBoxContainer/Mode.selected = mode
	$MarginContainer/VBoxContainer/Speed.set("value", speed)
	$MarginContainer/VBoxContainer/Brightness.set("value", brightness)
	set_brightness(brightness)
	set_kbd_rgb_mode(mode, r, g, b, speed)
	set_kbd_rgb_state(boot, awake, sleep)
	

func _save_scores():
	config.set_value("settings", "r", r)
	config.set_value("settings", "g", g)
	config.set_value("settings", "b", b)
	config.set_value("settings", "boot", boot)
	config.set_value("settings", "awake", awake)
	config.set_value("settings", "sleep", sleep)
	config.set_value("settings", "mode", mode)
	config.set_value("settings", "brightness", brightness)
	config.set_value("settings", "speed", speed)
	config.save("user://scores.cfg")


func _save_colors(colors: Array[Color]) -> void:
	var file = FileAccess.open("user://colors.txt", FileAccess.WRITE)
	if file:
		for color in colors:
			file.store_line(color.to_html())
		file.close()

func _load_colors() -> Array[Color]:
	var _colors: Array[Color] = []
	var file = FileAccess.open("user://colors.txt", FileAccess.READ)
	if file:
		while not file.eof_reached():
			var color_hex = file.get_line()
			_colors.append(Color(color_hex))
		file.close()
	_colors.pop_back()
	return _colors
