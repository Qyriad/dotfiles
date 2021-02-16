use std::os::unix;
use std::fs::File;
use std::process::{Command, Stdio};

use anyhow::Result as AResult;
use anyhow::anyhow;

use gtk::RecentManagerExt as _;


fn add_filename_to_gtk_recents(filename: &str) -> AResult<()>
{
    gtk::init()?;

    let recent_manager = gtk::RecentManager::get_default()
        .ok_or(anyhow!("Failed to get default recent manager."))?;

    let succeeded = recent_manager.add_item(&filename);

    if !succeeded {
        return Err(anyhow!("Failed to add item to recent manager."));
    }

    //glib::idle_add_local(|| { gtk::main_quit(); glib::source::Continue(false) });
    gtk::main();

    Ok(())
}


fn main() -> AResult<()>
{
    let now = chrono::offset::Local::now();
    let now = now.format("%Y-%m-%d %H-%M-%S");
    let filename = format!("/home/qyriad/Screenshots/Screenshot_from_{}.png", now);

    let output = Command::new("grimshot").args(&["save", "area", &filename])
        .output()?;


    if !output.stderr.is_empty() {
        print!("{}", String::from_utf8_lossy(&output.stderr));
        return Ok(());
    }


    println!("Filename: {}", &filename);
    // Add the screenshot file to GTK's recent files.
    add_filename_to_gtk_recents(&filename)?;

    // Create a symlink as /tmp/screenshot.png.
    //let _ = std::fs::remove_file("/tmp/screenshot.png");
    //unix::fs::symlink(&filename, "/tmp/screenshot.png")?;

    Command::new("wl-copy")
        .stdin(Stdio::from(File::open(filename)?))
        .spawn()?
        .wait()?;
    //let mut stdin = wl_copy.stdin.take().unwrap();
    //stdin.write(filename.as_bytes())?;

    //return Ok(());

    //gtk::init()?;

    //let recent_manager = gtk::RecentManager::get_default()
        //.ok_or(anyhow!("Failed to get recent manager."))?;

    ////let succeeded = recent_manager.add_item("/home/qyriad/Pictures/2021-02-08T14:31:31,052788452-07:00.png");
    //let succeeded = recent_manager.add_item("/home/qyriad/Pictures/2021-02-08T14:56:03,624588424-07:00.png");
    //dbg!(succeeded);

    //if succeeded {
        //glib::idle_add_local(|| { gtk::main_quit(); glib::source::Continue(false) } );
        //gtk::main();
    //}

    //let items = recent_manager.get_items();
    //for item in items {
        ////dbg!(item.get_uri()?);
        //let uri = item.get_uri().unwrap();
        //dbg!(uri);
    //}

    Ok(())
}
