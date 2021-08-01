
MOD_NAME=$(jq -r '.name' mod/info.json)
MOD_VERSION=$(jq -r '.version' mod/info.json)
FILE_NAME="${MOD_NAME}_${MOD_VERSION}.zip"
MODS_DIR="/Users/${USER}/Library/Application Support/factorio/mods/"

zip  "$FILE_NAME" -r mod/

cp "$FILE_NAME" "$MODS_DIR"/"$FILE_NAME"
