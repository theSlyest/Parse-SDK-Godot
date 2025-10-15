class_name ParseObject

var parse_class_name: StringName
var object_id: StringName
var created_at: Time
var updated_at: Time
var acl: String
var server_data: Dictionary[String, Variant]

func get(key: StringName) -> Variant:
	var value := super(key)
	if (value != null):
		return value
	assert(server_data.has(key), "The column {key} does not exist.")
	return server_data.get(key)
