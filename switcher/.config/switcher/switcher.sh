switcher_id="com.switcher.hypr"
config_path="$HOME/.config/switcher/switcherrc"

function get_windows_info() {
    windows=$(hyprctl clients -j | jq 'map(select(.mapped == true and .class != "com.switcher.hypr")) | sort_by(.focusHistoryID) | .[] | {class, address, title}' | jq -s '.')

    icons=()

    while read -r line; do
        # desktopfile is /usr/share/applications/xxx.desktop where xxx is lowercase of $line 
        desktopfile="/usr/share/applications/${line,,}.desktop"
        icon=$(grep -r -h "Icon=" "$desktopfile" | head -n 1 | cut -d "=" -f 2)
        icon=$(find /usr/share/icons/ -name "$icon.*" | head -n 1)
        icons+=("$icon")
    done < <(echo "$windows" | jq -r '.[] | "\(.class)"')
}

function get_current_index() {
    current_index=$(grep -oP '(?<=index": )\d+' "$config_path")
    [[ -z "$current_index" ]] && current_index=0
    current_index=$((current_index + 1))
    
    last_line=$(tail -n 1 "$config_path")
    icons=($(echo "$last_line" | grep -oP '(?<="icons": ")[^"]*'))
    [[ "$current_index" -ge "${#icons[@]}" ]] && current_index=0
}

function init_data() {
    get_windows_info

    current_index=1

    echo "{\"index\": $current_index," > "$config_path.tmp"
    echo "\"windows\": $windows," >> "$config_path.tmp"
    echo "\"icons\": \"${icons[*]}\" }" >> "$config_path.tmp"
    
    cat "$config_path.tmp" > "$config_path"
    rm "$config_path.tmp"
}

function display(){
    python "$HOME/.config/switcher/switcher.py" &
    hyprctl dispatch movetoworkspacesilent 10,$switcher_id
}

function next() {
    get_current_index
    sed -i "s/index\": [0-9]*/index\": $current_index/" "$config_path"
}

function move_to_current_workspace(){
    current_workspace=$(hyprctl activeworkspace | grep -oP '(?<=ID )\d+')
    hyprctl dispatch movetoworkspace $current_workspace,$switcher_id
}

case "$1" in
    init)
        init_data
        display
        ;;
    next)
        active_class=$(hyprctl activewindow | grep -oP '(?<=class: )[^ ]*')
        if [[ "$active_class" == "$switcher_id" ]]; then
            next
        else
            init_data
            move_to_current_workspace
        fi
        ;;
    *)
        echo "Usage: $0 {init|next|prev}"
        exit 1
esac