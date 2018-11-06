# tmux-pass [![Build Status](https://travis-ci.org/rafi/tmux-pass.svg?branch=master)](https://travis-ci.org/rafi/tmux-pass)

> Quick password-store browser with preview using fzf in tmux.

![tmux-pass preview](http://rafi.io/static/img/project/tmux-pass/preview.gif)

## Install

### Requirements
* [password-store](https://www.passwordstore.org)
* [tmux](https://github.com/tmux/tmux/wiki) 2.1+ (2.2 recommended)
* bash 4+
* [fzf](https://github.com/junegunn/fzf)

### Using [Tmux Plugin Manager](https://github.com/tmux-plugins/tpm)

Add the following to your list of TPM plugins in `~/.tmux.conf`:

```bash
set -g @plugin 'rafi/tmux-pass'
```

Hit prefix + I to fetch and source the plugin.
You should now be able to use the plugin!

### Manual

Clone the repo:

```bash
git clone https://github.com/rafi/tmux-pass ~/.tmux/plugins/tmux-pass
```

Source it in your `~/.tmux.conf`:

```bash
run-shell ~/.tmux/plugins/tmux-pass/tmux-pass.tmux
```

Reload tmux config by running:

```bash
tmux source-file ~/.tmux.conf
```

## Configuration

NOTE: for changes to take effect,
you'll need to source again your `~/.tmux.conf` file.

* [@pass-key](#pass-key)
* [@pass-copy-to-clipboard](#pass-copy-to-clipboard)
* [@pass-window-size](#pass-window-size)

### @pass-key

```
default: B
```

Customize how to display the pass browser.
Always preceded by prefix: prefix + @pass-key

For example:

```bash
set -g @pass-key b
```

### @pass-copy-to-clipboard

```
default: on
```

Copies selected password into clipboard.

For example:

```bash
set -g @pass-copy-to-clipboard on
```

### @pass-window-size

```
default: 10
```

The size of the tmux split that will be opened.

For example:

```bash
set -g @pass-window-size 10
```

## Acknowledgements

This plugin is inspired by [tmux-1password](https://github.com/yardnsm/tmux-1password).

## License

MIT
