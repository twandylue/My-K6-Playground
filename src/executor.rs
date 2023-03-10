use std::path::PathBuf;

pub struct Executor<'a> {
    pub mode: String,
    pub file: &'a PathBuf,
}

impl<'a> Executor<'a> {
    pub fn new(mode: &str, file: &'a PathBuf) -> Self {
        Executor {
            mode: mode.to_string(),
            file,
        }
    }

    pub fn execute_stress_test(&self, pod_number: i32) -> Result<(), ()> {
        let filename = self
            .file
            .as_path()
            .file_stem()
            .ok_or_else(|| eprintln!("ERROR: could not find the file: {f:?}", f = self.file))?
            .to_string_lossy();

        let output_folder_path = match self.mode.as_str() {
            "const_env" => format!("results/ConstantEnvs/{filename}_{pod_number}Pods",),
            "const_pod" => format!("results/ConstantPods/{filename}_{pod_number}Pods",),
            _ => return Err(()),
        };

        std::fs::create_dir_all(&output_folder_path).map_err(|err| {
            eprintln!("ERROR: could not carete the output folder: {output_folder_path}: {err}")
        })?;

        // TODO: get ENV file

        Ok(())
    }
}
