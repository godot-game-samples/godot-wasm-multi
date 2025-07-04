#[derive(serde::Serialize, serde::Deserialize)]
pub struct Player {
    pub name: String,
    pub level: u8,
}