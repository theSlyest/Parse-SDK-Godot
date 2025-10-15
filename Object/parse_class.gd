class_name ParseClass

const URL_PARAM := &"/classes"

var parse_class_name: StringName

func _init(parse_class: StringName) -> void:
	parse_class_name = parse_class

func create() -> ParseObject:
	return null
