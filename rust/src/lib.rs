pub mod player;
use crate::player::Player;
use spin::Mutex;
use lazy_static::lazy_static;

lazy_static! {
    static ref BUFFER: Mutex<Option<Vec<u8>>> = Mutex::new(None);
    static ref RESULT_BUFFER: Mutex<Option<Vec<u8>>> = Mutex::new(None);
    static ref LAST_STRING: Mutex<Option<String>> = Mutex::new(None);
    static ref LAST_JSON: Mutex<Option<String>> = Mutex::new(None);
}

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

#[unsafe(no_mangle)]
pub unsafe extern "C" fn get_data_len() -> usize {
    let guard = BUFFER.lock();
    guard.as_ref().map(|buf| buf.len()).unwrap_or(0)
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

#[unsafe(no_mangle)]
pub extern "C" fn double_stored_data() {
    let buffer_guard = BUFFER.lock();
    let mut result_guard = RESULT_BUFFER.lock();

    if let Some(ref data) = *buffer_guard {
        if data.len() >= 4 {
            let value = i32::from_le_bytes([data[0], data[1], data[2], data[3]]);
            let doubled = value.wrapping_mul(2);
            let bytes = doubled.to_le_bytes();
            *result_guard = Some(bytes.to_vec());
        } else {
            *result_guard = Some(vec![0, 0, 0, 0]); // fallback
        }
    } else {
        *result_guard = Some(vec![0, 0, 0, 0]); // fallback
    }
}

#[unsafe(no_mangle)]
pub extern "C" fn reverse_bytes() {
    let buffer_guard = BUFFER.lock();
    let mut result_guard = RESULT_BUFFER.lock();

    if let Some(ref data) = *buffer_guard {
        let mut reversed = data.clone();
        reversed.reverse();
        *result_guard = Some(reversed);
    } else {
        *result_guard = Some(vec![]);
    }
}

#[unsafe(no_mangle)]
pub unsafe extern "C" fn get_result_buffer_ptr() -> *const u8 {
    let guard = RESULT_BUFFER.lock();
    guard.as_ref().map(|buf| buf.as_ptr()).unwrap_or(core::ptr::null())
}

#[unsafe(no_mangle)]
pub extern "C" fn get_last_string_len() -> usize {
    let lock = LAST_STRING.lock();
    lock.as_ref().map(|s| s.len()).unwrap_or(0)
}

#[unsafe(no_mangle)]
pub extern "C" fn get_player_json() -> *const u8 {
    let player = Player { name: "creeper", level: 3 };
    let json: serde_json_core::heapless::String<256> = serde_json_core::to_string(&player).unwrap();
    let mut guard = LAST_JSON.lock();
    *guard = Some(json.parse().unwrap());
    guard.as_ref().unwrap().as_ptr()
}


#[unsafe(no_mangle)]
pub extern "C" fn get_player_json_len() -> usize {
    let guard = LAST_JSON.lock();
    guard.as_ref().map(|s| s.len()).unwrap_or(0)
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_double_stored_data() {
        let input: i32 = 21;
        let input_bytes = input.to_le_bytes();
        {
            let mut buffer_guard = BUFFER.lock();
            *buffer_guard = Some(input_bytes.to_vec());
        }
        double_stored_data();

        let result_bytes = {
            let result_guard = RESULT_BUFFER.lock();
            result_guard
                .as_ref()
                .expect("RESULT_BUFFER should be set")
                .clone()
        };
        assert_eq!(result_bytes.len(), 4);
        let result_value = i32::from_le_bytes([
            result_bytes[0],
            result_bytes[1],
            result_bytes[2],
            result_bytes[3],
        ]);
        assert_eq!(result_value, input * 2);
    }
}
