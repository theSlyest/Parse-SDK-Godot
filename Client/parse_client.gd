class_name ParseClient

var _server_conf: ParseServerConf
var _live_query_conf: ParseLiveQueryConf

func _init(server_conf: ParseServerConf, live_query_conf: ParseLiveQueryConf = null) -> void:
	if (server_conf == null):
		pass
	_server_conf = server_conf
	_live_query_conf = live_query_conf
