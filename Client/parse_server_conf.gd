class_name ParseServerConf

var app_id: StringName
var server_url: StringName
var client_key: StringName
var master_key: StringName
var http_timeout: int = 5

func _init(id: StringName, url: StringName, key: StringName, m_key: StringName = "", timeout: int = 5) -> void:
	app_id = id
	server_url = url
	client_key = key
	master_key = m_key
	http_timeout = timeout
