# Use the official Go image to build the application
FROM golang:1.24 AS builder

#Set the working directory inside the container
WORKDIR /app

# Copy Go module files (if applicable)
COPY go.mod go.sum ./

# Copy the Go application source code
COPY . .

# Download Go dependencies
RUN go mod tidy

# Build the Go application (this should generate the `signaling-server` binary)
RUN go build -o signaling-server .

# Expose the server port
EXPOSE 8080

# Command to run the Go server
CMD ["./signaling-server"]
