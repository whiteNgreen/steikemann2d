extends Node

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause_menu"):
		get_tree().quit(0)
	elif event.is_action_pressed("toggle_screen_mode"):
		var prime_screen: int = DisplayServer.get_primary_screen()
		var mode: DisplayServer.WindowMode = DisplayServer.window_get_mode(prime_screen)
		if mode == DisplayServer.WindowMode.WINDOW_MODE_EXCLUSIVE_FULLSCREEN:
			DisplayServer.window_set_mode(DisplayServer.WindowMode.WINDOW_MODE_WINDOWED, prime_screen)
			DisplayServer.window_set_size(Vector2i(1280, 720), prime_screen)
			var size: Vector2i = DisplayServer.screen_get_size()
			DisplayServer.window_set_position(size / 4, prime_screen)
		else:
			DisplayServer.window_set_mode(DisplayServer.WindowMode.WINDOW_MODE_EXCLUSIVE_FULLSCREEN, prime_screen)
	elif event.is_action_pressed("restart"):
		get_tree().reload_current_scene()
