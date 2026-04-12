## Step 02 — Server Identity & Pre-Domain Preparation (DC01)

Verified that the server is properly configured with the correct hostname:

- Hostname: DC01

Confirmed system configuration using System Properties:
- Computer Name: DC01
- Workgroup: WORKGROUP (prior to domain creation)

Validated network configuration:

- Static IP: 192.168.56.10
- Subnet: 255.255.255.0
- DNS Server: 192.168.56.10 (configured to support Active Directory and DNS services)

Verified network profile:

- Network Category: Private

Verification was performed using:

- `hostname` to confirm system identity
- `ipconfig /all` to validate full network configuration and DNS assignment
- `Get-NetConnectionProfile` to confirm network type

## Key Takeaways

- Proper server naming must be completed before domain controller promotion
- Domain controllers must use themselves as DNS servers to support Active Directory functionality
- Private network profiles are required for proper domain communication
- Using `ipconfig /all` provides full network visibility, including DNS servers

## Real-World Relevance

In enterprise environments, servers must be fully validated before being promoted to domain controllers. Misconfigured hostnames or DNS settings can lead to authentication failures, group policy issues, and domain communication breakdowns.

DNS configuration is one of the most critical components of Active Directory, as it enables service discovery and domain functionality across the network.