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

func getString(text: String) -> String:
	var bytes: PackedByteArray = text.to_utf8_buffer()
	var offset := 0
	
	wasm.memory.seek(offset).put_data(bytes)
	wasm.function("store_data", [offset, bytes.size()])

	var ptr = wasm.function("get_data_ptr")
	var result = wasm.memory.seek(ptr).get_data(bytes.size())

	if result.size() > 1 and result[0] == 0:
		var string_data: PackedByteArray = result[1]
		return string_data.get_string_from_utf8()
	else:
		print("Failed to read memory.")
		return ""

func getInt(value: int) -> int:
	var offset := 0
	var bytes := PackedByteArray()

	# Little-endian encoding of int32
	bytes.append(value & 0xFF)
	bytes.append((value >> 8) & 0xFF)
	bytes.append((value >> 16) & 0xFF)
	bytes.append((value >> 24) & 0xFF)

	wasm.memory.seek(offset).put_data(bytes)
	wasm.function("store_data", [offset, bytes.size()])

	var ptr = wasm.function("get_data_ptr")
	var result = wasm.memory.seek(ptr).get_data(4)

	if result[0] == 0:
		var value_bytes = result[1]
		var int_value = value_bytes[0] | (value_bytes[1] << 8) | (value_bytes[2] << 16) | (value_bytes[3] << 24)
		return int_value
	else:
		print("Failed to read int from memory.")
		return 0
	
func getBytes(bytes: PackedByteArray) -> PackedByteArray: 
	var offset := 0
	wasm.memory.seek(offset).put_data(bytes)
	wasm.function("store_data", [offset, bytes.size()])
	var ptr = wasm.function("get_data_ptr")
	var result = wasm.memory.seek(ptr).get_data(bytes.size())	

	if result[0] == 0:
		var data: PackedByteArray = result[1]
		return data
	else:
		print("Failed to read memory.")
	return []
	
func getJson(text: String) -> Dictionary:
	var bytes: PackedByteArray = text.to_utf8_buffer()
	var offset := 0

	wasm.memory.seek(offset).put_data(bytes)
	wasm.function("store_data", [offset, bytes.size()])

	var ptr = wasm.function("get_data_ptr")
	var result = wasm.memory.seek(ptr).get_data(bytes.size())

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
