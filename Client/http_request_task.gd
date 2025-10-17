class_name HTTPRequestTask

## Emitted when a request is completed. The request can be successful or not successful: if not, an [code]error[/code] Dictionary will be passed as a result.
## @arg-types Variant
signal task_finished()

## Mapping of Methods enum values to descriptions for use in printing user-friendly error codes.
const METHOD_MAP = {
	HTTPClient.METHOD_GET: "GET",
	HTTPClient.METHOD_POST: "CREATE",
	HTTPClient.METHOD_PUT: "UPDATE",
	HTTPClient.METHOD_DELETE: "DELETE"
}

## A variable, temporary holding the result of the request.
var data
var error: Dictionary

## The code indicating the HTTP request is processing.
var _method : HTTPClient.Method = HTTPClient.METHOD_GET

var _response_headers: PackedStringArray = PackedStringArray()
var _response_code: int = 0

var _url: String = ""
var _fields: String = ""
var _headers: PackedStringArray = []


func _init(url: StringName, method: HTTPClient.Method, body: Dictionary) -> void:
	pass

func _on_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	var bod = body.get_string_from_utf8()
	if bod != "":
		bod = Utilities.get_json_data(bod)
	
	var failed: bool = bod is Dictionary and bod.has("error") and response_code != HTTPClient.RESPONSE_OK
	# Probably going to regret this...
	if response_code == HTTPClient.RESPONSE_OK or response_code == HTTPClient.RESPONSE_CREATED:
		match _method:
			HTTPClient.METHOD_POST, HTTPClient.METHOD_GET, HTTPClient.METHOD_PUT:
				pass
			HTTPClient.METHOD_DELETE:
				data = true
	else:
		var description = ""
		if METHOD_MAP.has(_method):
			description = "(" + METHOD_MAP[_method] + ")"

		Parse._printerr("method in error was: " + str(_method) + " " + description)
		build_error(bod, _method, description)
	
	task_finished.emit()


func build_error(_error, method, description) -> void:
	if _error:
		if _error is Array and _error.size() > 0 and _error[0].has("error"):
			_error = _error[0].error
		elif _error is Dictionary and _error.keys().size() > 0 and _error.has("error"):
			_error = _error.error
		
		error = _error
	else:
		#error.code, error.status, error.message
		error = { "error": {
				 "code": 0,
				 "status": "Unknown Error",
				 "message": "Error: %s - %s" % [method, description]
			}
		}
	
	data = null


func _merge_dict(dic_a : Dictionary, dic_b : Dictionary, nullify := false) -> Dictionary:
	var ret := dic_a.duplicate(true)
	for key in dic_b:
		var val = dic_b[key]

		if val == null and nullify:
			ret.erase(key)
		elif val is Array:
			ret[key] = _merge_array(ret.get(key) if ret.get(key) else [], val)
		elif val is Dictionary:
			ret[key] = _merge_dict(ret.get(key) if ret.get(key) else {}, val)
		else:
			ret[key] = val
	return ret


func _merge_array(arr_a : Array, arr_b : Array, nullify := false) -> Array:
	var ret := arr_a.duplicate(true)
	ret.resize(len(arr_b))

	var deletions := 0
	for i in len(arr_b):
		var index : int = i - deletions
		var val = arr_b[index]
		if val == null and nullify:
			ret.remove_at(index)
			deletions += i
		elif val is Array:
			ret[index] = _merge_array(ret[index] if ret[index] else [], val)
		elif val is Dictionary:
			ret[index] = _merge_dict(ret[index] if ret[index] else {}, val)
		else:
			ret[index] = val
	return ret


func run() -> void:
	#_headers = PackedStringArray([_AUTHORIZATION_HEADER + auth.idtoken])

	var	http_request = HTTPRequest.new()
	http_request.timeout = 5
	Utilities.fix_http_request(http_request)
	Parse.add_child(http_request)
	http_request.request_completed.connect(
		func(result, response_code, headers, body): 
			_on_request_completed(result, response_code, headers, body)
			http_request.queue_free()
	)
	
	http_request.request(_url, _headers, _method, _fields)
