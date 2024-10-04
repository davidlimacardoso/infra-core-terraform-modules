resource "aws_route53_zone" "private" {
  for_each = { for zone in var.hosted_zones : zone.name => zone if zone.private }
  name     = "vprofile.in"

  vpc {
    vpc_id = each.value.vpc_id
  }
}

resource "aws_route53_zone" "public" {
  for_each = { for zone in var.hosted_zones : zone.name => zone if !zone.private }
  name     = "public.in"
}

resource "aws_route53_record" "record_private_zone" {
for_each = {
    for item in flatten([
      for zone in var.hosted_zones : [
        for record in zone.records : {
          zone_name = zone.name
          record    = record
        }
      ] if zone.private
    ]) : "${item.zone_name}-${item.record.name}-${item.record.type}" => item
  }

  zone_id = aws_route53_zone.private[each.value.zone_name].zone_id
  name    = each.value.record.name
  type    = each.value.record.type
  ttl     = each.value.record.ttl
  records = each.value.record.records
}

resource "aws_route53_record" "record_public_zone" {
for_each = {
    for item in flatten([
      for zone in var.hosted_zones : [
        for record in zone.records : {
          zone_name = zone.name
          record    = record
        }
      ] if !zone.private
    ]) : "${item.zone_name}-${item.record.name}-${item.record.type}" => item
  }

  zone_id = aws_route53_zone.private[each.value.zone_name].zone_id
  name    = each.value.record.name
  type    = each.value.record.type
  ttl     = each.value.record.ttl
  records = each.value.record.records
}

output "private_hosted_zone_id" {
  value = { for zone in var.hosted_zones : zone.name => aws_route53_zone.private[zone.name].id }  
}