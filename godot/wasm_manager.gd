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
