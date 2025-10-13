class_name ParseLiveQueryConf

var server_url: StringName
var buffer_size: int = 4096:
	set(value):
		assert(value > 0, "The buffer size should be greater than 0.")
		buffer_size = value
			
var web_socket_timeout: int = 5000:
	set(value):
		assert(value > 0, "The timeout should be greater than 0.")
		web_socket_timeout = value

func _init(url: StringName, buffer:int = 4096, timeout: int = 5000) -> void:
	server_url = url
	buffer_size = buffer
	web_socket_timeout = timeout
