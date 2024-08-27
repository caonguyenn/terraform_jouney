resource "aws_key_pair" "my_keypair" {
  key_name   = "My_Keypair"
  public_key = file("${path.root}/../ssh_key/id_rsa.pub")
}