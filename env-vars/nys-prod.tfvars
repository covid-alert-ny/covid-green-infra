aws_region   = "us-east-1"
profile      = "nys"
root_profile = "nys"
environment  = "prod"
full_name    = "covid19"
namespace    = "nys"

enable_dns = true

rds_db_name = "covidgreen_prod"

route53_zone    = "ctprox.health.ny.gov"
api_dns         = "api.prd.ctprox.health.ny.gov"
push_dns        = "push.prd.ctprox.health.ny.gov"
wildcard_domain = "*.prd.ctprox.health.ny.gov"

exposure_schedule      = "rate(5 minutes)"
settings_schedule      = "rate(5 minutes)"
code_lifetime_mins     = 1440
token_lifetime_mins    = 1440
verify_rate_limit_secs = 120

log_level           = "info"
logs_retention_days = 120
arcgis_url          = "https://basemaps.arcgis.com"

default_country_code = "US"
default_region       = "US"
native_regions       = "US"
sms_template         = "Hi there"
sms_sender           = "8008675309"
sms_region           = "US"

app_bundle_id               = "1234asdf" # required by ssm
callback_lambda_s3_bucket = "nys-cpt-artifacts"
callback_lambda_s3_key = "common-lambdas/lambdas-v0.0.1.zip"
cso_lambda_s3_bucket = "nys-cpt-artifacts"
cso_lambda_s3_key = "region-lambdas/region-lambdas-cdeb0045b73b845481901cdc46d452e56f1ff6a3.zip"
authorizer_lambda_s3_bucket = "nys-cpt-artifacts"
authorizer_lambda_s3_key = "common-lambdas/lambdas-v0.0.1.zip"
exposures_lambda_s3_bucket = "nys-cpt-artifacts"
exposures_lambda_s3_key = "common-lambdas/lambdas-v0.0.1.zip"
settings_lambda_s3_bucket = "nys-cpt-artifacts"
settings_lambda_s3_key = "common-lambdas/lambdas-v0.0.1.zip"
stats_lambda_s3_bucket = "nys-cpt-artifacts"
stats_lambda_s3_key = "region-lambdas/region-lambdas-cdeb0045b73b845481901cdc46d452e56f1ff6a3.zip"
token_lambda_s3_bucket = "nys-cpt-artifacts"
token_lambda_s3_key = "common-lambdas/lambdas-v0.0.1.zip"

