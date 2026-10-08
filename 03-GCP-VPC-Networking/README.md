# GCP VPC Networking

**Trainer:** Rushi 
**Platform:** Google Cloud Platform (GCP)

---

## 1. What is a VPC?

VPC stands for **Virtual Private Cloud**.

A VPC is a logically isolated network environment in Google Cloud where we can deploy and communicate with resources such as:

- Virtual Machines
- GKE workloads
- Databases
- Load Balancers
- Other cloud resources

A simple way to understand it:

```text
GCP Project
     |
     └── VPC Network
             |
             ├── Subnet
             │     ├── VM
             │     └── VM
             │
             └── Subnet
                   ├── VM
                   └── VM
```

---

# 2. Why Do We Need a VPC?

A VPC provides the networking environment required for cloud resources to communicate.

For example, consider a banking application:

```text
Internet
   |
   ▼
Load Balancer
   |
   ▼
Web Servers
   |
   ▼
Application Servers
   |
   ▼
Database
```

The different components need controlled network communication.

A VPC helps us design this network.

---

# 3. VPC and Subnet

One important concept to remember:

```text
VPC
 |
 ├── Subnet 1
 |
 ├── Subnet 2
 |
 └── Subnet 3
```

### VPC

A VPC is the overall network environment.

### Subnet

A subnet is an IP address range inside a VPC.

In Google Cloud:

> **VPC is global, while a subnet is regional.**

Example:

```text
VPC
 |
 ├── us-central1 subnet
 |
 ├── asia-south1 subnet
 |
 └── europe-west1 subnet
```
---

# 4. Default VPC

When a Google Cloud project is created, it may have a default VPC network depending on the project's configuration and organization policies.

The default network is generally created as an **auto mode VPC**.

For learning, the default VPC is useful.

For production environments, organizations commonly prefer a planned **custom-mode VPC** so that they can explicitly control:

- IP address ranges
- Subnets
- Regions
- Network architecture
- Firewall rules

---

# 5. Custom VPC

For our training labs, we will create custom VPC networks.

Example:

```bash
gcloud compute networks create banking-app-vpc1 \
  --subnet-mode=custom
```

Here:

```text
banking-app-vpc1
        |
        └── Custom VPC
```

---

# 6. Creating a Subnet

Example:

```bash
gcloud compute networks subnets create banking-app-subnet1 \
  --network=banking-app-vpc1 \
  --region=us-central1 \
  --range=10.10.0.0/24
```

Here:

| Parameter | Meaning |
|---|---|
| `banking-app-subnet1` | Subnet name |
| `--network` | VPC network |
| `--region` | Region where subnet is created |
| `--range` | IPv4 CIDR range |

Architecture:

```text
banking-app-vpc1
       |
       └── banking-app-subnet1
             |
             └── 10.10.0.0/24
```

---

# 7. CIDR

CIDR stands for:

**Classless Inter-Domain Routing**

Example:

```text
10.10.0.0/24
```

The `/24` represents the number of network-prefix bits.

IPv4 contains 32 bits.

Therefore:

```text
32 - 24 = 8 host bits
```

Total mathematical addresses:

```text
2^8 = 256
```

### Common CIDR Examples

| CIDR | Total IPv4 Addresses |
|---|---:|
| `/32` | 1 |
| `/31` | 2 |
| `/30` | 4 |
| `/29` | 8 |
| `/28` | 16 |
| `/27` | 32 |
| `/26` | 64 |
| `/25` | 128 |
| `/24` | 256 |
| `/16` | 65,536 |

> Cloud platforms may reserve addresses, so the number of usable/assignable addresses can be smaller than the mathematical total.

---

# 8. Private IP Address Ranges

RFC 1918 defines the commonly used private IPv4 ranges:

```text
10.0.0.0/8

172.16.0.0/12

192.168.0.0/16
```

These addresses are commonly used for internal networking.

Example:

```text
10.10.0.0/24
10.20.0.0/24
10.30.0.0/24
```

---

# 9. Public IP vs Private IP

### Private/Internal IP

Used for communication inside private networks.

Example:

```text
VM1
10.10.0.2
   |
   | Private Communication
   ▼
VM2
10.10.0.3
```

### Public/External IP

Used when a resource needs internet-facing connectivity.

Example:

```text
Internet
   |
   ▼
Public IP
   |
   ▼
VM
```

In a typical application architecture, internal components can communicate using private IP addresses.

```text
Load Balancer
      |
      ▼
Web Server
      |
      ▼
Application Server
      |
      ▼
Database
```

---

