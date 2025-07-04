extends Control

@onready var string_input = $HBoxContainer/VBoxContainer/StringInput
@onready var number_input = $HBoxContainer/VBoxContainer/NumberInput
@onready var byte_array_input = $HBoxContainer/VBoxContainer/ByteArrayInput
@onready var json_input = $HBoxContainer/VBoxContainer/JsonInput
@onready var debug_output = $HBoxContainer/DebugContainer/DebugOutput
@onready var wasm_output = $HBoxContainer/WasmContainer/WasmOutput

func _on_submit_button_pressed():
	var string_val = string_input.text
	var number_val = int(number_input.value)
	var byte_array_text = byte_array_input.text
	var json_text = json_input.text

	var byte_result = parse_byte_array(byte_array_text)
	var json_result = parse_json_dictionary(json_text)
	json_result = convert_keys_to_int(json_result, ["level"])

	displayDebugOutput(string_val, number_val, byte_result, json_result)
	displayWasmOutput(string_val, number_val, byte_result, json_text)

func displayDebugOutput(string_val, number_val, byte_result, json_result):
	debug_output.clear()
	debug_output.append_text("[b]String:[/b] %s\n" % string_val)
	debug_output.append_text("[b]Number:[/b] %d\n" % number_val)
	debug_output.append_text("[b]Bytes:[/b] %s\n" % str(byte_result))
	debug_output.append_text("[b]JSON:[/b] %s\n" % str(json_result))

func displayWasmOutput(string_val, number_val, byte_result, json_text):
	var wasm_string_result = getWasmString(string_val)
	var wasm_int_result = getWasmInt(number_val)
	var wasm_byte_result = getWasmBytes(byte_result)
	var wasm_json_result = getWasmJson(json_text)
	wasm_json_result = convert_keys_to_int(wasm_json_result, ["level"])

	wasm_output.clear()
	wasm_output.append_text("[b]String:[/b] %s\n" % wasm_string_result)
	wasm_output.append_text("[b]Number:[/b] %d\n" % wasm_int_result)
	wasm_output.append_text("[b]Bytes:[/b] %s\n" % str(wasm_byte_result))
	wasm_output.append_text("[b]JSON:[/b] %s\n" % str(wasm_json_result))


func parse_byte_array(text: String) -> Array:
	text = text.strip_edges()
	if text.begins_with("[") and text.ends_with("]"):
		text = text.substr(1, text.length() - 2)

	var items = text.split(",", false)
	var byte_array = []

	for item in items:
		var trimmed = item.strip_edges()
		if trimmed.is_valid_int():
			byte_array.append(int(trimmed))
		else:
			push_error("バイト列の要素が数値ではありません: %s" % trimmed)
			return []
	return byte_array

func getWasmString(text: String):
	return WasmManager.getString(text)

func getWasmInt(value: int):
	return WasmManager.getInt(value)

func getWasmBytes(bytes: PackedByteArray):
	return WasmManager.getBytes(bytes)

func getWasmJson(json_text: String):
	return WasmManager.getJson(json_text)

func parse_json_dictionary(json_text: String) -> Dictionary:
	var parser = JSON.new()
	var result = parser.parse(json_text)
	if result == OK:
		var data = parser.get_data()
		if typeof(data) == TYPE_DICTIONARY:
			return data
		else:
			push_error("JSONの内容がオブジェクト（辞書）ではありません")
	else:
		push_error("JSONの構文が不正です")
	return {}
	
func convert_keys_to_int(dict: Dictionary, keys: Array) -> Dictionary:
	var result = dict.duplicate()
	for key in keys:
		if result.has(key):
			var value = result[key]
			if typeof(value) == TYPE_FLOAT:
				result[key] = int(value)
	return result
