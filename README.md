# Line Select

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

# Example

Imagine you have a list of files in a directory and you want to selectively remove them using `rm`. Instead of using a complex find command, you can utilize the Interactive Line Selector to streamline the process:

<pre>
ls | <b>lineselect</b> | xargs rm
</pre>

# Installation

## Debian

```bash
wget https://github.com/urbanogilson/lineselect/releases/download/v0.1.0/lineselect_0.1.0_amd64.deb
apt install ./lineselect_0.1.0_amd64.deb
```

# Contributions

Contributions are welcome! If you have ideas for improvements or new features, please feel free to submit a pull request.

# Acknowledgments

This project builds upon the fantastic work of the following projects:

- [Clap](https://github.com/clap-rs/clap) - A full featured, fast Command Line Argument Parser for Rust.
- [Dialoguer](https://github.com/console-rs/dialoguer) - Rust utility library for nice command line prompts and similar things.
- [Colored](https://github.com/colored-rs/colored) - Coloring terminal so simple you already know how to do it!

## Previous Implementation

This idea has been implemented before by [chfritz/lineselect](https://github.com/chfritz/lineselect) using JavaScript. Our project aims to provide an option in Rust with a single binary.

# License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
