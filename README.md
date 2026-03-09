# Terraform Azure Windows VM Deployment

This repository provides a complete, production-ready Infrastructure as Code (IaC) setup for deploying a **Windows Virtual Machine** on Azure. It is designed with security and automation as a priority.

## Architecture Overview

The deployment includes the following Azure resources:

* **Resource Group**: Centralized management for all lab components.
* **Networking**: A secure VNet with isolated subnets for workloads and the management layer.
* **Security**: 
    * **Network Security Groups (NSGs)**: Dynamic rules for controlled inbound/outbound traffic.
    * **Azure Key Vault**: Stores VM credentials securely (Usernames/Passwords).
* **Compute**: Windows Server 2022 VM (Standard_B2s, Premium SSD).
* **Access**: **Azure Bastion** host for secure, browser-based RDP access to the VM.
* **Optimization**: Automated daily shutdown schedule at 20:00 (GTB time).

##  Repository Structure

```
├── bootstrap/          # Initial setup for remote state storage
│   └── main.tf         # Creates the Storage Account & Container
└── main/               # Core infrastructure deployment
    └── main.tf         # VNet, Bastion, Key Vault, VM, and NSGs
```

## Deployment Guide

### 1. Bootstrap Remote State
Ensure your Terraform state is stored securely in Azure:
1. Navigate to `/bootstrap`.
2. Run `terraform init` and `terraform apply`.

### 2. Deploy Core Infrastructure
This project uses GitHub Actions for automated deployments.
1. **Create a Feature Branch**: Never work directly on `main`. Create a new branch: `git checkout -b feature-my-update`.
2. **Commit & Push**: Make your changes to the `/main` directory and push your branch to GitHub.
3. **Open a Pull Request**: Submit a Pull Request (PR) to merge your changes into `main`.
4. **Automated Validation**: Once the PR is opened, the GitHub Actions pipeline will trigger a `terraform plan` to validate your changes.
5. **Merge**: Once approved and merged into `main`, the pipeline will automatically execute `terraform apply` to deploy your infrastructure.

## Security & Secrets
Sensitive data such as VM admin credentials are managed via **Azure Key Vault**. This setup ensures that secrets are not exposed in plaintext and are handled securely by the Service Principal during deployment.

## Contribution Policy
This repository is protected. All changes must be submitted via **Pull Requests**. 
Direct pushes to the `main` branch are blocked. Please create a feature branch, submit your changes, and request a review before merging.
