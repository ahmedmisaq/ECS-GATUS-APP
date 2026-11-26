terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 5.0"
    }
  }
}

data "cloudflare_zone" "zone_lookup" {
  filter = {
    name = var.cloudflare_zone
  }
}

resource "aws_acm_certificate" "certificate" {
  domain_name       = var.domain_name
  validation_method = "DNS"

  tags = {
    Environment = "Prod"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "cloudflare_dns_record" "dns_validation" {
  for_each = {
    for dvo in aws_acm_certificate.certificate.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  zone_id = data.cloudflare_zone.zone_lookup.id
  name    = each.value.name
  content = each.value.record
  type    = each.value.type
  ttl     = 60
  proxied = false
}


resource "aws_acm_certificate_validation" "certificate_validation" {
  certificate_arn         = aws_acm_certificate.certificate.arn
  validation_record_fqdns = [for record in cloudflare_dns_record.dns_validation : record.name]
}

resource "cloudflare_dns_record" "gatus_dns" {
  zone_id = data.cloudflare_zone.zone_lookup.id
  name = var.cloudflare_dns_name
  ttl = 3600
  type = "CNAME"
  proxied = false
  content = "gatus-terraform-alb-1771821270.eu-north-1.elb.amazonaws.com"
}