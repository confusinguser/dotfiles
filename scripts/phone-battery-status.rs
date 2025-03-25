#!/usr/bin/env rust-script
//! ```cargo
//! [dependencies]
//! tokio = {version = "*", features=["full"]}
//! ```
use std::process::Stdio;
use std::sync::Arc;
use std::time::Duration;

use tokio::io::{AsyncBufReadExt, BufReader};
use tokio::process::{self, ChildStdout};
use tokio::sync::Mutex;
use tokio::time::Instant;

#[tokio::main]
pub async fn main() -> tokio::io::Result<()> {
    let last_change: Arc<Mutex<Instant>> = Arc::new(Mutex::new(Instant::now()));
    let charge: Arc<Mutex<Option<u32>>> = Arc::new(Mutex::new(None));
    let is_charging: Arc<Mutex<Option<bool>>> = Arc::new(Mutex::new(None));
    let has_been_too_long: Arc<Mutex<bool>> = Arc::new(Mutex::new(false));
    if let Some(starting_conditions) = get_charging_and_status() {
        update(starting_conditions.0, starting_conditions.1, false);
        *charge.lock().await = Some(starting_conditions.0);
        *is_charging.lock().await = Some(starting_conditions.1);
    }

    let last_change_clone = last_change.clone();
    let is_charging_clone = is_charging.clone();
    let has_been_too_long_clone = has_been_too_long.clone();
    let charge_clone = charge.clone();
    let battery_percentage_listener = tokio::spawn(async move {
        let stdout = run_command_async("gdbus monitor --session --dest org.kde.kdeconnect --object-path /modules/kdeconnect/devices/2a9d4d71_3d40_4920_b5ee_527f4315703d/battery").unwrap();
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
            let Ok(charge_local) = data.1.parse::<u32>() else {continue;};
            let Ok(is_charging_local) = data.0.parse::<bool>() else {continue;};
            *charge_clone.lock().await = Some(charge_local);
            *is_charging_clone.lock().await = Some(is_charging_local);
            *last_change_clone.lock().await = Instant::now();
            *has_been_too_long_clone.lock().await = false;

            update(charge_local, is_charging_local, false);
        }
    });

    let is_charging_clone = is_charging.clone();
    let last_change_clone = last_change.clone();
    let has_been_too_long_clone = has_been_too_long.clone();
    let charge_clone = charge.clone();
    let has_been_too_long_checker = tokio::spawn(async move {
        let mut sleep_until = Instant::now();
        loop {
            tokio::time::sleep({
                let diff: Duration = sleep_until - Instant::now();
                if diff.is_zero() {
                    Duration::from_secs(60)
                } else {
                    diff
                }
            })
            .await;

            let last_change = *last_change_clone.lock().await;
            sleep_until = last_change + Duration::from_secs(120);
            let Some(is_charging) = *is_charging_clone.lock().await else {continue;};
            let mut has_been_too_long = false;

            if is_charging {
                has_been_too_long = Instant::now() - last_change > Duration::from_secs(120);
                *has_been_too_long_clone.lock().await = has_been_too_long;
            }
            if has_been_too_long {
                let Some(charge) = *charge_clone.lock().await else {continue;};
                update(charge, is_charging, has_been_too_long);
            }
        }
    });
    let is_connected_listener = tokio::spawn(async move {});
    battery_percentage_listener.await?;
    has_been_too_long_checker.await?;
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

fn update(charge: u32, is_charging: bool, has_been_too_long: bool) {
    let css_class = if has_been_too_long {
        "has_been_too_long"
    } else if is_charging {
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
    if charge.len() <= 6 {
        return None;
    }
    let Ok(charge) = charge[2..charge.len() - 3].parse::<u32>() else {return None;};

    let Some(is_charging) = run_command("gdbus call --session --dest org.kde.kdeconnect --object-path /modules/kdeconnect/devices/4eb553e1_dca2_40d6_a0f7_3123cf4d641c/battery --method org.freedesktop.DBus.Properties.Get org.kde.kdeconnect.device.battery isCharging") else {return None};
    let Ok(is_charging) = is_charging[2..is_charging.len() - 3].parse::<bool>() else {return None;};
    Some((charge, is_charging))
}
