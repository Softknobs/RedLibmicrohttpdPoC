# RedLibmicrohttpdPoC
Simple libmicrohttpd server example serving one page with Red bindings (Windows / Linux)

# Build

Compile for Windows with this command:
```
red -t Windows libmicrohttpd-example.red
```

or Linux:
```
red -t Linux libmicrohttpd-example.red
```

# Usage

Run the executable

## Windows

![Screenshot](https://github.com/Softknobs/RedLibmicrohttpdPoC/blob/master/libmicrohttpd-win.png)

- port can be customized with dedicated port field
- by default, click "Start" to start the server on port 8080
- browse http://localhost:8080 to see the served page
- click "Stop" to stop the server

## Linux

When program is run, the server is started on port 8080 if available.
Use CTRL-C to quit.

# Binaries

Building the librairies is not required as binaries are available on GNU.org or in Linux distributions. Here, binaries are provided for simplicity and no additional download is required.

# Windows 
Available here: https://ftpmirror.gnu.org/libmicrohttpd/libmicrohttpd-latest-w32-bin.zip

## Linux

Depends on the distribution. For Debian x64, the .so can be retrieved by installing:
```
apt-get install libmicrohttpd12:i386
```
The .so is then available here:
```
/usr/lib/i386-linux-gnu/libmicrohttpd.so.12
```



