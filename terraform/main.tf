provider "aws" {
  region = "us-west-2"
  # shared_credentials_file = "~/.aws/credentials"
  # profile                 = "default"
}

resource "aws_iam_user" "test_user" {
  name = "test_user"
}

data "template_file" "test_policy" {
  template = "${file("../templates/policy.json")}"
}

resource "aws_iam_policy" "test_policy" {
  name        = "test_policy"
  path        = "/"
  description = "My test policy"
  policy = "${data.template_file.test_policy.rendered}"
}

resource "aws_iam_policy_attachment" "test_attach" {
  name       = "test-attachment"
  users      = ["${aws_iam_user.test_user.name}"]
  policy_arn = "${aws_iam_policy.test_policy.arn}"
}
