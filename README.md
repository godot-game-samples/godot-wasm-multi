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

| Log Type     | String  | Number | Bytes           | JSON                                      | Description                                                                 |
|--------------|---------|--------|------------------|-------------------------------------------|-----------------------------------------------------------------------------|
| DebugLog     | ABCDEF  | 1      | [1, 2, 3, 4, 5]  | { "name": "creeper", "level": 13 }        | Display input values as they are (no processing)                                        |
| WasmLog      | ABCDEF  | 1      | [1, 2, 3, 4, 5]  | { "name": "creeper", "level": 13 }        | Pass input to Wasm and read back (without conversion)                                   |
| WasmCalcLog  | FEDCBA  | 2      | [5, 4, 3, 2, 1]  | { "name": "repeerc", "level": 26 }        | Output after processing via Wasm (String: inverted, Number: twice, Bytes: inverted, JSON: processed)           |

## Author

**Daisuke Takayama**

-   [@webcyou](https://twitter.com/webcyou)
-   [@panicdragon](https://twitter.com/panicdragon)
-   <https://github.com/webcyou>
-   <https://github.com/webcyou-org>
-   <https://github.com/panicdragon>
-   <https://www.webcyou.com/>
