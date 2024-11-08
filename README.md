# Zed for Windows (Unofficial)

This repository contains unofficial builds of [Zed](https://github.com/zed-industries/zed) for Windows.

***Disclaimer**: These builds may break at any time as they are not officially supported by Zed Industries.*

These releases are transparently built against the latest release tag of Zed using Github Actions.

## Builds

| Channel | Workflow Status | Latest Release | Remarks |
| ------- | ------ | -------------- | -------- |
| Stable | [![Stable](https://github.com/xarunoba/zed-windows/actions/workflows/stable.yml/badge.svg)](https://github.com/xarunoba/zed-windows/actions/workflows/stable.yml) | [![Stable Release](https://img.shields.io/github/v/release/xarunoba/zed-windows?sort=date&filter=v*&logo=zedindustries)](https://github.com/xarunoba/zed-windows/releases/latest) | Built against the [latest](https://github.com/zed-industries/zed/releases/latest) release tag of Zed (Checked every 3 hours) |
| Preview | [![Preview](https://github.com/xarunoba/zed-windows/actions/workflows/preview.yml/badge.svg)](https://github.com/xarunoba/zed-windows/actions/workflows/preview.yml) | [![Preview Release](https://img.shields.io/github/v/release/xarunoba/zed-windows?sort=date&filter=*-pre*&logo=zedindustries)](https://github.com/xarunoba/zed-windows/releases?q=*-pre&expanded=true) | Built against the [pre-release](https://github.com/zed-industries/zed/releases?q=*-pre&expanded=true) tag of Zed (Checked every 3 hours) |
| Nightly | [![Nightly](https://github.com/xarunoba/zed-windows/actions/workflows/nightly.yml/badge.svg)](https://github.com/xarunoba/zed-windows/actions/workflows/nightly.yml) | [![Nightly Release](https://img.shields.io/github/v/release/xarunoba/zed-windows?sort=date&filter=*-nightly&logo=zedindustries)](https://github.com/xarunoba/zed-windows/releases?q=*-nightly&expanded=true) | Built against the [nightly](https://github.com/zed-industries/zed/releases/tag/nightly) release tag of Zed (Checked every 11 AM UTC, 4 hours after Zed releases a new nightly) |
## Features

- Builds for Vulkan and OpenGL ES (OpenGL ES may or may not work as it is barely supported by Zed)
- Auto-updater is properly disabled for these builds using the `ZED_UPDATE_EXPLANATION` environment variable
- Uses proper release channels for Zed via `crates/zed/RELEASE_CHANNEL`

## Usage

Download the latest release from the [Releases](https://github.com/xarunoba/zed-windows/releases) page.

Extract the contents of the archive to a folder of your choice.

Run the `zed.exe` executable.

## Is this safe?

Yes, this is safe. There are no changes to the official Zed codebase as seen in the GitHub Actions builds.

### Windows Defender is complaining about the executable

This is a false positive. See [this issue](https://github.com/zed-industries/zed/issues/14789) for more information.