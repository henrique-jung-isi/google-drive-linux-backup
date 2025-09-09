#!/bin/bash
set -e

function valueFromGioInfo {
	file="$1"
	prop="$2"
	gio info "$file" | grep "$prop" | awk -F': ' '{print $2}'
}

function getIdByName {
	directory="$1"
	name="$2"
	for file in $(gio list "$directory"); do
		displayName=$(valueFromGioInfo "$directory$file" "display-name")
		if [[ "$displayName" == "$name" ]]; then
			echo $file
			return
		fi
	done
}

function mountGio {
	path="$1"
	email=$(gio mount -l | grep "@" | awk -F': ' '{print $2}')

	if [[ ! "${email[@]}" == *"->"* ]]; then
		gio mount "google-drive://$email/"
	fi
}

while [ "$1" != "" ]; do
	case "$1" in
	-h | --help)
		echo "Usage:
  copy.bash [OPTIONS] [FILES...]

Options:
  -h, --help    Show help.
  -d            Change destination folder on drive.
                Default: google-drive:/My Drive.
  -r            Create destination folder.
  -n, --dry-run 
                Don't do anything, just show what would happen.

Files:
  The list of files to save one after the other separated by spaces."
		exit 0
		;;
	-n | --dry-run)
		dryRun=1
		;;
	-d)
		originalDestination="$2"
		IFS='/' read -ra folderToSave <<<"$2"
		shift
		;;
	-r) create=1 ;;
	*)
		if [[ "$1" = /* ]]; then
			files+=("$1")
		else
			files+=("$(pwd)/$1")
		fi
		;;
	esac
	shift
done

if [[ -z $files ]]; then
	files=("/home/$USER/.config/Code/User/keybindings.json" "/home/$USER/.config/Code/User/settings.json")
fi

if [[ -z $folderToSave ]]; then
	folderToSave=("My Drive")
	originalDestination="$folderToSave"
fi

mountGio

drive="/run/user/$UID/gvfs/"
drive="$drive$(ls $drive | grep "google-drive" | head -n 1)"

for folder in "${folderToSave[@]}"; do
	current="$drive/$accumulated"
	id=$(getIdByName "$current" "$folder")
	if [[ -z $id ]]; then
		if [[ $create -eq 0 ]]; then
			echo 'Path not found. Not creating: -r option missing.'
			exit 1
		fi
		if [[ $dryRun -eq 0 ]]; then
			mkdir "$current$folder"
			id=$(getIdByName "$current" "$folder")
		else
			echo "Would create dir -> google-drive:/$originalDestination"
			break
		fi
	fi
	accumulated="$accumulated$id/"
done

if [[ ! -z $id || $dryRun ]]; then
	for file in "${files[@]}"; do
		name="$(basename "$file")"
		id=$(getIdByName "$drive/$accumulated" "$name")
		if [[ ! -z "$id" ]] && diff -q "$file" "$drive/$accumulated$id" >/dev/null 2>&1; then
			echo google-drive:/$originalDestination/$name up to date
		else
			if [[ $dryRun -eq 0 ]]; then
				cp "$file" "$drive/$accumulated"
			fi
			echo "$([[ $dryRun -eq 1 ]] && echo "Would copy: " || echo "")$file -> google-drive:/$originalDestination"
		fi

	done
else
	exit 1
fi
