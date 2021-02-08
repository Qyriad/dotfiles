#![feature(with_options)]

use std::env;
use std::process::Command;
use std::path::Path;
use std::fs::File;
use std::io::Write;

use anyhow::Result as AResult;
use anyhow::anyhow;


fn wob_process_exists() -> AResult<bool>
{
    let processes = psutil::process::processes()?;
    for process in processes {
        if process?.name()? == "wob" {
            return Ok(true);
        }
    }

    return Ok(false);
}


fn main() -> AResult<()>
{
    let args = env::args();
    let adjustment = args.skip(1).next().ok_or(anyhow!("Volume adjustment argument not specified."))?;
    let mut chars = adjustment.chars();
    let direction = if chars.next().unwrap() == '-' {
        "-d"
    } else {
        "-i"
    };
    let adjustment: &str = chars.as_str();
    let adjustment = &adjustment[0..adjustment.len() - 1];

    Command::new("pamixer").args(&[direction, adjustment]).spawn()?;

    let swaysock = env::var("SWAYSOCK")?;
    let mut wob_path_str = String::from(swaysock);
    wob_path_str.push_str(".wob");
    let wob_path = Path::new(&wob_path_str);

    if !wob_path.exists() {
        Command::new("swaymsg").arg("exec")
            .arg(format!("mkfifo {0} && tail -f {0}", wob_path_str))
            .spawn()?;
    }

    if !wob_process_exists().unwrap_or(false) {
        Command::new("swaymsg").arg("exec")
            .arg(format!("tail -f {} | wob", wob_path_str))
            .spawn()?;
    }

    let current_vol = Command::new("pamixer").arg("--get-volume").output()?;
    let current_vol = String::from_utf8(current_vol.stdout)?;

    let mut wob = File::with_options().write(true).open(wob_path)?;
    wob.write(current_vol.as_bytes())?;
    wob.flush()?;

    Ok(())
}
