data "archive_file" "callback" {
  type        = "zip"
  output_path = "${path.module}/.zip/${module.labels.id}_callback.zip"
  source_file = "${path.module}/templates/lambda-placeholder.js"
}

data "aws_iam_policy_document" "callback_policy" {
  statement {
    actions = [
      "s3:*",
      "ec2:CreateNetworkInterface",
      "ec2:DescribeNetworkInterfaces",
      "ec2:DetachNetworkInterface",
      "ec2:DeleteNetworkInterface",
      "secretsmanager:GetSecretValue",
      "ssm:GetParameter",
      "sqs:*"
    ]
    resources = ["*"]
  }

  statement {
    actions = ["kms:*"]
    resources = [
      aws_kms_key.sqs.arn
    ]
  }
}

data "aws_iam_policy_document" "callback_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type = "Service"

      identifiers = [
        "lambda.amazonaws.com",
      ]
    }
  }
}

resource "aws_cloudwatch_log_group" "callback" {
  name              = format("/aws/lambda/%s-callback", module.labels.id)
  retention_in_days = var.logs_retention_days
  tags              = module.labels.tags
}

resource "aws_iam_policy" "callback_policy" {
  name   = "${module.labels.id}-lambda-callback-policy"
  path   = "/"
  policy = data.aws_iam_policy_document.callback_policy.json
}

resource "aws_iam_role" "callback" {
  name               = "${module.labels.id}-lambda-callback"
  assume_role_policy = data.aws_iam_policy_document.callback_assume_role.json
  tags               = module.labels.tags
}

resource "aws_iam_role_policy_attachment" "callback_policy" {
  role       = aws_iam_role.callback.name
  policy_arn = aws_iam_policy.callback_policy.arn
}

resource "aws_iam_role_policy_attachment" "callback_logs" {
  role       = aws_iam_role.callback.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_s3_bucket_object" "callback_s3_file" {
  bucket = aws_s3_bucket.lambdas.id
  key    = "lambdas/${module.labels.id}_callback.zip"
  source = "${path.module}/.zip/${module.labels.id}_callback.zip"
}

resource "aws_lambda_function" "callback" {
  s3_bucket        = (var.callback_lambda_s3_bucket != "" ? var.callback_lambda_s3_bucket : aws_s3_bucket_object.callback_s3_file.bucket)
  s3_key           = (var.callback_lambda_s3_key != "" ? var.callback_lambda_s3_key : aws_s3_bucket_object.callback_s3_file.key)
  function_name    = "${module.labels.id}-callback"
  source_code_hash = (var.callback_lambda_s3_key != "" ? "" : data.archive_file.callback.output_base64sha256)
  role             = aws_iam_role.callback.arn
  runtime          = "nodejs10.x"
  handler          = "callback.handler"
  memory_size      = 128
  timeout          = 15
  tags             = module.labels.tags

  depends_on = [aws_cloudwatch_log_group.callback]

  vpc_config {
    security_group_ids = [module.lambda_sg.id]
    subnet_ids         = module.vpc.private_subnets
  }

  environment {
    variables = {
      CONFIG_VAR_PREFIX = local.config_var_prefix,
      NODE_ENV          = "production"
    }
  }

  lifecycle {
    ignore_changes = [
      source_code_hash,
    ]
  }
}

resource "aws_lambda_event_source_mapping" "callback" {
  event_source_arn = aws_sqs_queue.callback.arn
  function_name    = aws_lambda_function.callback.arn
}
