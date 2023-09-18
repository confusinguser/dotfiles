#!/usr/bin/env rust-script
//! ```cargo
//! [dependencies]
//! tokio = {version = "*", features=["full"]}
//! ```
use std::process::Stdio;
use std::thread;
use std::time::Duration;

use tokio::io::{AsyncBufReadExt, BufReader};
use tokio::process::{self, ChildStdout};
use tokio::time::Instant;

#[tokio::main]
pub async fn main() -> tokio::io::Result<()> {
    const ANIMATION_STEPS: u32 = 10;
    const ANIMATION_STEP_DURATION: Duration = Duration::from_millis(23);
    let status_listener = tokio::spawn(async move {
        let stdout = run_command_async("playerctl -F status").unwrap();
        let mut buffer = BufReader::new(stdout).lines();
        let mut i = -1;
        let mut reversed_animation = false;
        loop {
            let animation_step_start = Instant::now();
            if i == -1 {
                let status = buffer.next_line().await;
                reversed_animation = false;
                if status.unwrap().unwrap() == "Paused" {
                    reversed_animation = true;
                }
                i = 0;
            }

            let mut interweave_play_pause = i as f32 / ANIMATION_STEPS as f32;
            if reversed_animation {
                interweave_play_pause = 1. - interweave_play_pause;
            }

            update(interweave_play_pause);
            i += 1;
            if i as u32 <= ANIMATION_STEPS {
                thread::sleep(
                    ANIMATION_STEP_DURATION
                        .checked_sub(Instant::now() - animation_step_start)
                        .unwrap_or_default(),
                );
            } else {
                i = -1;
            }
        }
    });
    let metadata_listener = tokio::spawn(async move {
        let mut last_update = Instant::now();
        let stdout = run_command_async("playerctl -F metadata").unwrap();
        let mut buffer = BufReader::new(stdout).lines();
        loop {
            let _ = buffer.next_line().await;
            if last_update.elapsed().as_millis() > 100 {
                let paused = run_command("playerctl status").map_or(false, |out| out == "Paused");
                update(if paused { 0. } else { 1. });
                last_update = Instant::now();
            }
        }
    });
    metadata_listener.await?;
    status_listener.await?;
    Ok(())
}

fn run_command_async(command: &str) -> Option<ChildStdout> {
    let mut command_array = command.split(' ');
    if command_array.clone().count() == 0 {
        return None;
    }

    let mut cmd = process::Command::new(command_array.next().unwrap())
        .stdout(Stdio::piped())
        .args(command_array)
        .spawn()
        .unwrap();
    cmd.stdout.take()
}

fn run_command(command: &str) -> Option<String> {
    let mut command_array = command.split(' ');
    if command_array.clone().count() == 0 {
        return Default::default();
    }

    let cmd = std::process::Command::new(command_array.next().unwrap())
        .stdout(Stdio::piped())
        .args(command_array)
        .output()
        .unwrap();

    String::from_utf8(cmd.stdout)
        .ok()
        .map(|e| e.trim().to_owned())
}

fn trim_title(title: &str, len: usize) -> String {
    let mut title = title.to_string();
    let forbidden_edge_chars = ['\"', ' ', '-', '.', '&', '(', ','];
    let mut trimmed = false;
    while title.chars().count() >= len {
        title.pop(); // For ellipsis
        trimmed = true;
    }

    if trimmed {
        while forbidden_edge_chars
            .iter()
            .any(|&forbidden| forbidden == title.chars().last().unwrap_or_default())
        {
            title.pop();
        }

        title + "…"
    } else {
        title
    }
}

fn update(interweave_play_pause: f32) {
    const TITLE_LEN_PLAYING: usize = 30;
    const TITLE_LEN_PAUSED: usize = 15;

    let mut artist = run_command("playerctl -s metadata artist").unwrap_or_default();
    artist = artist.replacen("Original Broadway Cast", "OBC", 1);
    artist = artist.replace('\"', "\\\"");
    let mut title = run_command("playerctl -s metadata title").unwrap_or_default();
    title = title.replace('\"', "\\\"");
    let paused = run_command("playerctl status").unwrap_or(String::from("Paused")) == "Paused";

    let title_trimmed_paused = trim_title(title.as_str(), TITLE_LEN_PAUSED);
    let title_trimmed_playing = trim_title(title.as_str(), TITLE_LEN_PLAYING);

    let mut text = format!("{} – {}", title_trimmed_playing, artist);
    let total_chars = text.chars().count() - title_trimmed_paused.chars().count();
    text = text
        .chars()
        .take(
            (interweave_play_pause * total_chars as f32) as usize
                + title_trimmed_paused.chars().count(),
        )
        .collect();
    if !(interweave_play_pause == 1. || title_trimmed_paused.len() == title.len()) {
        // Was trimmed
        text.pop();
        text += "…"
    }

    let mut css_class = if paused {
        "spotify-paused"
    } else {
        "spotify-playing"
    };
    if title.is_empty() && artist.is_empty() {
        css_class = "spotify-hidden";
    }

    println!("{{\"text\":\"{} \", \"class\":\"{}\"}}", text, css_class);
}
