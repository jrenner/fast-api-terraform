variable "s3_policy" {

}

resource "aws_iam_role_policy_attachment" "api_attach_s3_policy" {
  role = aws_iam_role.default-role.name
  policy_arn = var.s3_policy.arn
}