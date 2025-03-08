# Define the base URL of the API
$baseUrl = "http://localhost:8080"

# Define the query parameters
$roomName = "salad"
$username = "watermelon"

# Define the body to send in the POST request
$body = @{
    room = $roomName
    username = $username
}

# Send the POST request and capture the response
$response = Invoke-RestMethod -Uri "$baseUrl/livekit/generateTokenForHostRoom" -Method Post -Body $body

# Output the response
$response
