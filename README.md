# Godot 4 & Rust WebAssembly Various formats

<p align="center">
<img width="600" src="https://github.com/godot-game-samples/godot-wasm-multi/blob/main/assets/screenshot/screen.png">
</p>

To use Rust with Godot 4, use godot-wasm.

**GitHub**

[godot-wasm](https://github.com/ashtonmeuser/godot-wasm)

### Input Type

| Label      | Input Type        | Data Format              | Example Input            |
|------------|-------------------|--------------------------|--------------------------|
| String     | LineEdit          | `String`                 | "ABCDEF"                 |
| Int        | SpinBox           | `int`                    | 0                        |
| ByteArray  | LineEdit (text)   | JSON-like `Array<int>`   | [1, 2, 3, 4, 5]          |
| JSON       | TextEdit (multiline) | JSON `Dictionary`      | { "name": "creeper", "level": 13 } |

### Output Type

| Log Type     | Description                                                                 |
|---------------|-----------------------------------------------------------------------------|
| DebugLog      | Display input values as they are (no processing)                                        |
| WasmLog       | Pass input to Wasm and read back (without conversion)                                   |
| WasmCalcLog   | Output after processing via Wasm (String: inverted, Number: twice, Bytes: inverted, JSON: processed)           |

**example**

| InputType | InputValue                         | DebugLog                           | WasmLog | WasmCalcLog     |                                       
|-----------|------------------------------------|------------------------------------|--------|-----------------|
| String    | ABCDEF                             | ABCDEF                             | ABCDEF      | FEDCBA          | 
| Number    | 1                                  | 1                                  | 1      | 2               | 
| Bytes     | [1, 2, 3, 4, 5]                    | [1, 2, 3, 4, 5]                    | [1, 2, 3, 4, 5]      | [5, 4, 3, 2, 1] |
| JSON     | { "name": "creeper", "level": 13 } | { "name": "creeper", "level": 13 } | { "name": "creeper", "level": 13 }      | { "name": "repeerc", "level": 26 } |  

## WebAssembly Functions

This section explains how to store and retrieve String, int, PackedByteArray, and JSON values between Godot and WebAssembly (Rust).

All data is stored into linear memory via store_* functions, and then retrieved using memory pointers returned by WebAssembly.

### Godot-side: Store Functions

```
func store_string(text: String, offset := 0) -> int:
	var bytes: PackedByteArray = text.to_utf8_buffer()
	wasm.memory.seek(offset).put_data(bytes)
	wasm.function("store_data", [offset, bytes.size()])
	return bytes.size()

func store_int(value: int, offset: int) -> void:
	var bytes := PackedByteArray()
	bytes.append(value & 0xFF)
	bytes.append((value >> 8) & 0xFF)
	bytes.append((value >> 16) & 0xFF)
	bytes.append((value >> 24) & 0xFF)
	wasm.memory.seek(offset).put_data(bytes)

func store_bytes(bytes: PackedByteArray, offset := 0) -> int:
	wasm.memory.seek(offset).put_data(bytes)
	wasm.function("store_data", [offset, bytes.size()])
	return bytes.size()
```

Note: JSON data is also stored as a UTF-8 encoded string using store_string().

### Godot-side: Read via get_data_ptr

After storing the data, we retrieve the pointer to it from Wasm using get_data_ptr, and then read it back from memory:

```
func get_string(text: String) -> String:
	var offset := 0
	var length = store_string(text, offset)
	var ptr = wasm.function("get_data_ptr")
	var result = wasm.memory.seek(ptr).get_data(length)
	return get_result_string(result)
```

### Rust-side: Wasm Data Handling

```
#[unsafe(no_mangle)]
pub unsafe extern "C" fn store_data(ptr: *const u8, len: usize) {
    let data = unsafe { std::slice::from_raw_parts(ptr, len) };
    let mut guard = BUFFER.lock();
    *guard = Some(data.to_vec());
}

#[unsafe(no_mangle)]
pub unsafe extern "C" fn get_data_ptr() -> *const u8 {
    let guard = BUFFER.lock();
    guard.as_ref().map(|buf| buf.as_ptr()).unwrap_or(core::ptr::null())
}
```

### Rust-side: Processing with Result Buffer

To perform a transformation on the input data (e.g., reversing a string), we use a separate buffer (RESULT_BUFFER):

```
lazy_static! {
    static ref BUFFER: Mutex<Option<Vec<u8>>> = Mutex::new(None);
    static ref RESULT_BUFFER: Mutex<Option<Vec<u8>>> = Mutex::new(None);
}

#[unsafe(no_mangle)]
pub extern "C" fn reverse_string() {
    let buffer_guard = BUFFER.lock();
    let mut result_guard = RESULT_BUFFER.lock();

    if let Some(ref data) = *buffer_guard {
        if let Ok(input_str) = std::str::from_utf8(data) {
            let reversed: String = input_str.chars().rev().collect();
            *result_guard = Some(reversed.into_bytes());
        } else {
            *result_guard = Some("invalid_utf8".as_bytes().to_vec());
        }
    } else {
        *result_guard = Some("no_data".as_bytes().to_vec());
    }
}
```

To retrieve this result:

```
#[unsafe(no_mangle)]
pub unsafe extern "C" fn get_result_buffer_ptr() -> *const u8 {
    let guard = RESULT_BUFFER.lock();
    guard.as_ref().map(|buf| buf.as_ptr()).unwrap_or(core::ptr::null())
}
```

### Godot-side: Read Transformed Result

On the Godot side, you can retrieve the transformed data after processing:

```
func get_string_reverse(text: String) -> String:
	var offset := 0
	var length = store_string(text, offset)
	wasm.function("reverse_string")
	var ptr = wasm.function("get_result_buffer_ptr")
	var result = wasm.memory.seek(ptr).get_data(length)
	return get_result_string(result)
```

### ✅ Summary

- Use store_* to transfer data to Wasm memory
- Use get_data_ptr() to retrieve raw input
- Use get_result_buffer_ptr() to retrieve processed results
- BUFFER is for raw input, RESULT_BUFFER is for transformations
- JSON is treated as a string and parsed after retrieval

## Author

**Daisuke Takayama**

-   [@webcyou](https://twitter.com/webcyou)
-   [@panicdragon](https://twitter.com/panicdragon)
-   <https://github.com/webcyou>
-   <https://github.com/webcyou-org>
-   <https://github.com/panicdragon>
-   <https://www.webcyou.com/>
