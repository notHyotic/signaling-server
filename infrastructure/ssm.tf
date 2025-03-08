
// add livekit credentials
resource "aws_ssm_parameter" "api_key" {
  name        = "/signaling-server/livekit-api-key"
  description = "livekit api key"
  type        = "SecureString"
  value       = "uninitialized"
  lifecycle {
    ignore_changes = [value] # Terraform will ignore changes to the value field
  }
}

resource "aws_ssm_parameter" "api_secret" {
  name        = "/signaling-server/livekit-api-secret"
  description = "livekit api secret"
  type        = "SecureString"
  value       = "uninitialized"
  lifecycle {
    ignore_changes = [value] # Terraform will ignore changes to the value field
  }
}

resource "aws_ssm_parameter" "websocket_url" {
  name        = "/signaling-server/livekit-ws-url"
  description = "livekit websocket url"
  type        = "String"
  value       = "uninitialized"

  lifecycle {
    ignore_changes = [value] # Terraform will ignore changes to the value field
  }
}