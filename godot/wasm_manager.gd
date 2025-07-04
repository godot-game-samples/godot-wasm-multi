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

func getString():
	pass

func getInt():
	pass
	
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
	
func getJson():
	pass
