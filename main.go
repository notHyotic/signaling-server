package main

import (
	"log"
	"signaling-server/api"
)

func main() {
	app := api.NewApp()
	log.Fatal(app.Listen(":8080"))
}
