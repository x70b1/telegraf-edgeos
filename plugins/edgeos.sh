#!/bin/sh

edgeos_firmware() {
    firmware_product=$(cut -d '.' -f 2 < /etc/version | cut -d '-' -f 2)
    firmware_parameter="filter=eq~~platform~~edgerouter&filter=eq~~channel~~release&filter=eq~~product~~$firmware_product"

    firmware_running=$(sudo /usr/sbin/ubnt-hal show-version | grep Version | cut -d ' ' -f 7)
    firmware_availiable=$(curl -sf "https://fw-update.ubnt.com/api/firmware-latest?$firmware_parameter" | jq -r ._embedded.firmware[0].version)
    firmware_model=$(sudo /usr/sbin/ubnt-hal show-version | grep model | cut -d ' ' -f 7-)
    firmware_serial=$(sudo /usr/sbin/ubnt-hal show-version | grep S/N | cut -d ' ' -f 9-)

    if [ -n "$firmware_availiable" ]; then
        if [ "$firmware_running" = "$firmware_availiable" ]; then
            firmware_upgrade=0
        else
            firmware_upgrade=1
        fi
    else
        firmware_availiable="unknown"
        firmware_upgrade=0
    fi

    echo "edgeos_firmware running=\"$firmware_running\",availiable=\"$firmware_availiable\",upgrade=$firmware_upgrade,model=\"$firmware_model\",serial=\"$firmware_serial\""
}

edgeos_interfaces() {
    interfaces_list=$(find /sys/class/net -maxdepth 1 -type l | cut -d '/' -f 5)

    interfaces_ethernet=$(/usr/sbin/ubnt-ifctl list-sys-intfs ethernet)
    interfaces_switch=$(/usr/sbin/ubnt-ifctl list-sys-intfs switch)
    interfaces_vif=$(/usr/sbin/ubnt-ifctl list-sys-intfs vif)
    interfaces_bridge=$(/usr/sbin/ubnt-ifctl list-sys-intfs bridge)

    for interface_name in $interfaces_list; do
        if echo "$interfaces_ethernet" | grep -q "$interface_name"; then
            interface_type="ethernet"
        elif echo "$interfaces_switch" | grep -q "$interface_name"; then
            interface_type="switch"
        elif echo "$interfaces_vif" | grep -q "$interface_name"; then
            interface_type="vif"
        elif echo "$interfaces_bridge" | grep -q "$interface_name"; then
            interface_type="bridge"
        else
            interface_type="other"
        fi

        if [ -f /sys/class/net/"$interface_name"/ifalias ]; then
            interface_alias=$(cat /sys/class/net/"$interface_name"/ifalias)

            if [ -n "$interface_alias" ]; then
                interface_alias="alias=\"$interface_alias\","
            else
                interface_alias=""
            fi
        fi

        if [ -f /sys/class/net/"$interface_name"/operstate ]; then
            interface_state=$(cat /sys/class/net/"$interface_name"/operstate)

            if [ "$interface_state" = "up" ]; then
                interface_state="state=0,"
            elif [ "$interface_state" = "lowerlayerdown" ]; then
                interface_state="state=1,"
            elif [ "$interface_state" = "down" ]; then
                interface_state="state=2,"
            else
                interface_state="state=3,"
            fi
        fi

        if [ -f /sys/class/net/"$interface_name"/speed ]; then
            interface_speed=$(cat /sys/class/net/"$interface_name"/speed 2>/dev/null)

            if [ -n "$interface_speed" ]; then
                interface_speed="speed=$interface_speed"
            else
                interface_speed="speed=0"
            fi
        fi

        echo "edgeos_interface,interface=$interface_name,type=$interface_type $interface_alias$interface_state$interface_speed"
    done
}

edgeos_power() {
    power_info=$(sudo /usr/sbin/ubnt-hal getPowerStatus)

    if ! echo "$power_info" | grep -q "is not supported on this platform"; then
        echo "$power_info" | while read -r line; do
            power_info_measurement=$(echo "$line" | cut -d ':' -f 1 | rev | cut -d ' ' -f 1 | rev)
            power_info_value=$(echo "$line" | cut -d ':' -f 2 | cut -d ' ' -f 2)

            echo "edgeos_power $power_info_measurement=$power_info_value"
        done
    else
        echo "Collecting power metrics is not supported on this hardware!"
    fi
}

edgeos_temperature() {
    temperature_info=$(sudo /usr/sbin/ubnt-hal getTemp | tail -n +2 | head -n -1)

    if ! [ -z "$temperature_info" ]; then
        echo "$temperature_info" | while read -r line; do
            temperature_info_sensor=$(echo "$line" | cut -d ':' -f 1 | sed 's/ /\\ /')
            temperature_info_value=$(echo "$line" | cut -d ':' -f 2 | cut -d ' ' -f 1)

            echo "edgeos_temperature,sensor=$temperature_info_sensor temperature=$temperature_info_value"
        done
    else
        echo "Collecting temperature metrics is not supported on this hardware!"
    fi
}

for module in "$@"; do
    if [ "$module" = "--firmware" ]; then
        edgeos_firmware
    elif [ "$module" = "--interfaces" ]; then
        edgeos_interfaces
    elif [ "$module" = "--power" ]; then
        edgeos_power
    elif [ "$module" = "--temperature" ]; then
        edgeos_temperature
    fi
done
