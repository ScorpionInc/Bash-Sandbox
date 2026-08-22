#!/bin/bash

get_default_interface_address()
{
	local dev=$(ip route list | awk '/^default/ {print $5}')
	local addr=$(ip -o -f inet addr show "$dev" | awk '{print $4}')
	echo "${addr}"
}

get_default_interface_network_address()
{
	local ip_cidr=$(get_default_interface_address)

    # Split the IP and the slash notation
    IFS='/' read -r ip mask <<< "$ip_cidr"

    # Parse the 4 octets of the IP address
    IFS='.' read -r i1 i2 i3 i4 <<< "$ip"

    # Convert IP octets to a 32-bit integer
    local ip_int=$(( (i1 << 24) + (i2 << 16) + (i3 << 8) + i4 ))

    # Generate the 32-bit subnet mask from slash notation
    local mask_int=$(( 0xFFFFFFFF << (32 - mask) ))

    # Perform a bitwise AND to get the network integer
    local net_int=$(( ip_int & mask_int ))

    # Convert the 32-bit network integer back to dotted-quad notation
    local n1=$(( (net_int >> 24) & 0xFF ))
    local n2=$(( (net_int >> 16) & 0xFF ))
    local n3=$(( (net_int >> 8) & 0xFF ))
    local n4=$(( net_int & 0xFF ))

    echo "$n1.$n2.$n3.$n4"
}

get_default_interface_broadcast_address()
{
	local ip_cidr=$(get_default_interface_address)

	# Split the IP and the slash notation
    IFS='/' read -r ip mask <<< "$ip_cidr"

    # Parse the 4 octets of the IP address
    IFS='.' read -r i1 i2 i3 i4 <<< "$ip"

    # Convert IP octets to a 32-bit integer
    local ip_int=$(( (i1 << 24) + (i2 << 16) + (i3 << 8) + i4 ))

	local mask_int=$(( 0xFFFFFFFF << (32 - mask) & 0xFFFFFFFF ))
	local bcast_int=$(( ip_int | (~mask_int & 0xFFFFFFFF) ))

	printf "%d.%d.%d.%d\n" \
		$(( (bcast_int >> 24) & 255 )) \
		$(( (bcast_int >> 16) & 255 )) \
		$(( (bcast_int >> 8) & 255 )) \
		$(( bcast_int & 255 ))
}

# Define the first three octets of the network
SUBNET="10.0.69"

echo "Starting ping scan on ${SUBNET}.0/24..."

# Loop through the last octet from 1 to 254
for i in {1..254}; do
    IP="${SUBNET}.${i}"
    # Send a single ping packet (-c 1), wait at most 1 second for a response (-W 1 or -t 1)
    # and redirect all output to /dev/null
    ping -c 1 -W 3 "$IP" >/dev/null 2>&1

    # Check the exit status of the ping command
    if [ $? -eq 0 ]; then
        echo "Host $IP is UP"
    # Optional: uncomment the else block to see all addresses
    else
        echo "Host $IP is DOWN"
    fi
done

echo "Scan complete."
