pub mod player;
use crate::player::Player;
use spin::Mutex;
use lazy_static::lazy_static;

lazy_static! {
    static ref LAST_STRING: Mutex<Option<String>> = Mutex::new(None);
    static ref BUFFER: Mutex<Option<Vec<u8>>> = Mutex::new(None);
    static ref LAST_JSON: Mutex<Option<String>> = Mutex::new(None);
}

#[unsafe(no_mangle)]
pub extern "C" fn get_last_string_len() -> usize {
    let lock = LAST_STRING.lock();
    lock.as_ref().map(|s| s.len()).unwrap_or(0)
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