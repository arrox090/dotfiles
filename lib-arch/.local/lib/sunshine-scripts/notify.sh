notify() {
	local title="$1" msg="$2"
	curl -s -m 10 -A "sunshine-notify/1.0" \
		-H "Content-Type: application/json" \
		-d "$(jq -n --arg c "**$title**: ${msg:0:1900}" '{content: $c}')" \
		"$DISCORD_WEBHOOK_URL" >/dev/null
}
