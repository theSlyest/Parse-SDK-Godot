class_name ParseServerConf

var app_id: StringName
var client_key: StringName
var server_url: StringName

func _init(id: StringName, key: StringName, url: StringName) -> void:
	app_id = id
	client_key = key
	server_url = url
