use std::process::{Command, Stdio};

fn binary() -> Command {
    Command::new(env!("CARGO_BIN_EXE_lineselect"))
}

#[test]
fn test_empty_stdin_exits_successfully() {
    let output = binary()
        .stdin(Stdio::piped())
        .stdout(Stdio::piped())
        .stderr(Stdio::piped())
        .spawn()
        .unwrap()
        .wait_with_output()
        .unwrap();

    assert!(output.status.success());
    assert!(output.stdout.is_empty());
}

#[test]
fn test_version_flag() {
    let output = binary().arg("--version").output().unwrap();
    assert!(output.status.success());
    let stdout = String::from_utf8_lossy(&output.stdout);
    assert!(stdout.contains(env!("CARGO_PKG_VERSION")));
}

#[test]
fn test_help_flag() {
    let output = binary().arg("--help").output().unwrap();
    assert!(output.status.success());
    let stdout = String::from_utf8_lossy(&output.stdout);
    assert!(stdout.contains("lineselect"));
    assert!(stdout.contains("--prompt"));
    assert!(stdout.contains("--max-height"));
}

#[test]
fn test_help_shows_default_prompt() {
    let output = binary().arg("--help").output().unwrap();
    let stdout = String::from_utf8_lossy(&output.stdout);
    assert!(stdout.contains("Pick some lines"));
}
