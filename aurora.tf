resource "random_password" "db_master_pass" {
  length           = 16
  special          = true
  override_special = "_%!"
}

resource "aws_secretsmanager_secret" "aurora_db_secret" {
  name        = "iac-aurora-db-credentials"
  description = "Credenciales maestras para Aurora DB"
}

resource "aws_secretsmanager_secret_version" "aurora_db_secret_val" {
  secret_id = aws_secretsmanager_secret.aurora_db_secret.id
  secret_string = jsonencode({
    username = "admin"
    password = random_password.db_master_pass.result
  })
}

resource "aws_db_subnet_group" "aurora_subnet_group" {
  name       = "iac-aurora-subnet-group"
  subnet_ids = [aws_subnet.private_data_1.id, aws_subnet.private_data_2.id]

  tags = {
    Name = "IAC-Aurora-Subnet-Group"
  }
}

resource "aws_rds_cluster" "main" {
  cluster_identifier      = "iac-aurora-cluster"
  engine                  = "aurora-mysql"
  engine_version          = "8.0.mysql_aurora.3.04.0"
  availability_zones      = ["us-east-1a", "us-east-1b"]
  database_name           = "iacdb"
  master_username         = "admin"
  master_password         = random_password.db_master_pass.result
  backup_retention_period = 7
  preferred_backup_window = "07:00-09:00"
  vpc_security_group_ids  = [aws_security_group.db_sg.id]
  db_subnet_group_name    = aws_db_subnet_group.aurora_subnet_group.name
  skip_final_snapshot     = true
  storage_encrypted       = true

  tags = {
    Name = "IAC-Aurora-Cluster"
  }
}

resource "aws_rds_cluster_instance" "cluster_instances" {
  count               = 2
  identifier          = "iac-aurora-node-${count.index}"
  cluster_identifier  = aws_rds_cluster.main.id
  instance_class      = "db.t3.medium"
  engine              = aws_rds_cluster.main.engine
  engine_version      = aws_rds_cluster.main.engine_version
  publicly_accessible = false

  tags = {
    Name = "IAC-Aurora-Node-${count.index}"
  }
}
