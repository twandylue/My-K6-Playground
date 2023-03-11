use serde::{Deserialize, Serialize};

#[derive(Clone, Debug, PartialEq, Eq, Deserialize, Serialize)]
#[serde(rename_all(deserialize = "UPPERCASE"))]
pub struct Env {
    pub rate: i32,
    pub duration: String,
    pub preallocatedvus: i32,
    pub maxvus: i32,
}
