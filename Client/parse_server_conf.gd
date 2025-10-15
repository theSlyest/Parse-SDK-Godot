class_name ParseServerConf

var app_id: StringName
var server_url: StringName
var client_key: StringName
var master_key: StringName

func _init(id: StringName, url: StringName, key: StringName, m_key: StringName = "") -> void:
	app_id = id
	server_url = url
	client_key = key
	master_key = m_key
