extends Node

func _printerr(...args: Array) -> void:
	printerr("[Firebase Error] >> ", args)

func _print(...args: Array) -> void:
	print("[Firebase] >> ", args)
