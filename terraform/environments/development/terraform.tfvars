
region = "eu-west-2"

enable_rds = false
enable_sqs = false
enable_cloudfront = false
enable_waf = false
enable_ses = false

enable_nat = false

frontend_desired_count = 1
backend_desired_count  = 1
admin_desired_count    = 0

frontend_cpu = 256
frontend_memory = 512
backend_cpu = 256
backend_memory = 512
admin_cpu = 256
admin_memory = 512

domain_name = ""
create_hosted_zone = false
