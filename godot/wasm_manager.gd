extends Node

@onready var wasm: Wasm = Wasm.new()
@onready var memory = WasmMemory.new()

func _ready() -> void:
	var bytecode = FileAccess.get_file_as_bytes("res://rust.wasm")
	var imports = {
		"memory": memory,
	}
	wasm.load(bytecode, imports)

func _process(delta: float) -> void:
	pass

func store_string(text: String, offset := 0) -> int:
	var bytes: PackedByteArray = text.to_utf8_buffer()
	wasm.memory.seek(offset).put_data(bytes)
	wasm.function("store_data", [offset, bytes.size()])
	return bytes.size()

func get_string(text: String) -> String:
	var offset := 0
	var length = store_string(text, offset)
	var ptr = wasm.function("get_data_ptr")
	var result = wasm.memory.seek(ptr).get_data(length)
	return get_result_string(result)

func get_result_string(result: Array) -> String:
	if result.size() > 1 and result[0] == 0:
		var string_data: PackedByteArray = result[1]
		return string_data.get_string_from_utf8()
	else:
		print("Failed to read memory.")
		return ""

func get_string_reverse(text: String) -> String:
	var offset := 0
	var length = store_string(text, offset)
	wasm.function("reverse_string")
	var ptr = wasm.function("get_result_buffer_ptr")
	var result = wasm.memory.seek(ptr).get_data(length)
	return get_result_string(result)

func store_int(value: int, offset: int) -> void:
	var bytes := PackedByteArray()
	bytes.append(value & 0xFF)
	bytes.append((value >> 8) & 0xFF)
	bytes.append((value >> 16) & 0xFF)
	bytes.append((value >> 24) & 0xFF)
	wasm.memory.seek(offset).put_data(bytes)

func get_int_at(offset: int) -> int:
	var result = wasm.memory.seek(offset).get_data(4)
	if result[0] == 0:
		var value_bytes = result[1]		
		return value_bytes[0] | (value_bytes[1] << 8) | (value_bytes[2] << 16) | (value_bytes[3] << 24)
	else:
		print("Failed to read 4 bytes from memory.")
		return 0

func get_int(value: int) -> int:
	var offset := 0
	store_int(value, offset)
	wasm.function("store_data", [offset, 4])
	var ptr = wasm.function("get_data_ptr")
	return get_int_at(ptr)

func get_int_double(value: int) -> int:
	var offset := 0
	store_int(value, offset)
	wasm.function("store_data", [offset, 4])
	wasm.function("double_stored_data")
	var ptr = wasm.function("get_result_buffer_ptr")
	return get_int_at(ptr)

func get_result_bytes(result: Array) -> PackedByteArray:
	if result[0] == 0:
		return result[1]
	else:
		print("Failed to read memory.")
	return []

func store_bytes(bytes: PackedByteArray, offset := 0) -> int:
	wasm.memory.seek(offset).put_data(bytes)
	wasm.function("store_data", [offset, bytes.size()])
	return bytes.size()

func get_bytes(bytes: PackedByteArray) -> PackedByteArray: 
	var offset := 0
	var length = store_bytes(bytes, offset)
	var ptr = wasm.function("get_data_ptr")
	var result = wasm.memory.seek(ptr).get_data(length)	
	return get_result_bytes(result)
	
func get_bytes_reverse(bytes: PackedByteArray) -> PackedByteArray:
	var offset := 0
	var length = store_bytes(bytes, offset)

	wasm.function("reverse_bytes")
	var ptr = wasm.function("get_result_buffer_ptr")
	var result = wasm.memory.seek(ptr).get_data(length)
	return get_result_bytes(result)

func get_json_result(result: Array) -> Dictionary:
	if result.size() > 1 and result[0] == 0:
		var json_bytes: PackedByteArray = result[1]
		var json_string = json_bytes.get_string_from_utf8()
		var parser = JSON.new()
		if parser.parse(json_string) == OK:
			var data = parser.get_data()
			if typeof(data) == TYPE_DICTIONARY:
				return data
			else:
				push_error("返されたJSONがオブジェクトではありません")
		else:
			push_error("JSONの構文が不正です: %s" % json_string)
	else:
		print("Failed to read memory.")
	return {}
	
func get_json(text: String) -> Dictionary:
	var offset := 0
	var length = store_string(text, offset)
	var ptr = wasm.function("get_data_ptr")
	var result = wasm.memory.seek(ptr).get_data(length)
	
	return get_json_result(result)

func get_json_transformed(text: String) -> Dictionary:
	var offset := 0
	var length = store_string(text, offset)

	wasm.function("transform_player")
	var ptr = wasm.function("get_result_buffer_ptr")
	var result_length = wasm.function("get_result_buffer_size")
	var result = wasm.memory.seek(ptr).get_data(result_length)

	var json_bytes: PackedByteArray = result[1]
	var json_string = json_bytes.get_string_from_utf8()
	
	return get_json_result(result)
