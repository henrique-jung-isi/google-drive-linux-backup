# Google Drive for Ubuntu Linux Backup

Bash script to automate backup of files using Online Accounts from Ubuntu and Google Drive.  
By default the script will backup the user's vscode `keybindings.json` and `settings.json` files to the `My Drive` folder.  
The script will use `diff` to determine if the files need updating.

## Usage

&emsp;`backup.bash` [OPTIONS] [FILES...]  

| Option | Description |
| --- | --- |
| -h, --help | Show help.  |
| -d | Change destination folder on drive.  Default: google-drive:/My Drive. |
| -r | Create destination folder. |
| -n, --dry-run | Don't do anything, just show what would happen. |

Files:  
&emsp;The list of files to save one after the other separated by spaces.

## Example usage

```bash
./backup.bash
# Will save "~/.config/Code/User/keybindings.json" and "~/.config/Code/User/settings.json" to "My Drive" folder
```

```bash
./backup.bash -d -r "My Drive/files" ~/file1 "~/file 2"
# Will create the "files" directory if it doesn't exists and save "~/file1" and "~/file 2"
```

## Service and timer files

This files will automate the usage of the script. By default the scipt will run 1 minute after boot and every hour from there.

To use copy them to `~/.config/systemd/user`.  
Reload the systemctl daemon and enable them.

```bash
cp backup.* ~/.config/systemd/user
systemctl --user daemon-reload
systemctl --user enable backup.timer
```

The timer will be stopped, to start it without rebooting run:

```
systemctl --user start backup.timer
```
