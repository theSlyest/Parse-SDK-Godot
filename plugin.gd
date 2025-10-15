@tool
extends EditorPlugin

func _enable_plugin() -> void:
	add_autoload_singleton("Parse", "res://addons/parse-sdk/parse/parse.tscn")

func _disable_plugin() -> void:
	remove_autoload_singleton("Parse")
