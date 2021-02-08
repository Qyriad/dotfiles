#![feature(with_options)]

use std::env;
use std::process::Command;
use std::path::Path;
use std::fs::File;
use std::io::Write;

use anyhow::Result as AResult;
use anyhow::anyhow;


fn main() -> AResult<()>
{
    let args = env::args();
    let adjustment = args.skip(1).next().ok_or(anyhow!("Volume adjustment argument not specified."))?;

    Command::new("pactl").args(&["set-sink-volume", "@DEFAULT_SINK@", &adjustment]).spawn()?;

    let swaysock = env::var("SWAYSOCK")?;
    let mut wob_path_str = String::from(swaysock);
    wob_path_str.push_str(".wob");
    let wob_path = Path::new(&wob_path_str);

    if !wob_path.exists() {
        Command::new("swaymsg").arg("exec")
            .arg(format!("mkfifo {0} && tail -f {0}", wob_path_str))
            .spawn()?;
    }

    let processes = psutil::process::processes()?;
    if processes.into_iter().find(|process| process.as_ref().unwrap().name().unwrap() == "wob").is_none() {
        Command::new("swaymsg").arg("exec")
            .arg(format!("tail -f {} | wob", wob_path_str));
    }

    let current_vol = Command::new("pamixer").arg("--get-volume").output()?;
    let current_vol = String::from_utf8(current_vol.stdout)?;

    let mut wob = File::with_options().write(true).open(wob_path)?;
    wob.write(current_vol.as_bytes())?;

    Ok(())
}
