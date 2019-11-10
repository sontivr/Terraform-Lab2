output "instance_id" {
  value = "${aws_instance.windows-server-2019.id}"
}

output "instance_public_ip" {
  value = "${aws_instance.windows-server-2019.public_ip}"
}
