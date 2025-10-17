extends Node

var _config: Dictionary = {
	"appId": "",
	"url": "",
	"clientKey": "",
	"masterKey": "",
	"httpTimeout": 5,
	"liveQuery": {
		"url": "",
		"bufferSize": 4096,
		"timeout": 5
	},
	"auth": {
		"google": {},
		"apple": {}
	}
}

var Client: ParseClient



func _ready() -> void:
	load_config()


func load_config() -> void
	if not (_config.apiKey != "" and _config.authDomain != ""):
		var env = ConfigFile.new()
		var err = env.load("res://addons/pare-sdk/.env")
		if err == OK:
			for key in _config.keys():
				var config_value = _config[key]
				if key == "emulators" and config_value.has("ports"):
					for port in config_value["ports"].keys():
						config_value["ports"][port] = env.get_value(_EMULATORS_PORTS, port, "")
				if key == "auth_providers":
					for provider in config_value.keys():
						config_value[provider] = env.get_value(_AUTH_PROVIDERS, provider, "")
				else:
					var value : String = env.get_value(_ENVIRONMENT_VARIABLES, key, "")
					if value == "":
						_print("The value for `%s` is not configured. If you are not planning to use it, ignore this message." % key)
					else:
						_config[key] = value
		else:
			_printerr("Unable to read .env file at path 'res://addons/godot-firebase/.env'")

	_setup_modules()

func _printerr(...args: Array) -> void:
	printerr("[Firebase Error] >> ", args)

func _print(...args: Array) -> void:
	print("[Firebase] >> ", args)
