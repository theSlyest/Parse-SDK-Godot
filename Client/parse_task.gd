class_name ParseTask

## Emitted when a request is completed. The request can be successful or not successful: if not, an [code]error[/code] Dictionary will be passed as a result.
## @arg-types Variant
signal task_finished()

enum Task {
	TASK_GET,       ## A GET Request Task, processing a get() request
	TASK_POST,      ## A POST Request Task, processing add() request
	TASK_PUT,     ## A PATCH Request Task, processing a update() request
	TASK_DELETE    ## A DELETE Request Task, processing a delete() request
}

## Mapping of Task enum values to descriptions for use in printing user-friendly error codes.
const TASK_MAP = {
	Task.TASK_GET: "GET DOCUMENT",
	Task.TASK_POST: "ADD DOCUMENT",
	Task.TASK_PUT: "UPDATE DOCUMENT",
	Task.TASK_DELETE: "DELETE DOCUMENT",
}

## The code indicating the HTTP request is processing.
## @setter set_action
var action : int = -1 : set = set_action

## A variable, temporary holding the result of the request.
var data
var error: Dictionary

var _response_headers: PackedStringArray = PackedStringArray()
var _response_code: int = 0

var _method: int = -1
var _url: String = ""
var _fields: String = ""
var _headers: PackedStringArray = []

func _on_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	var bod = body.get_string_from_utf8()
	if bod != "":
		bod = Utilities.get_json_data(bod)
	
	var failed: bool = bod is Dictionary and bod.has("error") and response_code != HTTPClient.RESPONSE_OK
	# Probably going to regret this...
	if response_code == HTTPClient.RESPONSE_OK or response_code == HTTPClient.RESPONSE_CREATED:
		match action:
			Task.TASK_POST, Task.TASK_GET, Task.TASK_PUT:
				document = FirestoreDocument.new(bod)
				data = document
			Task.TASK_DELETE:
				data = true
	else:
		var description = ""
		if TASK_MAP.has(action):
			description = "(" + TASK_MAP[action] + ")"

		Parse._printerr("Action in error was: " + str(action) + " " + description)
		build_error(bod, action, description)
	
	task_finished.emit()
		
func build_error(_error, action, description) -> void:
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
				 "message": "Error: %s - %s" % [action, description]
			}
		}
	
	data = null

func set_action(value : int) -> void:
	action = value
	match action:
		Task.TASK_GET:
			_method = HTTPClient.METHOD_GET
		Task.TASK_POST:
			_method = HTTPClient.METHOD_POST
		Task.TASK_PUT:
			_method = HTTPClient.METHOD_PATCH
		Task.TASK_DELETE:
			_method = HTTPClient.METHOD_DELETE
		_:
			assert(false)


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
