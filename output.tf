output "vpcInfo" {

value = aws_vpc.vpc.id

}

output "subnetsPub"{
    value = data.aws_subnet_ids.subnetsPub.ids
}




