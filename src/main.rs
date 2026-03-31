use clap::{Arg, Command};
use dialoguer::{
    console::{style, Term},
    theme::SimpleTheme,
    MultiSelect,
};
use std::io;

fn cmd() -> Command {
    let name = "lineselect";

    Command::new(name)
        .override_usage(format!(
            "<command producing input> | {} | <subsequent command>",
            style(name).bold()
        ))
        .version(env!("CARGO_PKG_VERSION"))
        .author(env!("CARGO_PKG_AUTHORS"))
        .about(env!("CARGO_PKG_DESCRIPTION"))
        .arg(
            Arg::new("prompt")
                .long("prompt")
                .short('p')
                .value_name("TEXT")
                .help("Custom prompt text")
                .default_value("Pick some lines"),
        )
        .arg(
            Arg::new("max-height")
                .long("max-height")
                .value_name("N")
                .help("Maximum number of lines to display at once")
                .value_parser(clap::value_parser!(usize)),
        )
}

fn read_lines<R: io::BufRead>(reader: R) -> Vec<String> {
    let mut lines = Vec::new();

    for line in reader.lines() {
        match line {
            Ok(line) => lines.push(line),
            Err(error) => {
                eprintln!("Error reading line: {}", error);
                continue;
            }
        }
    }

    lines
}

fn main() -> Result<(), Box<dyn std::error::Error>> {
    let matches = cmd().get_matches();

    let prompt = matches.get_one::<String>("prompt").unwrap();
    let max_height = matches.get_one::<usize>("max-height").copied();

    let stdin = io::stdin();
    let lines = read_lines(stdin.lock());

    if lines.is_empty() {
        return Ok(());
    }

    let selector = MultiSelect::with_theme(&SimpleTheme)
        .with_prompt(format!(
            "{} {}",
            style("?").red().bold(),
            style(prompt.as_str()).bold()
        ))
        .report(false)
        .items(&lines);

    let selector = if let Some(height) = max_height {
        selector.max_length(height)
    } else {
        selector
    };

    if let Some(positions) = selector.interact_on_opt(&Term::stderr())? {
        positions
            .iter()
            .for_each(|position| println!("{}", lines[*position]));
    } else {
        std::process::exit(1);
    }

    Ok(())
}

#[cfg(test)]
mod tests {
    use super::*;
    use std::io::Cursor;

    #[test]
    fn test_cmd() {
        cmd().debug_assert();
    }

    #[test]
    fn test_read_lines() {
        let input = "Line 1\nLine 2\nLine 3\n";
        let lines = read_lines(Cursor::new(input));
        assert_eq!(lines.len(), 3);
        assert_eq!(lines[0], "Line 1");
        assert_eq!(lines[1], "Line 2");
        assert_eq!(lines[2], "Line 3");
    }

    #[test]
    fn test_read_lines_empty() {
        let lines = read_lines(Cursor::new(""));
        assert!(lines.is_empty());
    }

    #[test]
    fn test_read_lines_single_line() {
        let lines = read_lines(Cursor::new("only line\n"));
        assert_eq!(lines.len(), 1);
        assert_eq!(lines[0], "only line");
    }

    #[test]
    fn test_read_lines_no_trailing_newline() {
        let lines = read_lines(Cursor::new("Line 1\nLine 2"));
        assert_eq!(lines.len(), 2);
        assert_eq!(lines[0], "Line 1");
        assert_eq!(lines[1], "Line 2");
    }

    #[test]
    fn test_read_lines_blank_lines_preserved() {
        let lines = read_lines(Cursor::new("Line 1\n\nLine 3\n"));
        assert_eq!(lines.len(), 3);
        assert_eq!(lines[0], "Line 1");
        assert_eq!(lines[1], "");
        assert_eq!(lines[2], "Line 3");
    }

    #[test]
    fn test_read_lines_whitespace_only_preserved() {
        let lines = read_lines(Cursor::new("  \n\t\n   spaces   \n"));
        assert_eq!(lines.len(), 3);
        assert_eq!(lines[0], "  ");
        assert_eq!(lines[1], "\t");
        assert_eq!(lines[2], "   spaces   ");
    }

    #[test]
    fn test_read_lines_unicode() {
        let lines = read_lines(Cursor::new("日本語\nEmoji 🦀\nCafé\n"));
        assert_eq!(lines.len(), 3);
        assert_eq!(lines[0], "日本語");
        assert_eq!(lines[1], "Emoji 🦀");
        assert_eq!(lines[2], "Café");
    }
}
