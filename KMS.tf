resource "aws_kms_key" "ims_app" {
  description = "Customer key"
  enable_key_rotation = true
  is_enabled = true
  deletion_window_in_days = 30
}
resource "aws_kms_alias" "ims_app" {
  name = "alias/ims_app"
  target_key_id = aws_kms_key.ims_app.key_id
}