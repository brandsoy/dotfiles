# My Neovim

## Notes

Blink.cmp rust fuzzy finder matcher thing is complaining.

# Install rustup if not installed

curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

# Use nightly

rustup default nightly

# Add Rust source (required for some builds)

rustup component add rust-src

Went into /home/mattis/.local/share/nvim/site/pack/core/opt/blink.cmp
And ran : cargo build --release
