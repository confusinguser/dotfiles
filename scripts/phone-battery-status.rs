#!/usr/bin/env rust-script
//! ```cargo
//! [dependencies]
//! tokio = {version = "*", features=["full"]}
//! ```
use std::process::Stdio;

use tokio::io::{AsyncBufReadExt, BufReader};
use tokio::process::{self, ChildStdout};

#[tokio::main]
pub async fn main() -> tokio::io::Result<()> {
    if let Some(starting_conditions) = get_charging_and_status() {
        update(starting_conditions.0, starting_conditions.1);
    }

    let battery_percentage_listener = tokio::spawn(async move {
        let stdout = run_command_async("gdbus monitor --session --dest org.kde.kdeconnect --object-path /modules/kdeconnect/devices/4eb553e1_dca2_40d6_a0f7_3123cf4d641c/battery").unwrap();
        let mut buffer = BufReader::new(stdout).lines();
        loop {
            let line = buffer
                .next_line()
                .await
                .unwrap_or_default()
                .unwrap_or_default();
            if line.is_empty() {
                continue;
            }

            let Some(split) = line.split_once('(') else {continue;};
            let data = &split.1[..split.1.len() - 1];
            let Some(data) = data.split_once(", ") else {continue;};
            let Ok(charge) = data.1.parse::<u32>() else {continue;};
            let Ok(is_charging) = data.0.parse::<bool>() else {continue;};
            update(charge, is_charging);
        }
    });
    battery_percentage_listener.await?;
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

fn update(charge: u32, is_charging: bool) {
    let css_class = if is_charging {
        "charging"
    } else {
        "discharging"
    };
    let icon = if is_charging {
        match charge / 10 {
            0 => '󰢟',
            1 => '󰢜',
            2 => '󰂆',
            3 => '󰂇',
            4 => '󰂈',
            5 => '󰢝',
            6 => '󰂉',
            7 => '󰢞',
            8 => '󰂊',
            9 => '󰂋',
            10 => '󰂅',
            _ => '󰂑',
        }
    } else {
        match charge / 10 {
            0 => '󰂎',
            1 => '󰁺',
            2 => '󰁻',
            3 => '󰁼',
            4 => '󰁽',
            5 => '󰁾',
            6 => '󰁿',
            7 => '󰂀',
            8 => '󰂁',
            9 => '󰂂',
            10 => '󰁹',
            _ => '󰂑',
        }
    };

    println!(
        "{{\"text\":\"{} {}%\", \"class\":\"{}\"}}",
        icon, charge, css_class
    );
}

fn get_charging_and_status() -> Option<(u32, bool)> {
    let Some(charge) = run_command("gdbus call --session --dest org.kde.kdeconnect --object-path /modules/kdeconnect/devices/4eb553e1_dca2_40d6_a0f7_3123cf4d641c/battery --method org.freedesktop.DBus.Properties.Get org.kde.kdeconnect.device.battery charge") else {return None};
    let Ok(charge) = charge[2..charge.len() - 3].parse::<u32>() else {return None;};

    let Some(is_charging) = run_command("gdbus call --session --dest org.kde.kdeconnect --object-path /modules/kdeconnect/devices/4eb553e1_dca2_40d6_a0f7_3123cf4d641c/battery --method org.freedesktop.DBus.Properties.Get org.kde.kdeconnect.device.battery isCharging") else {return None};
    let Ok(is_charging) = is_charging[2..is_charging.len() - 3].parse::<bool>() else {return None;};
    Some((charge, is_charging))
}
