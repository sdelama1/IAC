#!/bin/bash
dnf update -y
dnf install -y python3.11 pip git
# Aquí iría la lógica para descargar tu app del repo/S3 y ejecutarla
# aws secretsmanager get-secret-value ...
