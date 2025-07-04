#[derive(serde::Serialize)]
pub struct Player {
    pub name: &'static str,
    pub level: u8,
}