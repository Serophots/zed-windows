# Zed for Windows (Unofficial)

**2025-24-2: I'm archiving this as this as I have moved back to my previous code editor as there have been a lot of issues regarding LSPs being broken and what not making me unproductive with Zed. I will come back when things get stable and as of now, unfortunately I have to archive this repository. Feel free to fork this as you want, no problem. :)**

This repository contains unofficial builds of [Zed](https://github.com/zed-industries/zed) for Windows.

***Disclaimer**: These builds may break at any time as they are not officially supported by Zed Industries.*

These releases are transparently built against the latest release tag of Zed using Github Actions.

## Builds

| Channel | Workflow Status | Latest Release | Remarks |
| ------- | ------ | -------------- | -------- |
| Stable | [![Stable](https://img.shields.io/github/actions/workflow/status/xarunoba/zed-windows/stable.yml?logo=github)](https://github.com/xarunoba/zed-windows/actions/workflows/stable.yml) | [![Stable Release](https://img.shields.io/github/v/release/xarunoba/zed-windows?sort=date&filter=v*&logo=zedindustries)](https://github.com/xarunoba/zed-windows/releases/latest) | Built against the [latest](https://github.com/zed-industries/zed/releases/latest) release tag of Zed (Checked every 3 hours) |
| Preview | [![Preview](https://img.shields.io/github/actions/workflow/status/xarunoba/zed-windows/preview.yml?logo=github)](https://github.com/xarunoba/zed-windows/actions/workflows/preview.yml) | [![Preview Release](https://img.shields.io/github/v/release/xarunoba/zed-windows?sort=date&filter=*-pre*&logo=zedindustries)](https://github.com/xarunoba/zed-windows/releases?q=*-pre&expanded=true) | Built against the [pre-release](https://github.com/zed-industries/zed/releases?q=*-pre&expanded=true) tag of Zed (Checked every 3 hours) |
| Nightly | [![Nightly](https://img.shields.io/github/actions/workflow/status/xarunoba/zed-windows/nightly.yml?logo=github)](https://github.com/xarunoba/zed-windows/actions/workflows/nightly.yml) | [![Nightly Release](https://img.shields.io/github/v/release/xarunoba/zed-windows?sort=date&filter=*-nightly&logo=zedindustries)](https://github.com/xarunoba/zed-windows/releases?q=*-nightly&expanded=true) | Built against the [nightly](https://github.com/zed-industries/zed/releases/tag/nightly) release tag of Zed (Checked every 11 AM UTC, 4 hours after Zed releases a new nightly) |
## Features

- Builds for Vulkan and OpenGL ES (OpenGL ES may or may not work as it is barely supported by Zed)
- Auto-updater is properly disabled for these builds using the `ZED_UPDATE_EXPLANATION` environment variable
- Uses proper release channels for Zed via `crates/zed/RELEASE_CHANNEL`

## Installation & Usage

### Scripts

You can install Zed via PowerShell:
(You can also use this script to update Zed if it has been installed previously using the install script)
```
irm https://raw.githubusercontent.com/xarunoba/zed-windows/refs/heads/main/install.ps1 | iex
```

Or if you want to uninstall Zed that has been installed via the install script:
```
irm https://raw.githubusercontent.com/xarunoba/zed-windows/refs/heads/main/uninstall.ps1 | iex
```

Just run Zed either from the Start Menu shortcut or by running `zed` in the command line.

### Manually

Download the latest release from the [Releases](https://github.com/xarunoba/zed-windows/releases) page.

Extract the contents of the archive to a folder of your choice.

Run the `zed.exe` executable.

## Is this safe?

Yes, this is safe. There are no changes to the official Zed codebase as seen in the GitHub Actions builds.

### Windows Defender is complaining about the executable

This is a false positive. See [this issue](https://github.com/zed-industries/zed/issues/14789) for more information.