# 10. Same VPC Communication

Two VMs inside the same VPC can communicate using their internal IP addresses when routing and firewall rules allow the traffic.

Example:

```text
banking-app-vpc1
10.10.0.0/24
       |
       ├── banking-app-vm1
       │      10.10.0.2
       │
       └── banking-app-vm2
              10.10.0.3
```

Communication:

```text
VM1 ─────────────► VM2
       Private IP
```

This is the first concept we demonstrate in our hands-on lab.

---

# 11. Communication Across Regions

A VPC is global, while subnets are regional.

Therefore, a VPC can contain subnets in different regions.

Example:

```text
                    VPC
                     |
       ┌─────────────┼─────────────┐
       |             |             |
       ▼             ▼             ▼
us-central1     asia-south1    europe-west1
 Subnet          Subnet          Subnet
```

Resources in different regions can communicate when the required routes and firewall rules allow the traffic.

---

# 12. Different VPC Networks

Suppose we have:

```text
VPC1
 |
 └── VM1

VPC2
 |
 └── VM2
```

By default, separate VPC networks do not automatically communicate with each other.

We need a connectivity mechanism.

One option is:

```text
VPC1
 |
 | VPC Peering
 |
 VPC2
```

---

# 13. VPC Network Peering

VPC Network Peering allows two VPC networks to communicate privately.

Example:

```text
VPC1
10.10.0.0/24
   |
   |
   | VPC PEERING
   |
   ▼
VPC2
10.20.0.0/24
```

The VPCs remain separate networks, but routes are exchanged between the peered networks.

Firewall rules still control whether traffic is allowed.

---

# 14. VPC Peering Requirements

When using VPC Network Peering, remember:

### 1. IP ranges must not overlap

Example:

```text
VPC1 → 10.10.0.0/24

VPC2 → 10.20.0.0/24
```

Good.

But:

```text
VPC1 → 10.10.0.0/24

VPC2 → 10.10.0.0/24
```

Overlapping ranges are a problem for peering.

---

### 2. Both VPCs need the peering relationship configured

Example:

```text
VPC1 ─────── VPC2
```

The peering relationship is configured on both sides.

---

### 3. Firewall rules still apply

Peering provides connectivity, but firewall rules determine whether traffic is allowed.

---

### 4. VPC Peering is not transitive

This is one of the most important concepts.

```text
VPC1
  |
  | Peering
  |
 VPC2
  |
  | Peering
  |
 VPC3
```

It does NOT automatically mean:

```text
VPC1 ─────────► VPC3
```

Therefore:

```text
VPC1 ↔ VPC2    ✅

VPC2 ↔ VPC3    ✅

VPC1 ↔ VPC3    ❌
```

This is called:

> **Non-transitive peering**

---

# 15. Firewall Rules

Firewall rules control traffic entering or leaving resources in a VPC.

Example:

```bash
gcloud compute firewall-rules create banking-app-allow-ssh \
  --network=banking-app-vpc1 \
  --direction=INGRESS \
  --action=ALLOW \
  --rules=tcp:22 \
  --source-ranges=0.0.0.0/0 \
  --target-tags=banking-app
```

This allows SSH traffic on TCP port 22 for instances targeted by the `banking-app` tag.

---

# 16. Firewall Priority

Firewall rules have a priority.

Important rule:

> **Lower number = higher priority**

Example:

```text
Priority 900
     ↓
Higher priority

Priority 1000
     ↓
Lower than 900

Priority 1100
     ↓
Lower than 1000
```

Therefore:

```text
900 > 1000 > 1100
```

Here `>` means **higher priority**, not a larger numerical value.

The default priority used when one isn't specified is commonly `1000`.

---

# 17. ICMP

ICMP stands for:

**Internet Control Message Protocol**

ICMP is a network-layer protocol.

It is commonly used for network diagnostics.

For example:

```bash
ping 10.10.0.3
```

Ping commonly uses:

```text
ICMP Echo Request
        ↓
ICMP Echo Reply
```

ICMP does not use TCP or UDP ports.

Therefore, we use:

```bash
--rules=icmp
```

not:

```text
icmp:80
```

---

# 18. Ingress and Egress

### Ingress

Traffic coming **into** a resource.

```text
Internet
   |
   | INGRESS
   ▼
VM
```

### Egress

Traffic going **out** of a resource.

```text
VM
 |
 | EGRESS
 ▼
Internet
```

Example of an egress rule:

