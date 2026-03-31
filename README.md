# Line Select

[![CI](https://github.com/urbanogilson/lineselect/actions/workflows/rust.yml/badge.svg?branch=main)](https://github.com/urbanogilson/lineselect/actions/workflows/rust.yml)
[![Crates.io](https://img.shields.io/crates/v/lineselect.svg)](https://crates.io/crates/lineselect)
[![CI](https://img.shields.io/badge/License-MIT-blue.svg)](https://github.com/urbanogilson/lineselect/blob/main/LICENSE)

Elevate your command-line pipelines using the Interactive Line Selector – a potent utility enabling interactive line selection from stdin. Seamlessly integrate, pause, select, and refine your pipeline, enhancing data processing precision.

# Features
- Interactive Selection: Pause the pipeline's execution to manually select specific lines from the input stream.
- Seamless Integration: Easily integrate the Interactive Line Selector into your existing command-line pipelines.
- Optimized Workflow: Curate data on-the-fly for more accurate and meaningful results.

# Usage

Incorporate the Interactive Line Selector into your pipeline:

<pre>
&lt;command producing input&gt; | <b>lineselect</b> | &lt;subsequent command&gt;
</pre>

Use arrow keys to navigate, press `Space` to select/deselect lines, and press `Enter` to proceed with the selected lines.

## Options

| Option | Short | Description | Default |
|---|---|---|---|
| `--prompt <TEXT>` | `-p` | Custom prompt text | `Pick some lines` |
| `--max-height <N>` | | Maximum number of lines to display at once | (all lines) |
| `--version` | `-V` | Print version | |
| `--help` | `-h` | Print help | |

## Exit Codes

| Code | Meaning |
|---|---|
| `0` | Lines selected and printed, or empty input |
| `1` | User cancelled (Esc or Ctrl+C) |

# Example

Imagine you have a list of files in a directory and you want to selectively remove them using `rm`. Instead of using a complex find command, you can utilize the Interactive Line Selector to streamline the process:

<pre>
ls | <b>lineselect</b> | xargs rm
</pre>

![Example](https://github.com/urbanogilson/lineselect/blob/main/.github/example.gif)

Use a custom prompt to make scripts more descriptive:

```bash
git branch | lineselect --prompt "Pick branches to delete" | xargs git branch -d
```

Limit the visible lines when working with large inputs:

```bash
cat large_file.txt | lineselect --max-height 10 | xargs process
```

Check the exit code to detect cancellation in scripts:

```bash
if ! selected=$(ls | lineselect); then
  echo "Selection cancelled"
fi
```

# Installation

## Cargo (Linux, Mac, Windows)

```bash
cargo install lineselect
```

## Debian / Ubuntu

Download the `.deb` for your architecture from the [latest release](https://github.com/urbanogilson/lineselect/releases/latest) and install it:

```bash
apt install ./lineselect_*.deb
```

## RPM (Fedora / RHEL / openSUSE)

Download the `.rpm` for your architecture from the [latest release](https://github.com/urbanogilson/lineselect/releases/latest) and install it:

```bash
rpm -i lineselect-*.rpm
```

# Contributions

Contributions are welcome! If you have ideas for improvements or new features, please feel free to submit a pull request.

# Acknowledgments

This project builds upon the fantastic work of the following projects:

- [Clap](https://github.com/clap-rs/clap) - A full featured, fast Command Line Argument Parser for Rust.
- [Dialoguer](https://github.com/console-rs/dialoguer) - Rust utility library for nice command line prompts and similar things.

## Previous Implementation

This idea has been implemented before by [chfritz/lineselect](https://github.com/chfritz/lineselect) using JavaScript. Our project aims to provide an option in Rust with a single binary.

# License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
