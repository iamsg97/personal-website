# Placeholder parameter so the stack applies cleanly with zero manual setup.
# Set the real value after the first apply (see docs/AWS_HOSTING.md):
#   aws ssm put-parameter --name "/${var.project_name}/resend-api-key" \
#     --type SecureString --value "re_xxx" --overwrite
# Terraform ignores drift on `value` so it won't stomp on that update.
resource "aws_ssm_parameter" "resend_api_key" {
  name  = "/${var.project_name}/resend-api-key"
  type  = "SecureString"
  value = "CHANGE_ME"

  lifecycle {
    ignore_changes = [value]
  }
}
