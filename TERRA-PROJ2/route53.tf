resource "aws_route53_zone" "this" {
  name = "rosestore.fun"
}

resource "aws_route53_record" "root" {
  zone_id = aws_route53_zone.this.zone_id
  name    = "rosestore.fun"
  type    = "A"

  alias {
    name                   = aws_lb.this.dns_name
    zone_id                = aws_lb.this.zone_id
    evaluate_target_health = true
  }
}


output "alb_dns_name" {
  value = aws_lb.this.dns_name
}

output "name_servers" {
  value = aws_route53_zone.this.name_servers
}

 output "public_ip" {
    value = aws_instance.web.public_ip
 }
 