```bash
gcloud compute firewall-rules create deny-internet-egress \
  --direction=EGRESS \
  --priority=900 \
  --network=banking-app-vpc1 \
  --action=DENY \
  --rules=tcp:80,tcp:443 \
  --destination-ranges=0.0.0.0/0
```

This is a broad demonstration rule and should not be used casually in production.

---

# 19. VPC Peering Lab

Our hands-on project uses three VPCs.

```text
VPC1
banking-app-vpc1
10.10.0.0/24

VPC2
banking-data-vpc2
10.20.0.0/24

VPC3
banking-monitoring-vpc3
10.30.0.0/24
```

Architecture:

```text
VPC1
 │
 │ PEERING
 ▼
VPC2
 │
 │ PEERING
 ▼
VPC3
```

VMs:

```text
VPC1
 ├── banking-app-vm1
 └── banking-app-vm2

VPC2
 └── banking-data-vm2

VPC3
 └── banking-monitoring-vm3
```

---

# 20. Hands-on Lab

## Create VPC1

```bash
gcloud compute networks create banking-app-vpc1 \
  --subnet-mode=custom
```

## Create VPC1 Subnet

```bash
gcloud compute networks subnets create banking-app-subnet1 \
  --network=banking-app-vpc1 \
  --region=us-central1 \
  --range=10.10.0.0/24
```

## Create VPC2

```bash
gcloud compute networks create banking-data-vpc2 \
  --subnet-mode=custom
```

## Create VPC2 Subnet

```bash
gcloud compute networks subnets create banking-data-subnet2 \
  --network=banking-data-vpc2 \
  --region=us-central1 \
  --range=10.20.0.0/24
```

## Create VPC3

```bash
gcloud compute networks create banking-monitoring-vpc3 \
  --subnet-mode=custom
```

## Create VPC3 Subnet

```bash
gcloud compute networks subnets create banking-monitoring-subnet3 \
  --network=banking-monitoring-vpc3 \
  --region=us-central1 \
  --range=10.30.0.0/24
```

---

# 21. Verification Commands

List VPC networks:

```bash
gcloud compute networks list
```

List subnets:

```bash
gcloud compute networks subnets list
```

List VM instances:

```bash
gcloud compute instances list
```

List firewall rules:

```bash
gcloud compute firewall-rules list
```

List VPC peerings:

```bash
gcloud compute networks peerings list
```

---

# 22. Important Concepts

```text
VPC
 ↓
Global Network

Subnet
 ↓
Regional IP Range

VM
 ↓
Uses Subnet

Firewall
 ↓
Controls Traffic

VPC Peering
 ↓
Connects Separate VPCs

Peering
 ↓
NOT TRANSITIVE
```

---

# 23. Interview Questions

### Q1. What is VPC?

VPC stands for Virtual Private Cloud. It provides a logical network environment for cloud resources.

### Q2. Is VPC regional or global?

A VPC network is global. Subnets are regional.

### Q3. What is a subnet?

A subnet is a regional IP range inside a VPC network.

### Q4. Can two VMs in the same VPC communicate?

Yes, when routing and firewall rules allow the traffic.

### Q5. Can two separate VPCs communicate automatically?

No. A connectivity mechanism such as VPC Peering is required.

### Q6. What is VPC Peering?

VPC Network Peering provides private connectivity between two VPC networks.

### Q7. Is VPC Peering transitive?

No.

### Q8. What happens if two VPCs have overlapping IP ranges?

They cannot be peered using standard VPC Network Peering when the ranges conflict.

### Q9. Does firewall configuration automatically get shared between peered VPCs?

No. Each VPC maintains its own firewall rules.

### Q10. What is ICMP?

ICMP stands for Internet Control Message Protocol and is commonly used for network diagnostics such as ping.

---

# 24. Real-Time Banking Example

A company may separate workloads into different networks:

```text
                    Banking Environment

        Application VPC
        10.10.0.0/24
              |
              | Peering
              ▼
          Data VPC
        10.20.0.0/24
              |
              | Peering
              ▼
       Monitoring VPC
        10.30.0.0/24
```

Application servers communicate with data services using private IP addresses.

Monitoring components can communicate with required systems through explicitly configured network connectivity and firewall rules.

---

# 25. Key Takeaways

Remember these points:

```text
1. VPC = Network environment

2. Subnet = Regional IP range inside VPC

3. VPC = Global

4. Subnet = Regional

5. CIDR = Defines IP range

6. Firewall = Controls traffic

7. ICMP = Used by ping

8. Different VPCs do not automatically communicate

9. VPC Peering provides private connectivity

10. VPC Peering is NOT transitive
```

---

# GCP VPC Networking — End
