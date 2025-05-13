function bluetooth_toggle
    # Use blueman-manager instead of bluetoothctl to avoid Hyprland crash
    set bluetooth_status (rfkill list bluetooth | grep -i -o "Soft blocked: yes")
    set backup_file ~/.cache/airplane_backup

    if [ -z "$bluetooth_status" ]
        rfkill block bluetooth
        notify-send "Bluetooth" "Bluetooth turned off" --icon=bluetooth-disabled
    else
        rfkill unblock bluetooth
        # Wait a moment for bluetooth to initialize
        sleep 0.5
        # Restart bluetooth service to ensure clean state
        systemctl --user restart blueman-applet
        notify-send "Bluetooth" "Bluetooth turned on" --icon=bluetooth

        if test -e $backup_file
            rm $backup_file
        end
    end
end
