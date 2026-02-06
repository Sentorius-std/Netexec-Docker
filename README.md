# Netexec-Docker

A Docker wrapper for NetExec designed for automation, scripting, and clean result handling during network and infrastructure pentests.

This container allows you to run NetExec without installing it on the host, while keeping:

* Persistent NetExec workspace

* Automatic log saving

* Automatic JSON result parsing

<br>

## Requirements

* Docker installed

* Internet access (first build only)

<br>

## Build the image


```bash
docker build -t netexec-docker .
```

<br>

## Running a script

```bash
docker run --rm \
  -v $(pwd)/output:/output \
  -v $(pwd)/nxc_home:/data \
  netexec-docker smb 10.10.10.0/24
```
<br>

## Volumes explanation

**/output** :	Stores logs and JSON results outside the container

**/data**	: Persistent NetExec home (avoids first-time initialization every run)

<br>

## Output files

After each run, two files are created in /output:

* **scan_DATE.log** → Full NetExec output

* **scan_DATE.json** → Parsed result for automation
  
Example JSON:

```json
{
  "protocol": "SMB",
  "ip": "10.10.128.3",
  "hostname": "LOCAL",
  "compromised": true,
  "creds": "Local\\Administrator:Password123"
}
```
<img width="619" height="155" alt="image" src="https://github.com/user-attachments/assets/0b1b7313-b948-47e6-8517-49e09319f92a" />
<br>
<br>

In case the user tested is not a Local Admin :
<br>

<img width="644" height="148" alt="image" src="https://github.com/user-attachments/assets/61c080ce-6fe6-4d1f-a1bf-bfcd7a0d1ecc" />
<br>
<br>
In case an error occurs:

```json
{
  "response": "Error",
  "reason": "empty_output"
}
```
<img width="669" height="241" alt="image" src="https://github.com/user-attachments/assets/be09fe26-554d-4a43-9ab3-b30b3e4d96c9" />
