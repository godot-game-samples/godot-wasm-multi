#!/bin/bash

set -e
cd "$(dirname "$0")/.."

echo "🔧 Building Rust WASM..."
cd rust
cargo build --release --target wasm32-unknown-unknown

WASM_PATH="target/wasm32-unknown-unknown/release/rust.wasm"
DEST_PATH="../godot/rust.wasm"

echo "📦 Copying $WASM_PATH to $DEST_PATH"
cp "$WASM_PATH" "$DEST_PATH"

echo "✅ Done!"
