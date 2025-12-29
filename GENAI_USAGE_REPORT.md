# GenAI Usage Report: Terraform Security Vulnerability Fix

**Date:** December 26, 2025  
**AI Tool Used:** GitHub Copilot (Claude Sonnet 4.5)  
**Additional Usage:** AI assisted with shell scripting validity and best practices

### Shell Scripting Assistance

AI was utilized to validate the install.sh bootstrap script used for EC2 instance initialization. The AI helped identify potential race conditions with apt package manager locks that occur when Ubuntu's automatic update service runs concurrently with the user_data script at boot time. Additionally, AI provided guidance on proper error handling, command chaining, and best practices for shell scripts that run during system initialization.

---

## Summary

We identified a critical security vulnerability in our Terraform configuration where SSH and administrative management ports were exposed to the public internet (`0.0.0.0/0`). Using AI-assisted analysis, we implemented a targeted fix that restricts sensitive ports to trusted administrators while maintaining minimal code changes.

---

## Vulnerability Details

### Issue Identified

**Severity:** Critical  
**Resource:** `aws_security_group.Jenkins-VM-SG`  
**Location:** [terraform/main.tf](terraform/main.tf)

### The Problem

All ports including SSH (22), Jenkins (8080), and SonarQube (9000) were open to the entire internet:

```hcl
ingress = [
  for port in [22, 80, 443, 8080, 9000, 3000] : {
    description      = "inbound rules"
    from_port        = port
    to_port          = port
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]  # ❌ VULNERABILITY: All ports exposed
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    security_groups  = []
    self             = false
  }
]
```

### Security Risks

- **SSH Brute Force Attacks:** Port 22 open to internet enables automated password attacks
- **Unauthorized Admin Access:** Jenkins (8080) and SonarQube (9000) UIs accessible to anyone
- **Data Breach Risk:** Management interfaces can leak sensitive CI/CD data and secrets
- **Compliance Violations:** Fails CIS AWS Benchmark, PCI-DSS, and SOC 2 requirements

---

## AI-Assisted Analysis

### How AI Helped

1. **Identified the vulnerability** by analyzing security group rules
2. **Recommended least-privilege approach** - restrict admin ports, keep web ports public
3. **Provided minimal code change** using conditional logic within existing structure
4. **Suggested parameterization** with `admin_cidr` variable for flexibility

### AI Recommendation
>
> "Separate public-facing ports (80, 443) from administrative ports (22, 8080, 9000, 3000). Use a conditional in the loop to apply `0.0.0.0/0` only to web traffic, while restricting admin access to a parameterized trusted CIDR."

---

## Solution Implemented

### The Fix

Modified the security group rule with a conditional that checks port numbers:

```hcl
ingress = [
  for port in [22, 80, 443, 8080, 9000, 3000] : {
    description      = "inbound rules"
    from_port        = port
    to_port          = port
    protocol         = "tcp"
    cidr_blocks      = port == 80 || port == 443 ? ["0.0.0.0/0"] : [var.admin_cidr]
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    security_groups  = []
    self             = false
  }
]
```

✅ **What Changed:**

- Ports 80, 443: Remain accessible from `0.0.0.0/0` (public web traffic)
- Ports 22, 8080, 9000, 3000: Now restricted to `var.admin_cidr` (trusted admins only)

### New Variable Added

Created [terraform/variables.tf](terraform/variables.tf):

```hcl
variable "admin_cidr" {
  description = "Trusted CIDR block for administrative access"
  type        = string
  default     = "0.0.0.0/0"  # CHANGE THIS in production
}
```

---

## Implementation Steps

### 1. Configure Your Admin CIDR

Create `terraform/terraform.tfvars` with your trusted IP:

```hcl
admin_cidr = "203.0.113.10/32"  # Replace with your actual IP
```

Or set it during apply:

```bash
terraform apply -var="admin_cidr=203.0.113.10/32"
```

### 2. Validate and Apply Changes

```bash
cd terraform
terraform init
terraform validate
terraform plan
terraform apply
```

### 3. Verify Security

Test that:

- ✅ SSH connection works only from your IP
- ✅ Jenkins UI (`:8080`) accessible only from your IP
- ✅ SonarQube (`:9000`) accessible only from your IP
- ✅ Public web ports (`:80`, `:443`) work from anywhere
- ❌ Unauthorized IPs cannot access admin ports

---

## Before vs After

| Port | Service | Before | After |
|------|---------|--------|-------|
| 22 | SSH | `0.0.0.0/0` ❌ | `var.admin_cidr` ✅ |
| 80 | HTTP | `0.0.0.0/0` ✅ | `0.0.0.0/0` ✅ |
| 443 | HTTPS | `0.0.0.0/0` ✅ | `0.0.0.0/0` ✅ |
| 8080 | Jenkins | `0.0.0.0/0` ❌ | `var.admin_cidr` ✅ |
| 9000 | SonarQube | `0.0.0.0/0` ❌ | `var.admin_cidr` ✅ |
| 3000 | Application | `0.0.0.0/0` ❌ | `var.admin_cidr` ✅ |

---

## Lessons Learned

1. **Never expose admin ports publicly** - Always restrict SSH and management UIs to trusted networks
2. **Use conditional logic** - Minimal code changes can have maximum security impact
3. **Parameterize security controls** - Variables make it easy to update trusted sources
4. **Keep audit trail** - Commented vulnerable code serves as documentation
5. **AI accelerates security reviews** - Copilot identified and fixed the issue in minutes

---

## Future Recommendations

- Consider using AWS Systems Manager Session Manager instead of SSH
- Implement IP whitelisting at application level as defense-in-depth
- Enable AWS Security Hub and Config for continuous compliance monitoring
- Use AWS WAF for additional protection on public web ports
- Rotate the `admin_cidr` regularly based on team access patterns

---

## Additional AI Usage
