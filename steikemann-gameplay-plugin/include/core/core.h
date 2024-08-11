#ifndef GD_CORECORE_PLUGIN_STEIKEMANNGAMEPLAY_H
#define GD_CORECORE_PLUGIN_STEIKEMANNGAMEPLAY_H

#include <assert.h>
#include <chrono>
#include <godot_cpp/classes/engine.hpp>
#include <typeinfo>

// Distinction between editor-mode and in-game
#define RETURN_IF_EDITOR                                    \
	if (godot::Engine::get_singleton()->is_editor_hint()) { \
		return;                                             \
	}

#define GETNAME(class_name) \
	String get_class_name() const { return #class_name; }
#define DEFAULT_PROPERTY(class_name)                                                                     \
	ClassDB::bind_method(D_METHOD("get_class_name"), &class_name::get_class_name);                       \
	ClassDB::add_property(                                                                               \
			#class_name,                                                                                 \
			PropertyInfo(Variant::STRING, "class_name", PROPERTY_HINT_NONE, "", PROPERTY_USAGE_DEFAULT), \
			"",                                                                                          \
			"get_class_name");

namespace InputMap {
constexpr const char* move_left = "move_left";
constexpr const char* move_right = "move_right";
constexpr const char* jump = "jump";
constexpr const char* pause_menu = "pause_menu";
constexpr const char* toggle_screen_mode = "toggle_screen_mode";

// Some Built-in actions
constexpr const char* ui_up = "ui_up";
constexpr const char* ui_down = "ui_down";
} //namespace InputMap

enum class EInputAction : int {
	NONE = -1,
	// Game action
	// MOVE_LEFT,
	// MOVE_RIGHT,
	JUMP,
	PAUSE_MENU,
	TOGGLE_SCREEN_MODE,

	// Some Built-in Actions
	UI_ACCEPT,
	UI_SELECT,
	UI_CANCEL,
	UI_FOCUS_NEXT,
	UI_FOCUS_PREV,
	UI_LEFT,
	UI_RIGHT,
	UI_UP,
	UI_DOWN,
	UI_MENU,
};

enum class EInputActionType : int {
	NONE = -1,
	PRESSED,
	RELEASED,
	HELD,
};

struct InputAction {
	InputAction(EInputAction a, EInputActionType t) :
			action(a), type(t), timestamp(std::chrono::system_clock::now()) {}
	EInputAction action = EInputAction::NONE;
	EInputActionType type = EInputActionType::NONE;
	std::chrono::system_clock::time_point timestamp;

	bool received_input_within_timeframe(float timeframe_seconds) {
		float duration_since_timestamp = std::chrono::duration_cast<std::chrono::nanoseconds>(
				std::chrono::system_clock::now() - timestamp)
												 .count();
		float sec = (duration_since_timestamp / 1e9);
		printf("timeframe: %f -- time: %f \n", timeframe_seconds, sec);
		return (duration_since_timestamp / 1e9) < timeframe_seconds;
	}
};

#endif // GD_CORECORE_PLUGIN_STEIKEMANNGAMEPLAY_H