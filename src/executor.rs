pub struct Executor {
    pub mode: String,
    pub file: String,
}

impl Executor {
    pub fn new(mode: &str, file: &str) -> Self {
        Executor {
            mode: mode.to_string(),
            file: file.to_string(),
        }
    }

    pub fn execute_stress_test(&self, pod_number: i32) -> Result<(), ()> {
        let output_foler_path = match self.mode.as_str() {
            // TODO: check relative path
            "const_env" => format!(
                "../../Results/ConstantEnvs/{file}_{pod_number}Pods",
                file = self.file.clone()
            ),
            "const_pod" => format!(
                "../../Results/ConstantPods/{file}_{pod_number}Pods",
                file = self.file.clone()
            ),
            _ => return Err(()),
        };

        std::fs::create_dir_all(&output_foler_path)
            .map_err(|err| eprintln!("ERROR: could not carete output folder: {err}"))?;

        Ok(())
    }
}
