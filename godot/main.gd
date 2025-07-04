extends Node2D

func _ready() -> void:
	var bytes = PackedByteArray([1, 2, 3, 4, 5])
	var offset = 0
	WasmManager.wasm.memory.seek(offset).put_data(bytes)
	WasmManager.wasm.function("store_data", [offset, bytes.size()])
	
	var ptr = WasmManager.wasm.function("get_data_ptr")
	var len = WasmManager.wasm.function("get_data_len")

	print("ptr: ", ptr)
	print("len: ", len)

	var result = WasmManager.wasm.memory.seek(ptr).get_data(bytes.size())	
	print(result)
		
	if result[0] == 0:
		var data: PackedByteArray = result[1]
		print(data)
	else:
		print("Failed to read memory.")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
