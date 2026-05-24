# Lambda 実行ロール
resource "aws_iam_role" "slack_notifier" {
  name = "slack-notifier-lambda"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "slack_notifier_basic" {
  role       = aws_iam_role.slack_notifier.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

data "archive_file" "slack_notifier" {
  type        = "zip"
  output_path = "${path.module}/lambda/notify_slack.zip"
  source_file = "${path.module}/lambda/notify_slack.py"
}

resource "aws_lambda_function" "slack_notifier" {
  function_name    = "slack-alarm-notifier"
  role             = aws_iam_role.slack_notifier.arn
  handler          = "notify_slack.handler"
  runtime          = "python3.12"
  filename         = data.archive_file.slack_notifier.output_path
  source_code_hash = data.archive_file.slack_notifier.output_base64sha256

  environment {
    variables = {
      SLACK_WEBHOOK_URL = var.slack_webhook_url
    }
  }
}

resource "aws_lambda_permission" "allow_sns" {
  statement_id  = "AllowSNSInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.slack_notifier.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.alarm.arn
}

resource "aws_sns_topic" "alarm" {
  name = "cloudwatch-alarm"
}

resource "aws_sns_topic_subscription" "lambda" {
  topic_arn = aws_sns_topic.alarm.arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.slack_notifier.arn
}

resource "aws_cloudwatch_metric_alarm" "ecs_cpu_high" {
  alarm_name          = "ecs-api-cpu-high"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = 60
  statistic           = "Average"
  threshold           = 5.0
  alarm_description   = "ECS API の CPU 使用率が 5% 以上"
  alarm_actions       = [aws_sns_topic.alarm.arn]
  ok_actions          = [aws_sns_topic.alarm.arn]

  dimensions = {
    ClusterName = aws_ecs_cluster.main.name
    ServiceName = aws_ecs_service.api.name
  }
}

resource "aws_cloudwatch_query_definition" "error_logs" {
  name            = "API/ErrorLogs"
  log_group_names = [aws_cloudwatch_log_group.api.name]
  query_string    = <<-EOQ
      fields @timestamp, level, message, method, path, status_code, exception
      | filter level = "ERROR"
      | sort @timestamp desc
      | limit 100
    EOQ
}
