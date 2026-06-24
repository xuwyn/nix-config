{pkgs}:
pkgs.writeShellScriptBin "natural-scroll" ''
  #!/bin/bash

  # Get id of touchpad and the id of the field corresponding to
  # natural scrolling
  # id=`xinput list | grep -i "Touchpad" | cut -d'=' -f2 | cut -d'[' -f1`
  # natural_scrolling_id=`xinput list-props $id | \
  #                       grep -i "Natural Scrolling Enabled (" \
  #                       | cut -d'(' -f2 | cut -d')' -f1`

  # Set the property to true
  # xinput --set-prop $id $natural_scrolling_id 1

  # Function to enable natural scrolling for a specific device ID
  enable_natural_scrolling() {
    local device_id=$1
    # Extract the numeric property ID for 'Natural Scrolling Enabled'
    local prop_id=$(xinput list-props "$device_id" | grep -i "Natural Scrolling Enabled (" | cut -d'(' -f2 | cut -d')' -f1)

    if [ -n "$prop_id" ]; then
      xinput --set-prop "$device_id" "$prop_id" 1
    fi
  }

  # Iterate through all devices, filtering for those typically identified as pointer or mouse
  # We use xinput list --id-only to get just the ID numbers
  xinput list --id-only | while read -r id; do
    # Check if the device is a pointer/mouse/touchpad to avoid setting it on keyboards or other hardware
    if xinput list-props "$id" | grep -q "Natural Scrolling Enabled"; then
      enable_natural_scrolling "$id"
    fi
  done
''
