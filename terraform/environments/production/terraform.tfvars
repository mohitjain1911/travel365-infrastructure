
region = "eu-west-2"

enable_rds = true
enable_sqs = true
enable_cloudfront = true
enable_waf = true
enable_ses = true

enable_nat = true

frontend_desired_count = 2
backend_desired_count  = 2
admin_desired_count    = 1

frontend_cpu = 512
frontend_memory = 1024
backend_cpu = 512
backend_memory = 1024
admin_cpu = 512
admin_memory = 1024

domain_name = "clientdomain.com"
create_hosted_zone = true
