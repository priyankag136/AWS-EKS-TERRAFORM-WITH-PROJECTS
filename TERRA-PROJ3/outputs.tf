output "bucket_id" {
  value = module.vpc.bucket_id
}

output "static_website" {
  value = module.vpc.website_endpoint
}

output "public_ip" {
  value = module.vpc.public_ip_server1
}

output "private_ip" {
  value = module.vpc.private_ip_server1
}