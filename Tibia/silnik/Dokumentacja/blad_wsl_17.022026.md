[2026-02-17 14:48:12.992] Extension version: 0.104.3
[2026-02-17 14:48:12.993] L10N bundle: none
[2026-02-17 14:48:13.031] authorityHierarchy: wsl+ubuntu
[2026-02-17 14:48:13.031] WSL extension activating for a local WSL instance
[2026-02-17 14:48:13.228] Download in background is enabled
[2026-02-17 14:48:13.231] Resolving wsl+ubuntu, resolveAttempt: 1
[2026-02-17 14:48:13.378] WSL feature installed: true (dll path)
[2026-02-17 14:48:13.380] NodeExecServer run: C:\WINDOWS\System32\wsl.exe --list --verbose
[2026-02-17 14:48:13.547] 2 distros found
[2026-02-17 14:48:13.550] Starting VS Code Server inside WSL (wsl2)
[2026-02-17 14:48:13.550] Windows build: 19045. Multi distro support: available. WSL path support: enabled
[2026-02-17 14:48:13.550] Scriptless setup: false
[2026-02-17 14:48:13.552] No shell environment set or found for current distro.
[2026-02-17 14:48:13.941] WSL daemon log file: 
[2026-02-17 14:48:13.948] Probing if server is already installed: if [ -d ~/.vscode-server/bin/c3a26841a84f20dfe0850d0a5a9bd01da4f003ea ]; then printf 'install-found '; fi; if [ -f /etc/alpine-release ]; then printf 'alpine-'; fi; uname -m;
[2026-02-17 14:48:13.950] NodeExecServer run: C:\WINDOWS\System32\wsl.exe -d Ubuntu -e sh -c if [ -d ~/.vscode-server/bin/c3a26841a84f20dfe0850d0a5a9bd01da4f003ea ]; then printf 'install-found '; fi; if [ -f /etc/alpine-release ]; then printf 'alpine-'; fi; uname -m;
[2026-02-17 14:48:43.235] Update check by another window detected, skipping.
[2026-02-17 14:48:59.875] Unable to detect if server is already installed: Error: Failed to probe if server is already installed: code: Failed to probe if server is already installed: code: 4294967295, , Katastrofalny bBd. 
[2026-02-17 14:48:59.875] Kod bBdu: Wsl/Service/E_UNEXPECTED
[2026-02-17 14:48:59.875] 
[2026-02-17 14:48:59.877] NodeExecServer run: C:\WINDOWS\System32\wsl.exe -d Ubuntu sh -c '"$VSCODE_WSL_EXT_LOCATION/scripts/wslServer.sh" c3a26841a84f20dfe0850d0a5a9bd01da4f003ea stable code-server .vscode-server --host=127.0.0.1 --port=0 --connection-token=2456769619-2933169699-339075597-2785791697 --use-host-proxy --without-browser-env-var --disable-websocket-compression --accept-server-license-terms --telemetry-level=all'
[2026-02-17 14:49:00.101] Katastrofalny bBd. 
[2026-02-17 14:49:00.101] Kod bBdu: Wsl/Service/E_UNEXPECTED
[2026-02-17 14:49:00.101] 
[2026-02-17 14:49:00.104] For help with startup problems, go to https://code.visualstudio.com/docs/remote/troubleshooting#_wsl-tips
