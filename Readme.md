# Neurorust

The goal with this project is to eventually deploy a small http app that uses terraform, is written in rust, and has
some AI/ML capabilities to recognize images.

## 🔐 AWS Authentication

Make sure you're using the same region (this uses us-west-2)

### Terraform user in AWS

You just need to create a user in AWS that terraform will use. Assign it a role like this:
```
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "EC2Core",
            "Effect": "Allow",
            "Action": [
                "ec2:RunInstances",
                "ec2:TerminateInstances",
                "ec2:StartInstances",
                "ec2:StopInstances",
                "ec2:CreateTags",
                "ec2:DeleteTags",
                "ec2:CreateSecurityGroup",
                "ec2:AuthorizeSecurityGroupIngress",
                "ec2:AuthorizeSecurityGroupEgress",
                "ec2:RevokeSecurityGroupIngress",
                "ec2:RevokeSecurityGroupEgress",
                "ec2:Describe*"
            ],
            "Resource": "*"
        },
        {
            "Sid": "PassInstanceRole",
            "Effect": "Allow",
            "Action": "iam:PassRole",
            "Resource": "arn:aws:iam::<Your Account Id>:role/neurorust-ec2-role",
            "Condition": {
                "StringEquals": {
                    "iam:PassedToService": "ec2.amazonaws.com"
                }
            }
        }
    ]
}
```

### Authentication

This project uses Terraform to deploy to AWS. You must set the following environment variables:

- `export AWS_ACCESS_KEY_ID=your-access-key-id`
- `export AWS_SECRET_ACCESS_KEY=your-secret-access-key`

I recommend using `aws configure` or a tool like `aws-vault` to manage credentials securely.
Just use the Access Key and Secret associated with the terraform user.