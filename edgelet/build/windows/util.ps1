# Copyright (c) Microsoft. All rights reserved.

function Test-RustUp
{
    (get-command -Name rustup.exe -ErrorAction SilentlyContinue) -ne $null
}

function Get-CargoCommand
{
    if (Test-RustUp)
    {
        'cargo +stable-x86_64-pc-windows-msvc '
    }
    else
    {
        "$env:USERPROFILE/.cargo/bin/cargo.exe +stable-x86_64-pc-windows-msvc "
    }
}

function Get-Manifest
{
    $ProjectRoot = Join-Path -Path $PSScriptRoot -ChildPath "../../.."
    Join-Path -Path $ProjectRoot -ChildPath "edgelet/Cargo.toml"
}

function Assert-Rust
{
    Write-Host "Validating Rust (stable-x86_64-pc-windows-msvc) is installed and up to date."
    if (-not (Test-RustUp))
    {
        Write-Host "Installing rustup and stable-x86_64-pc-windows-msvc Rust."
        Invoke-RestMethod -usebasicparsing 'https://static.rust-lang.org/rustup/dist/x86_64-pc-windows-msvc/rustup-init.exe' -outfile 'rustup-init.exe'
        if ($LastExitCode)
        {
            Throw "Failed to download rustup with exit code $LastExitCode"
        }

        New-Item -Type Directory -Force ~/.cargo/bin
        Move-Item ./rustup-init.exe ~/.cargo/bin/rustup.exe
        $env:PATH += ";$(Resolve-Path '~/.cargo/bin')"
    }
    else
    {
        Write-Host "Running rustup.exe"
        rustup install stable-x86_64-pc-windows-msvc
        if ($LastExitCode)
        {
            Throw "Failed to install rust with exit code $LastExitCode"
        }

        rustup default stable-x86_64-pc-windows-msvc
        if ($LastExitCode)
        {
            Throw "Failed to set default rust toolchain with exit code $LastExitCode"
        }
    }
}
