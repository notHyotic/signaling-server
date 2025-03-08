# Define the base URL of the API
$baseUrl = "http://localhost:8080"

# Define the query parameters
$roomName = "salad"
$username = "watermelon"

# Construct the full URL with query parameters
$url = "$baseUrl/livekit/roomCheck?roomName=$roomName&username=$username"

# Send the GET request and capture the response
$response = Invoke-RestMethod -Uri $url -Method Get

# Output the response
$response