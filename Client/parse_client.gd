class_name ParseClient

var _server_conf: ParseServerConf
var _live_query_conf: ParseLiveQueryConf

func _init(server_conf: ParseServerConf, live_query_conf: ParseLiveQueryConf = null) -> void:
	assert(server_conf != null, "The server configuration should not be null.")
	_server_conf = server_conf
	_live_query_conf = live_query_conf
