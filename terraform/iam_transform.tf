// Creating a terraform IAMS role for transform Lambda
resource "aws_iam_role" "transform_lambda_role" {
    name_prefix = "role-${var.transform_lambda}"
    assume_role_policy = <<EOF
    {
        "Version": "2012-10-17",
        "Statement": [
            {
                "Effect": "Allow",
                "Action": [
                    "sts:AssumeRole"
                ],
                "Principal":{
                    "Service": [
                        "lambda.amazonaws.com"
                    ]
                }
            }
        ]
    }
    EOF
}

// Set up terraform IAMS permissions for Lambda - Cloudwatch
// //The IAM Policy Document specifies the permissions required for transform Lambda to access cloudwatch logs and alarms
data "aws_iam_policy_document" "cw_document_lambda_transform"{
    statement{
        effect = "Allow"
        actions = ["logs:CreateLogGroup"]
        resources = ["arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:*"]
    }
    statement {
      effect = "Allow"
      actions = ["logs:CreateLogStream","logs:PutLogEvents"]
      resources = ["arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/*:*",
                "arn:aws:logs:eu-west-2:590183674561:log-group:${aws_cloudwatch_log_group.alapin_extract_log_group.name}:*"]
    #   resources = ["arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/${var.transform_lambda}:*",
    #                 "arn:aws:logs:eu-west-2:590183674561:log-group:${aws_cloudwatch_log_group.alapin_extract_log_group.name}:*"]
    }
    statement {
      effect = "Allow"
      actions = ["cloudwatch:PutMetricData"]
      resources = [ "arn:aws:cloudwatch:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:metric/*/*" ]
    #   resources = [ "arn:aws:cloudwatch:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:metric/${var.metric_namespace}/*" ]

    }
    statement {
      effect = "Allow"
      actions = ["cloudwatch:DescribeAlarms",
        "cloudwatch:PutMetricAlarm",
        "cloudwatch:DeleteAlarms",
        "cloudwatch:DisableAlarmActions",
        "cloudwatch:EnableAlarmActions",
        "cloudwatch:GetMetricData"]
      resources = [ "arn:aws:cloudwatch:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:alarm/*"]
    #   resources = [ "arn:aws:cloudwatch:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:alarm/${var.alarm_name}"]
     
    }
}

//Create the IAM policy using the cloud watch policy document
resource "aws_iam_policy" "cw_policy_lambda_transform" {
    name_prefix = "cw-policy-${var.transform_lambda}"
    policy = data.aws_iam_policy_document.cw_document_lambda_transform.json
}

# Attach the Policy to the transform lambda assume role
resource "aws_iam_role_policy_attachment" "tranform_lambda_role_cw_policy" {
    role = aws_iam_role.transform_lambda_role.name
    policy_arn = aws_iam_policy.cw_policy_lambda_transform.arn
  
}

#######set up iam permissions for cloudwatch using sns
###it is already in iam.tf, anything else need to be added?