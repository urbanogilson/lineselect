use clap::Command;
use std::io;

fn cmd() -> clap::Command {
    Command::new("lineselect")
        .version("0.1.0")
        .author("Gilson Urbano <me@gilsonurbano.com>")
        .about("Select lines")
}

#[test]
fn verify_cmd() {
    cmd().debug_assert();
}

fn main() {
    cmd().get_matches();

    for line in io::stdin().lines() {
        println!("{}", line.unwrap());
    }
}
