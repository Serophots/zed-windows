# Zed for Windows (Unofficial)

[![Stable](https://github.com/xarunoba/zed-windows/actions/workflows/stable.yml/badge.svg)](https://github.com/xarunoba/zed-windows/actions/workflows/stable.yml)
[![Nightly](https://github.com/xarunoba/zed-windows/actions/workflows/nightly.yml/badge.svg)](https://github.com/xarunoba/zed-windows/actions/workflows/nightly.yml)

This repository contains unofficial builds of [Zed](https://github.com/zed-industries/zed) for Windows.

***Disclaimer**: These builds may break at any time as they are not officially supported by Zed Industries.*

These releases are transparently built against the latest release tag of Zed using Github Actions.

## Features

- Has two release channels: Stable and Nightly
  - Stable releases are built against the latest release tag of Zed and is checked every 3 hours
  - Nightly releases are built against the nightly release tag of Zed and is built and checked every 11 AM UTC (4 hours after Zed releases a new nightly)
- Builds for Vulkan and OpenGL ES (OpenGL ES may have more issues than Vulkan)

## Usage

Download the latest release from the [Releases](https://github.com/xarunoba/zed-windows/releases) page.

Extract the contents of the archive to a folder of your choice.

Run the `zed.exe` executable.
