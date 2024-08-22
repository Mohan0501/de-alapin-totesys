// Creating a terraform IAMS role for transform Lambda
resource "aws_iam_role" "transform_lambda_role" {
    name_prefix = "role-${var.transform_lambda}"
    force_detach_policies = true
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
// //The IAM Policy Document specifies the permissions required for transform Lambda to access cloudwatch
# data "aws_iam_policy_document" "cw_document_transform"{

#     statement {
#       effect = "Allow"
#       actions = ["logs:CreateLogStream","logs:PutLogEvents"]
#       resources = ["arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/${var.transform_lambda}:*",
#                     "arn:aws:logs:eu-west-2:590183674561:log-group:${aws_cloudwatch_log_group.alapin_extract_log_group.name}:*"]
                    
#     }
# }

# //Create the IAM policy using the cloud watch policy document
# resource "aws_iam_policy" "cw_policy_transform" {
#     name_prefix = "cw-policy-${var.transform_lambda}"
#     policy = data.aws_iam_policy_document.cw_document_transform.json
# }

# Attach the existing cw policy to the transform lambda role
resource "aws_iam_role_policy_attachment" "cw_policy_attachment_transform" {
    role = aws_iam_role.transform_lambda_role.name
    policy_arn = aws_iam_policy.cw_policy_allow_logs.arn
  
}

//Set up terraform IAMS permissions for Lambda - S3
// create policy document of using processed_data_bucket in aws s3
data "aws_iam_policy_document" "s3_document_transform"{
    statement {

        effect = "Allow"
        actions = ["s3:PutObject",
                   "s3:GetObject",
                   "s3:ListBucket",
                   "s3:DeleteObject"]

        resources = [
            "${aws_s3_bucket.processed_data_bucket.arn}/*",
            "${aws_s3_bucket.processed_data_bucket.arn}"
        ]       
    }

}


//Create the IAM policy using the s3 policy document for transform lambda assuming role
resource "aws_iam_policy" "s3_policy_transform" {
    name_prefix = "s3-policy-${var.transform_lambda}"
    description = "transform lambda policy for S3 read/write access "
    policy = data.aws_iam_policy_document.s3_document_transform.json
}


# Attach the Policy to the transform lambda assuming role
resource "aws_iam_role_policy_attachment" "s3_policy_attachment_transform" {
    role = aws_iam_role.transform_lambda_role.name
    policy_arn = aws_iam_policy.s3_policy_transform.arn

}
