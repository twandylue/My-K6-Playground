use std::{
    env,
    path::{Path, PathBuf},
    process::{exit, ExitCode},
};

use executor::Executor;

mod executor;

fn main() -> ExitCode {
    match entry() {
        Ok(()) => ExitCode::SUCCESS,
        Err(()) => ExitCode::FAILURE,
    }
}

fn entry() -> Result<(), ()> {
    let mut args = env::args();
    let program = args.next().expect("path to program doesn't be provided.");
    let mut subcommand: Option<String> = None;
    if let Some(arg) = args.next() {
        match arg.as_str() {
            "h | help" => {
                usage(&program);
                exit(0)
            }
            _ => subcommand = Some(arg),
        }
    }

    let subcommand = subcommand.ok_or_else(|| {
        usage(&program);
        eprintln!("ERROR: no subcommand is provided.")
    })?;

    match subcommand.as_str() {
        "cal" => todo!(),
        "stress-test" => {
            let mode = args.next();
            let mode = mode.ok_or_else(|| {
                usage(&program);
                eprintln!("ERROR: no mode is provided.");
            })?;

            let script_file = args.next();
            let script_file = script_file.ok_or_else(|| {
                usage(&program);
                eprintln!("ERROR: no script file is provided.");
            })?;

            if !Path::new(&script_file).exists() {
                eprintln!("ERROR: script file: {script_file} does not exist.");
                return Err(());
            }
            let script_file = PathBuf::from(&script_file);

            let pod_number = args.next();
            let pod_number = match pod_number {
                Some(p) => p.parse::<i32>().map_err(|err| {
                    eprintln!("ERROR: could not convert pod_number to number(int): {err}")
                })?,
                None => 1_i32,
            };

            let executor = Executor::new(&mode, &script_file);

            executor.execute_stress_test(pod_number)?;
        }
        _ => {
            usage(&program);
            eprintln!("ERROR: unknown subcommand: {subcommand}")
        }
    }

    Ok(())
}

fn usage(program: &str) {
    eprintln!("Usage: {program} [SUBCOMMAND] [OPTIONS]");
    eprintln!("Subcommands and options:");
    eprintln!("     stress-test <mode> <file> [pod number]      execute stress test according script <file> under <mode> as [pod number] pods in target.");
    eprintln!("     cal <folder>                                calculate the summary report of stress test results in <folder>");
    eprintln!();
    eprintln!("     <mode> -- const_pod     client with various envs(settings) and target with constant pods");
    eprintln!("            -- const_env     client with the same envs(settings) and target with various pods");
}
