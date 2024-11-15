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

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func _on_color_picker_preset_added(color: Color) -> void:
	pass # Replace with function body.


func _on_color_picker_color_changed(color: Color) -> void:
	r = color.r8
	g = color.g8
	b = color.b8
	set_kbd_rgb_mode(mode , r, g, b, speed)


func _on_brightness_value_changed(value: float) -> void:
	brightness = int(value)
	set_brightness(brightness)


func _on_speed_value_changed(value: float) -> void:
	speed = int(value)
	set_kbd_rgb_mode(mode , r, g, b, speed)


func _on_mode_item_selected(index: int) -> void:
	mode = index
	set_kbd_rgb_mode(mode , r, g, b, speed)
	

func _on_boot_toggled(toggled_on: bool) -> void:
	boot = toggled_on
	set_kbd_rgb_state(boot, awake, sleep)


func _on_awake_toggled(toggled_on: bool) -> void:
	awake = toggled_on
	set_kbd_rgb_state(boot, awake, sleep)


func _on_sleep_toggled(toggled_on: bool) -> void:
	sleep = toggled_on
	set_kbd_rgb_state(boot, awake, sleep)


func set_kbd_rgb_mode(mode:int, r:int, g:int, b:int, speed:int) -> void:
	var ok = OS.execute("bash", ["-c", "echo '1 %d %d %d %d %d' > /sys/class/leds/asus::kbd_backlight/kbd_rgb_mode " % [mode, r, g, b, speed]])

func set_brightness(brightness:int) -> void:
	var ok = OS.execute("bash", ["-c", "echo '%d' > /sys/class/leds/asus::kbd_backlight/brightness " % [brightness]])


func set_kbd_rgb_state(boot:bool, awake:bool, sleep:bool) -> void:
	var boot_int := int(boot)
	var awake_int := int(awake)
	var sleep_int := int(sleep)
	var ok = OS.execute("bash", ["-c", "echo '1 %d %d %d 1' > /sys/class/leds/asus::kbd_backlight/kbd_rgb_state " % [boot_int, awake_int, sleep_int]])
