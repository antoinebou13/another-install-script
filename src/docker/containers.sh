#!/usr/bin/env bash
#
# @file container.sh
# @brief list of container and other info

declare -A container_name_array=(
	[cloud_torrent]="cloud_torrent"
	[heimdall]="heimdall"
	[huginn]="huginn"
	[jellyfin]="jellyfin"
	[jenkins]="jenkins"
	[jupyterhub]="jupyterhub"
	[mailcow]="mailcow"
	[mcmyadmin]="mcmyadmin"
	[medusa]="medusa"
	[openvpn]="openvpn"
	[pyload]="pyload"
	[recalbox]="RecalBox"
	[statping]="statping"
	[syncthing]="syncthing"
	[teamspeak]="teamspeak"
)

echo "${container_name_array['cloud_torrent']}"