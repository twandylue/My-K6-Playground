use crate::models::env::Env;
use std::{
    fs,
    path::{Path, PathBuf},
    process::Command,
};

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
        let parent_file_path = self.file.as_path().parent().unwrap_or(Path::new("./"));

        let filename = self
            .file
            .as_path()
            .file_stem()
            .ok_or_else(|| eprintln!("ERROR: could not find the file: {f:?}", f = self.file))?
            .to_string_lossy();

        let mut env_filename = filename.clone().to_string();
        env_filename.push_str("ENVs.json");

        let env_filename = parent_file_path
            .join(env_filename.as_str())
            .to_string_lossy()
            .to_string();

        let env_file = fs::File::open(&env_filename).map_err(|err| {
            eprintln!("ERROR: could not read the env file: {env_filename}: {err}")
        })?;

        let envs: Vec<Env> = serde_json::from_reader(env_file).map_err(|err| {
            eprintln!("ERROR: could not deserialize the env file: {env_filename}: {err}")
        })?;

        let output_folder_path = match self.mode.as_str() {
            "const_env" => format!("results/ConstantEnvs/{filename}_{pod_number}Pods",),
            "const_pod" => format!("results/ConstantPods/{filename}_{pod_number}Pods",),
            _ => return Err(()),
        };

        std::fs::create_dir_all(&output_folder_path).map_err(|err| {
            eprintln!("ERROR: could not carete the output folder: {output_folder_path}: {err}")
        })?;

        for i in 0..envs.len() {
            let cmd = Self::gen_cmd(&self, &envs[i], &output_folder_path, i + 1, pod_number)?;

            println!("{cmd}");

            // TODO: execute
            // let output = Command::new(cmd).output().expect("test");
            // let output = output.stdout;
        }

        Ok(())
    }

    /// Returns a command in k6.
    /// k6 run --summary-export `summary_export.json` `script_file.json` --env RATE=`rate` --env DURATION=`duration` --env PREALLOCATEDVUS=`vus` --env MAXVUS=`vus`
    /// # Examples
    /// ```
    /// k6 run --summary-export results/ConstantPods/CreateTasksWithKey_1Pods/1_summary_1Pods_R1_D10s_P200_M300.json ./scripts/ConstantPods/CreateTasksWithKey.js --env RATE=1 --env DURATION=10s --env PREALLOCATEDVUS=200 --env MAXVUS=300
    /// ``
    fn gen_cmd(
        &self,
        env: &Env,
        output_folder_path: &str,
        round: usize,
        pod_number: i32,
    ) -> Result<String, ()> {
        let summary_report_name = format!(
            "{round}_summary_{pod_number}Pods_R{rate}_D{duration}_P{preallocatedvus}_M{maxvus}.json",
            rate = env.rate,
            duration = env.duration,
            preallocatedvus = env.preallocatedvus,
            maxvus = env.maxvus
        );

        let output_summary_path = Path::new(output_folder_path).join(summary_report_name);

        let cmd = format!("k6 run --summary-export {output_summary_path} {script_file} --env RATE={rate} --env DURATION={duration} --env PREALLOCATEDVUS={preallocatedvus} --env MAXVUS={maxvus}", 
            output_summary_path = output_summary_path.display(),
            script_file = &self.file.display(),
            rate = env.rate,
            duration = env.duration,
            preallocatedvus = env.preallocatedvus,
            maxvus = env.maxvus
        );

        Ok(cmd)
    }
}

#[cfg(test)]
mod tests {
    use super::Executor;
    use crate::models::env::Env;
    use std::path::PathBuf;

    #[test]
    fn gen_cmd_ok() -> Result<(), ()> {
        // arrange
        let script_file = PathBuf::from("./scripts/GetTaskById.js".to_string());
        let exe = Executor::new("const_pod", &script_file);
        let env = Env {
            rate: 3000,
            duration: "30s".to_string(),
            preallocatedvus: 3000,
            maxvus: 3000,
        };
        let output_folder_path = "results/ConstantPods/GetTaskById_1Pods";
        let round: usize = 1;
        let pod_number = 1;

        let expected = "k6 run --summary-export results/ConstantPods/GetTaskById_1Pods/1_summary_1Pods_R3000_D30s_P3000_M3000.json ./scripts/GetTaskById.js --env RATE=3000 --env DURATION=30s --env PREALLOCATEDVUS=3000 --env MAXVUS=3000";

        // act
        let actual = exe.gen_cmd(&env, &output_folder_path, round, pod_number)?;

        // arrange
        assert_eq!(expected, actual);

        Ok(())
    }
}
