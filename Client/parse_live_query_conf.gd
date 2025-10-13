class_name ParseLiveQueryConf

var server_url: StringName
var buffer_size: int = 4096
var web_socket_timeout: int = 5000

func _init(url: StringName, buffer:int = 4096, timeout: int = 5000) -> void:
	server_url = url
	buffer_size = buffer
	web_socket_timeout = timeout
