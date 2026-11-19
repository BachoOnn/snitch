# Security Policy

## Supported versions

Only the latest release receives security fixes.

## Reporting a vulnerability

Please do not open a public issue. Use GitHub's private reporting: open the **Security** tab of this repository and click **Report a vulnerability**.

Reports are acknowledged as soon as possible. Please include the affected version, steps to reproduce, and the impact you see.

## Design guarantees

- Snitch is intended for debug builds, and for internal test builds such as TestFlight when you turn it on with `Snitch.enableOutsideDebug()`. It never runs in an app installed from the App Store.
- It does not intercept or decrypt network traffic and does not modify TLS behavior.
- It sends no telemetry and makes no network calls of its own.
- Captured data stays in memory on the device unless you export it yourself.
