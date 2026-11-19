# ECS Gatus Deployment

Deployment of the Gatus health monitoring dashboard on AWS using Docker, Terraform, and Amazon ECS Fargate.

**Live Application:** https://gatus.aisaq.co.uk

## Overview

This project containerises and deploys [Gatus](https://github.com/TwiN/gatus), an open-source service health dashboard, on AWS.

- **Containerisation:** Docker image for the Gatus application.
- **Infrastructure:** Terraform with a modular architecture.
- **Orchestration:** Amazon ECS using AWS Fargate.
- **Container Registry:** Amazon Elastic Container Registry (ECR).
- **Load Balancing:** Internet-facing Application Load Balancer (ALB).
- **DNS:** Cloudflare manages the custom domain and DNS records.
- **HTTPS:** AWS Certificate Manager (ACM) provides the certificate used by the ALB HTTPS listener.
- **State Management:** Terraform remote state stored in Amazon S3.

## Architecture

### Architecture Diagram

<!--```text
                         Users
                           |
                           | HTTPS :443
                           v
                 Cloudflare DNS (CNAME)
                gatus.aisaq.co.uk
                           |
                           v
             Application Load Balancer (ALB)
                  Public subnets
                           |
                    HTTPS listener
                  ACM TLS certificate
                           |
                           v
                    ALB Target Group
                           |
                 HTTP to container :8080
                           |
                           v
                    ECS Fargate Service
                           |
                           v
                     ECS Task(s)
                           |
                           v
                    Gatus Container

              Docker image stored in Amazon ECR

       Terraform provisions and manages AWS infrastructure.
       Cloudflare manages DNS and ACM validation records.
       Amazon S3 stores Terraform remote state.
```
-->

### Components

**Network**

- VPC containing public and private subnets.
- Public subnets provide network placement for the internet-facing ALB.
- Subnet and security group configuration controls communication between the ALB and ECS tasks.

**Compute**

- ECS cluster named `gatus-app`.
- ECS service manages the desired number of running application tasks.
- AWS Fargate runs the containers without requiring EC2 instance management.
- The Gatus container listens on port `8080`.

**Container Registry**

- Amazon ECR repository: `gatus-terraform-ecr`.
- Docker images are tagged and pushed to ECR.
- The ECS task definition references the ECR image and its tag.

**Load Balancing**

- Internet-facing Application Load Balancer.
- HTTPS listener on port `443`.
- Target group forwards application traffic to the Gatus container on port `8080`.
- The target group health check is used to determine whether registered tasks can receive traffic.
- ALB access logging is configured with an Amazon S3 bucket.

**DNS & SSL**

- Cloudflare manages the `aisaq.co.uk` DNS zone.
- `gatus.aisaq.co.uk` is configured as a CNAME pointing to the ALB DNS name.
- AWS Certificate Manager provides the TLS certificate for the application hostname.
- Cloudflare DNS validation records are created for ACM certificate validation.
- The ALB terminates HTTPS and forwards requests to the application target group.

**Security & IAM**

- Security groups control traffic to the ALB and ECS tasks.
- The ECS task execution role allows ECS to retrieve the container image from ECR.
- ECR permissions are restricted to the actions required to pull the image.
- The Cloudflare API token is supplied through configuration and should not be committed to Git.

**Terraform State**

- Terraform state is stored remotely in Amazon S3.
- The S3 backend keeps infrastructure state separate from the application source code.
- State files and credentials must not be committed to the repository.

## Repository Structure

The repository uses a Terraform root configuration and separate modules for the main infrastructure components.

```text
ECS-GATUS-APP/
├── Dockerfile
├── README.md
├── provider.tf
├── backend.tf
├── main.tf
├── variables.tf
├── outputs.tf
│
└── modules/
    ├── networking/       # VPC and subnet resources
    ├── sg/               # Security groups
    ├── load-balacing/    # ALB, listener, target group and access logs
    ├── dns/              # ACM certificate and Cloudflare DNS records
    ├── ecr/              # ECR repository
    └── ecs/              # ECS cluster, task definition, IAM and service
```

> The directory is currently named `load-balacing` in the project. The structure above retains that spelling to match the existing Terraform module path.

## Local Development

### Build the Docker Image

From the directory containing the Dockerfile:

```bash
docker build -t gatus-terraform-ecr:latest .
```

### Run the Container Locally

```bash
docker run --rm -p 8080:8080 gatus-terraform-ecr:latest
```

Open the local application at:

```text
http://localhost:8080
```

The container must expose Gatus on port `8080` for this port mapping to work.

## ECR Bootstrap

The ECR repository must exist before the application image can be pushed to it. Create or deploy the repository using the project's ECR Terraform module, then authenticate Docker to the AWS ECR registry.

### Authenticate Docker to ECR

Set the AWS region to the region configured for the project:

```bash
aws ecr get-login-password --region <aws-region> \
  | docker login \
      --username AWS \
      --password-stdin <aws-account-id>.dkr.ecr.<aws-region>.amazonaws.com
```

### Tag and Push the Image

Build the image, tag it with the ECR repository URL and a version identifier, then push it:

```bash
# Build the image
docker build -t gatus-terraform-ecr:latest .

# Tag the image for ECR
docker tag gatus-terraform-ecr:latest \
  <aws-account-id>.dkr.ecr.<aws-region>.amazonaws.com/gatus-terraform-ecr:<image-tag>

# Push the image
docker push \
  <aws-account-id>.dkr.ecr.<aws-region>.amazonaws.com/gatus-terraform-ecr:<image-tag>
```

Use the same image tag in the ECS task definition. A commit SHA is a useful image tag because it identifies the source revision used to build the image. Replace the example values with the AWS account ID, region and tag for your environment.

## Terraform State Management

### S3 Backend Configuration

Terraform uses an Amazon S3 backend to store the project's remote state.

- **Storage:** Amazon S3.
- **Configuration:** Defined in the Terraform backend configuration.
- **Purpose:** Keeps the Terraform state available across working sessions and prevents the state from being tied to one local machine.

Treat Terraform state as sensitive. It can contain resource details and other values that should not be published. Do not commit state files, state backups, credentials or local Terraform working directories to Git.

## Prerequisites

Before deploying the project, make sure you have:

- An AWS account with permissions to manage the required networking, IAM, ECR, ECS, ALB, ACM and S3 resources.
- AWS CLI installed and configured for the intended AWS account.
- Terraform installed.
- Docker installed and running.
- A Cloudflare account with access to the `aisaq.co.uk` DNS zone.
- A Cloudflare API token with the required zone read and DNS edit permissions.
- Access to this GitHub repository.

## Setup Instructions

### 1. Clone the Repository

```bash
git clone <repository-url>
cd ECS-GATUS-APP
```

### 2. Configure AWS

Configure the AWS CLI using your credentials or an approved authentication method:

```bash
aws configure
```

Check which AWS identity is active:

```bash
aws sts get-caller-identity
```

Make sure the configured AWS region matches the region used by the Terraform providers and ECR repository.

### 3. Configure Cloudflare

Create a Cloudflare API token with permissions to read the relevant zone and edit its DNS records. Supply the token securely to the Cloudflare Terraform provider through the environment or your approved secrets-management process.

Do not place the token directly in committed Terraform files or the README.

### 4. Review Terraform Variables

Review `variables.tf` and the root module configuration before deployment. Set the values required for your environment, including:

- AWS region and resource naming values.
- Domain name and Cloudflare DNS hostname.
- ECR repository URL and image tag.
- Networking and subnet configuration.

Keep local variable files containing environment-specific or sensitive values out of version control.

### 5. Initialise and Validate Terraform

Run these commands from the directory containing the root Terraform configuration:

```bash
terraform init
terraform fmt -recursive
terraform validate
```

### 6. Review and Deploy Infrastructure

```bash
terraform plan
terraform apply
```

Review the plan before applying it. Pay particular attention to IAM permissions, security group rules, load balancer listeners, target group settings, DNS records and changes to remote state configuration.

### 7. Build and Push the Application Image

Build the Docker image and push it to the ECR repository using the commands in the **ECR Bootstrap** section. Confirm that the image tag matches the value referenced by the ECS task definition.

### 8. Verify the Deployment

Check the ECS service and tasks, confirm that the ALB target group reports healthy targets, and then open:

```text
https://gatus.aisaq.co.uk
```

## Deployment Flow

The application deployment follows these stages:

1. **Build:** Docker builds the Gatus application image.
2. **Publish:** The image is tagged and pushed to Amazon ECR.
3. **Provision:** Terraform creates and manages the AWS infrastructure.
4. **Run:** ECS Fargate runs the task definition as part of the ECS service.
5. **Register:** The ECS service registers running tasks with the ALB target group.
6. **Route:** The ALB receives HTTPS requests and forwards traffic to the Gatus container on port `8080`.
7. **Resolve:** Cloudflare DNS directs the custom hostname to the ALB.

## Verification & Testing

After deployment, verify each layer rather than checking only whether the application URL opens.

**Docker and ECR**

- Confirm that the image builds successfully.
- Confirm that the expected image tag exists in ECR.
- Confirm that the ECS task definition references the intended image and tag.

**ECS**

- Confirm that the ECS cluster exists.
- Confirm that the ECS service has running tasks and no persistent deployment errors.
- Review task and service events for image-pull, startup or networking errors.
- Confirm that the container port mapping uses port `8080`.

**Load Balancer**

- Confirm that the ALB is active and has the expected public subnets and security group.
- Confirm that the HTTPS listener uses the ACM certificate.
- Confirm that the target group has registered ECS tasks and reports them as healthy.

**DNS and HTTPS**

- Confirm that `gatus.aisaq.co.uk` resolves to the ALB DNS name.
- Confirm that the ACM certificate is issued and attached to the HTTPS listener.
- Open the application using HTTPS and confirm that the Gatus dashboard loads.

## Maintenance

### Check Terraform Outputs

```bash
terraform output
```

Use the outputs to inspect values exposed by the Terraform configuration, such as resource identifiers and the ALB DNS name.

### Check the Current AWS Identity

```bash
aws sts get-caller-identity
```

### Check ECS Service and Task Status

Use the cluster and service names configured in Terraform:

```bash
aws ecs describe-services \
  --cluster gatus-app \
  --services <ecs-service-name> \
  --region <aws-region>
```

### Update the Application Image

After making an application or Docker configuration change:

1. Build a new Docker image.
2. Tag it with a new version identifier, such as the Git commit SHA.
3. Push the image to ECR.
4. Update the image tag referenced by the ECS task definition.
5. Apply the Terraform change and verify that the ECS service deploys the new task successfully.
6. Confirm that the ALB target group reports the new task as healthy.

## Cleanup

To remove the AWS infrastructure managed by Terraform, run the following from the root Terraform directory:

```bash
terraform plan -destroy
terraform destroy
```

Review the resources in the destroy plan before confirming. Destroying the infrastructure can make the live application unavailable and may remove resources that other components depend on. Take care with the remote state bucket and any resources you intend to retain.

## Troubleshooting

**ECS tasks fail to start or cannot pull the image**

- Confirm that the image and tag exist in ECR.
- Check that the task definition uses the correct ECR repository URL and tag.
- Confirm that the ECS task execution role has the required ECR pull permissions.
- Review ECS service events and container logs.

**ALB target group reports unhealthy targets**

- Confirm that the Gatus container listens on port `8080`.
- Check the ECS task definition port mapping and the target group registration.
- Check that the ECS security group allows inbound application traffic from the ALB security group.
- Review the target group's health-check path, port and success-code matcher.

**HTTPS listener or certificate errors**

- Confirm that the ACM certificate is issued and covers `gatus.aisaq.co.uk`.
- Confirm that the HTTPS listener uses the correct certificate ARN.
- Check that Cloudflare ACM validation records exist and are not proxied during validation.

**Cloudflare DNS or API errors**

- Confirm that the API token has zone read and DNS edit permissions for the correct zone.
- Confirm that the Cloudflare provider is receiving the token in the expected format.
- Confirm that the CNAME record points to the ALB DNS name rather than an outdated load balancer address.

**Terraform asks for a certificate ARN**

- Check whether the root module is passing the certificate ARN from the DNS module output into the load-balancer module.
- Remove redundant root-level input variables if the value is already supplied by a module output.

**Terraform state locking or backend errors**

- Confirm that the S3 backend configuration points to the correct bucket and key.
- Check whether another Terraform process is using the same state.
- Do not manually delete a state lock unless you have confirmed that no active Terraform operation is running.

## Technologies

- **Cloud:** AWS (ECS, Fargate, ECR, ALB, ACM, IAM, VPC, S3)
- **Infrastructure as Code:** Terraform
- **Containers:** Docker
- **DNS:** Cloudflare
- **Application:** Gatus
- **State Management:** Terraform S3 backend

## Author

Eid Abokor - [GitHub](https://github.com/EidAbokor1)

## License

Educational project. Gatus is an open-source project; refer to the [Gatus repository](https://github.com/TwiN/gatus) for its licence and project details.
