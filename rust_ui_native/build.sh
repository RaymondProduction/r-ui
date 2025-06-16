#!/bin/sh
mkdir -p ~/dev/cargo-cache
export CARGO_HOME=~/dev/cargo-cache
cargo run
