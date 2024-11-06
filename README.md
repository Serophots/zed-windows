# Zed Builds for Windows (Unofficial)

This repository contains unnofficial builds of [Zed](https://github.com/zed-industries/zed) for Windows.
Disclaimer: These builds may break at any time as they are not officially supported by Zed Industries.
However they are transparently built from the official [Zed](https://github.com/zed-industries/zed) repository using GitHub Actions based on the latest release of Zed.

## Features

- Automatic builds on a schedule (every hour)
- Manual builds on request
- Builds for Vulkan and OpenGL ES

## Builds

| Build | Vulkan | OpenGL ES |
| --- | --- | --- |
| Latest Release | [![Latest Release Vulkan](https://github.com/xarunoba/zed-windows/actions/workflows/build.yml/badge.svg?branch=main)](https://github.com/xarunoba/zed-windows/actions/workflows/build.yml) | [![Latest Release OpenGL ES](https://github.com/xarunoba/zed-windows/actions/workflows/build.yml/badge.svg?branch=main)](https://github.com/xarunoba/zed-windows/actions/workflows/build.yml) |

## Usage

Download the latest release from the [Releases](https://github.com/xarunoba/zed-windows/releases) page.

### Vulkan

Extract the `zed-release-vulkan-<version>.zip` file to a folder of your choice.

Run `zed.exe` from the extracted folder.

### OpenGL ES

Extract the `zed-release-gles-<version>.zip` file to a folder of your choice
