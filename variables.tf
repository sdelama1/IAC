variable "redis_auth_token" {
  description = "Token de autenticación para Redis (debe tener min 16 caracteres)"
  type        = string
  sensitive   = true
}
