package livekit

import (
	"context"
	"log"
	"os"
	"time"

	"github.com/joho/godotenv"
	"github.com/livekit/protocol/auth"
	livekit "github.com/livekit/protocol/livekit"
	lksdk "github.com/livekit/server-sdk-go/v2"
)

var (
	hostUrl     string
	apiKey      string
	apiSecret   string
	roomService *lksdk.RoomServiceClient
)

func init() {
	// Load .env file
	err := godotenv.Load()
	if err != nil {
		log.Printf("Could not load .env file, will use environment variables.")
	}

	// Assign values from environment variables
	hostUrl = os.Getenv("LIVEKIT_WS_URL")
	apiKey = os.Getenv("LIVEKIT_API_KEY")
	apiSecret = os.Getenv("LIVEKIT_API_SECRET")

	if hostUrl == "" || apiKey == "" || apiSecret == "" {
		log.Fatalln("Missing LiveKit credentials in environment variables")
	}

	// Initialize RoomServiceClient
	roomService = lksdk.NewRoomServiceClient(hostUrl, apiKey, apiSecret)
}

func UsernameTaken(name, room string) (bool, error) {
	roomExist, err := RoomExist(room)
	if err != nil {
		return false, err
	}

	if !roomExist {
		return false, err
	}

	res, _ := roomService.ListParticipants(context.Background(), &livekit.ListParticipantsRequest{
		Room: room,
	})

	for _, p := range res.Participants {
		if p.Name == name {
			return true, err
		}
	}

	return false, err
}

func RoomExist(room string) (bool, error) {
	res, err := roomService.ListRooms(context.Background(), &livekit.ListRoomsRequest{})
	if err != nil {
		return false, err
	}

	rooms := res.GetRooms()

	for _, r := range rooms {
		if r.Name == room {
			return true, nil
		}
	}

	return false, nil
}

func CreateToken(room, username string, canPublish, canSubscribe bool) (string, error) {
	at := auth.NewAccessToken(apiKey, apiSecret)

	grant := &auth.VideoGrant{
		RoomJoin:     true,
		Room:         room,
		CanPublish:   &canPublish,
		CanSubscribe: &canSubscribe,
	}

	at.SetVideoGrant(grant).
		SetIdentity(username).
		SetValidFor(time.Hour)

	return at.ToJWT()
}

func ListAllParticipants(room string) ([]string, string, error) {
	// List participants in a room
	res, err := roomService.ListParticipants(context.Background(), &livekit.ListParticipantsRequest{
		Room: room,
	})

	if err != nil {
		return []string{}, "", err
	}

	var hostname string
	var pn []string

	// Loop through the participants to find the host and participant names
	for _, p := range res.Participants {
		if p.Permission.CanPublish {
			hostname = p.Name
		}
		pn = append(pn, p.Name)
	}

	// Return the list of participant names and the host (if found)
	return pn, hostname, nil
}
