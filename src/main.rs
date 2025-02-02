use clap::Command;
use colored::Colorize;
use dialoguer::{console::Term, theme::SimpleTheme, MultiSelect};
use std::io;

fn cmd() -> clap::Command {
    let name = "lineselect";

    Command::new(name)
        .override_usage(format!(
            "<command producing input> | {} | <subsequent command>",
            name.bold()
        ))
        .version("0.1.1")
        .author("Gilson Urbano <me@gilsonurbano.com>")
        .about("Select lines")
}

fn read_lines<R: io::BufRead>(reader: R) -> Vec<String> {
    let mut lines = Vec::new();

    for line in reader.lines() {
        match line {
            Ok(line) => lines.push(line),
            Err(error) => {
                eprintln!("Error: {}", error);
                break;
            }
        }
    }

    lines
}

fn main() -> Result<(), Box<dyn std::error::Error>> {
    cmd().get_matches();

    let stdin = io::stdin();

    let lines = read_lines(stdin.lock());

    if let Some(positions) = MultiSelect::with_theme(&SimpleTheme)
        .with_prompt(format!("{} {}", "?".red().bold(), "Pick some lines".bold()))
        .report(false)
        .items(&lines)
        .interact_on_opt(&Term::stderr())?
    {
        positions
            .iter()
            .for_each(|position| println!("{}", lines[*position]));
    }

    Ok(())
}

#[test]
fn test_cmd() {
    cmd().debug_assert();
}

#[test]
fn test_read_lines() {
    use std::io::Cursor;
    let input = "Line 1\nLine 2\nLine 3\n";
    let reader = Cursor::new(input);

    let lines = read_lines(reader);

    assert_eq!(lines.len(), 3);
    assert_eq!(lines[0], "Line 1");
    assert_eq!(lines[1], "Line 2");
    assert_eq!(lines[2], "Line 3");
}
