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

These files will automate the usage of the script. By default the script will run 1 minute after boot and every hour from there.

To use, there are two options:

```bash
sudo cp backup.* /etc/systemd/user
systemctl --user daemon-reload
systemctl --user enable backup.timer
```

This will copy all the files to the user systemctl folder.

Or create a symlink to the script:

```bash
sudo cp backup.service /etc/systemd/user
sudo cp backup.timer /etc/systemd/user
sudo ln -s $(pwd)/backup.bash /etc/systemd/user
systemctl --user daemon-reload
systemctl --user enable backup.timer
```

This way the script can be modified from the repository directory.

The timer will be stopped, to start it without rebooting run:

```bash
systemctl --user start backup.timer
```
