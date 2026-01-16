
output "aws_ami" {
  value = data.aws_ami.ami.id
}
output "aws_instance" {
  value = aws_instance.webserver.public_ip
}