#!/usr/bin/env rust-script
//! ```cargo
//! [dependencies]
//! tokio = {version = "*", features=["full"]}
//! busrt = {version = "*", features=["ipc"]}
//! ```

use std::env::Args;

// Client demo (listener)
use busrt::client::AsyncClient;
use busrt::ipc::{Client, Config};
use busrt::QoS;

enum Operation {
    ChangeBrightness(i8),
    SetBrightness(u8),
    GetBrightness,
}

#[tokio::main]
async fn main() -> Result<(), Box<dyn std::error::Error>> {
    tokio::spawn(async { listener().await.expect("TODO: panic message"); });
    Ok(())
}

impl Operation {
    fn parse(mut args: Args) -> Option<Operation> {
        match args.next()?.as_str() {
            "change" => {
                let brightness = args.next()?.parse().ok()?;
                Some(Operation::ChangeBrightness(brightness))
            }
            "set" => {
                let brightness = args.next()?.parse().ok()?;
                Some(Operation::SetBrightness(brightness))
            }
            "get" => Some(Operation::GetBrightness),
            _ => None,
        }
    }
}

async fn sender() -> Result<(), Box<dyn std::error::Error>> {
    let name = "sender";
    let args: String = std::env::args().skip(1).fold(String::new(), |acc, arg| acc + " " + &arg);

    // create a new client instance
    let config = Config::new("/tmp/backlight.sock", name);
    let mut client = Client::connect(&config).await?;

    // publish to a topic
    let opc = client
        .send_broadcast("backlight", args.as_bytes().into(), QoS::Processed)
        .await?
        .expect("no op");
    opc.await??;
    Ok(())
}


async fn listener() -> Result<(), Box<dyn std::error::Error>> {
    let name = "test.client.listener";
    // create a new client instance
    let config = Config::new("/tmp/backlight.sock", name);
    let mut client = Client::connect(&config).await?;
    // subscribe to all topics
    let opc = client.subscribe("#", QoS::Processed).await?.expect("no op");
    opc.await??;
    // handle incoming frames
    let rx = client.take_event_channel().unwrap();
    while let Ok(frame) = rx.recv().await {
        println!(
            "Frame from {}: {:?} {:?} {}",
            frame.sender(),
            frame.kind(),
            frame.topic(),
            std::str::from_utf8(frame.payload()).unwrap_or("something unreadable")
        );
    }
    Ok(())
}