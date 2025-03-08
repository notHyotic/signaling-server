package api

import (
	"context"
	"fmt"
	livekit "signaling-server/livekit"

	"github.com/gofiber/fiber/v2"
)

type API struct{}

// GenerateTokenForJoinRoom implements StrictServerInterface.
func (a *API) GenerateTokenForJoinRoom(ctx context.Context, request GenerateTokenForJoinRoomRequestObject) (GenerateTokenForJoinRoomResponseObject, error) {
	room := &request.Body.Room
	username := &request.Body.Username

	token, err := livekit.CreateToken(*room, *username, false, true)
	if err != nil {
		fmt.Printf("Error creating token: %v\n", err)
		return nil, fmt.Errorf("error creating token: %v", err)
	}

	p, h, err := livekit.ListAllParticipants(*room)
	if err != nil {
		fmt.Printf("Error getting participants: %v\n", err)
		return nil, fmt.Errorf("error getting participants: %v", err)
	}

	return GenerateTokenForJoinRoom200JSONResponse{
		Token:        &token,
		Host:         &h,
		Participants: &p,
	}, nil
}

// GetLivekitGetUsersInRoom implements StrictServerInterface.
func (a *API) GetLivekitGetUsersInRoom(ctx context.Context, request GetLivekitGetUsersInRoomRequestObject) (GetLivekitGetUsersInRoomResponseObject, error) {
	roomname := &request.Params.Room

	res, _, err := livekit.ListAllParticipants(*roomname)
	if err != nil {
		fmt.Printf("Error getting participants: %v\n", err)
		return nil, fmt.Errorf("error getting participants: %v", err)
	}

	return GetLivekitGetUsersInRoom200JSONResponse{
		Room: roomname,
		Users: &res,
	}, nil
}

// GetLivekitRoomCheck implements StrictServerInterface.
func (a *API) GetLivekitRoomCheck(ctx context.Context, request GetLivekitRoomCheckRequestObject) (GetLivekitRoomCheckResponseObject, error) {
	roomname := &request.Params.RoomName
	username := &request.Params.Username

	roomExist, err := livekit.RoomExist(*roomname)
	if err != nil {
		fmt.Printf("Error checking if room exist: %v\n", err)
		return nil, fmt.Errorf("error checking if room exist: %v", err)
	}

	usernameAvailable, err := livekit.UsernameTaken(*username, *roomname)
	usernameAvailable = !usernameAvailable
	if err != nil {
		fmt.Printf("Error checking if username is available: %v\n", err)
		return nil, fmt.Errorf("error checking if username is available: %v", err)
	}

	return GetLivekitRoomCheck200JSONResponse{
		RoomExists:        &roomExist,
		UsernameAvailable: &usernameAvailable,
	}, nil

}

// PostLivekitGenerateTokenForHostRoom implements StrictServerInterface.
func (a *API) PostLivekitGenerateTokenForHostRoom(ctx context.Context, request PostLivekitGenerateTokenForHostRoomRequestObject) (PostLivekitGenerateTokenForHostRoomResponseObject, error) {
	room := &request.Body.Room
	username := &request.Body.Username

	token, err := livekit.CreateToken(*room, *username, true, true)
	if err != nil {
		fmt.Printf("Error creating token: %v\n", err)
		return nil, fmt.Errorf("error creating token: %v", err)
	}

	return PostLivekitGenerateTokenForHostRoom200JSONResponse{
		Token:        &token,
	}, nil
}

func NewApp() *fiber.App {
	api := &API{}
	app := fiber.New()

	server := NewStrictHandler(api, nil)

	RegisterHandlers(app, server)

	app.Get("/", func(c *fiber.Ctx) error {
		return c.SendString("Hello from signaling-server")
	})

	return app
}
