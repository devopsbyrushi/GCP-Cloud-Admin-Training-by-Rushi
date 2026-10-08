
# GCP VPC Peering — Hands-on Lab

**Trainer:** RushiInfotech  
**Platform:** Google Cloud Platform

---

## Lab Objective

In this lab, we will build three VPC networks and understand:

- VPC creation
- Custom subnets
- VM-to-VM communication inside the same VPC
- Firewall rules
- ICMP/Ping testing
- VPC Network Peering
- Communication between different VPCs
- Non-transitive VPC Peering

---

# 1. Lab Architecture

```text
                         GCP PROJECT
                  Rushi GCP VPC Peering Lab


┌───────────────────────────────────────────────┐
│ VPC 1                                        │
│ banking-app-vpc1                             │
│ 10.10.0.0/24                                 │
│                                               │
│ banking-app-subnet1                          │
│                                               │
│  ┌─────────────────┐   ┌─────────────────┐   │
│  │ banking-app-vm1 │◄─►│ banking-app-vm2 │   │
│  │ App Server 1    │   │ App Server 2    │   │
│  └─────────────────┘   └─────────────────┘   │
│                                               │
│       Same VPC / Same Subnet                 │
└───────────────────────┬───────────────────────┘
                        │
                        │ VPC PEERING
                        ▼
┌───────────────────────────────────────────────┐
│ VPC 2                                        │
│ banking-data-vpc2                            │
│ 10.20.0.0/24                                 │
│                                               │
│ banking-data-subnet2                         │
│                                               │
│        ┌──────────────────────┐               │
│        │ banking-data-vm2     │               │
│        │ Data Server          │               │
│        └──────────────────────┘               │
└───────────────────────┬───────────────────────┘
                        │
                        │ VPC PEERING
                        ▼
┌───────────────────────────────────────────────┐
│ VPC 3                                        │
│ banking-monitoring-vpc3                      │
│ 10.30.0.0/24                                 │
│                                               │
│ banking-monitoring-subnet3                   │
│                                               │
│      ┌────────────────────────────┐           │
│      │ banking-monitoring-vm3     │           │
│      │ Monitoring Server          │           │
│      └────────────────────────────┘           │
└───────────────────────────────────────────────┘
```

---

# 2. Network Plan

| VPC | Subnet | CIDR |
|---|---|---|
| `banking-app-vpc1` | `banking-app-subnet1` | `10.10.0.0/24` |
| `banking-data-vpc2` | `banking-data-subnet2` | `10.20.0.0/24` |
| `banking-monitoring-vpc3` | `banking-monitoring-subnet3` | `10.30.0.0/24` |

### VM Plan

| VM | VPC | Purpose |
|---|---|---|
| `banking-app-vm1` | VPC1 | Application Server 1 |
| `banking-app-vm2` | VPC1 | Application Server 2 |
| `banking-data-vm2` | VPC2 | Data Server |
| `banking-monitoring-vm3` | VPC3 | Monitoring Server |

---

# 3. Project Setup

Project ID:

```text
rushi-gcp-vpc-lab-2026
```

Set the project:

```bash
gcloud config set project rushi-gcp-vpc-lab-2026
```

Verify:

```bash
gcloud config get-value project
```

Expected:

```text
rushi-gcp-vpc-lab-2026
```

Enable Compute Engine:

```bash
gcloud services enable compute.googleapis.com
```

---

# 4. Create VPC 1

VPC:

```text
banking-app-vpc1
```

Command:

```bash
gcloud compute networks create banking-app-vpc1 \
  --subnet-mode=custom
```

Verify:

```bash
gcloud compute networks list
```

---

# 5. Create VPC 1 Subnet

Subnet:

```text
banking-app-subnet1
```

CIDR:

```text
10.10.0.0/24
```

Command:

```bash
gcloud compute networks subnets create banking-app-subnet1 \
  --network=banking-app-vpc1 \
  --region=us-central1 \
  --range=10.10.0.0/24
```

Verify:

```bash
gcloud compute networks subnets list
```

---

# 6. Create VPC 2

VPC:

```text
banking-data-vpc2
```

Command:

```bash
gcloud compute networks create banking-data-vpc2 \
  --subnet-mode=custom
```

---

# 7. Create VPC 2 Subnet

Subnet:

```text
banking-data-subnet2
```

CIDR:

```text
10.20.0.0/24
```

Command:

```bash
gcloud compute networks subnets create banking-data-subnet2 \
  --network=banking-data-vpc2 \
  --region=us-central1 \
  --range=10.20.0.0/24
```

---

# 8. Create VPC 3

VPC:

```text
banking-monitoring-vpc3
```

Command:

```bash
gcloud compute networks create banking-monitoring-vpc3 \
  --subnet-mode=custom
```

---

# 9. Create VPC 3 Subnet

Subnet:

```text
banking-monitoring-subnet3
```

CIDR:

```text
10.30.0.0/24
```

Command:

```bash
gcloud compute networks subnets create banking-monitoring-subnet3 \
  --network=banking-monitoring-vpc3 \
  --region=us-central1 \
  --range=10.30.0.0/24
```

---

# 10. Verify All VPCs and Subnets

List VPCs:

```bash
gcloud compute networks list
```

Expected:

```text
banking-app-vpc1
banking-data-vpc2
banking-monitoring-vpc3
```

List subnets:

```bash
gcloud compute networks subnets list
```

Expected:

```text
banking-app-subnet1
banking-data-subnet2
banking-monitoring-subnet3
```

---

# 11. Create VM1 — Application Server 1

VM:

```text
banking-app-vm1
```

Command:

```bash
gcloud compute instances create banking-app-vm1 \
  --zone=us-central1-a \
  --machine-type=e2-micro \
  --network=banking-app-vpc1 \
  --subnet=banking-app-subnet1 \
  --tags=banking-app
```

---

# 12. Create VM2 — Application Server 2

VM2 will be created in the **same VPC and same subnet** as VM1.

```bash
gcloud compute instances create banking-app-vm2 \
  --zone=us-central1-a \
  --machine-type=e2-micro \
  --network=banking-app-vpc1 \
  --subnet=banking-app-subnet1 \
  --tags=banking-app
```

Architecture:

```text
banking-app-vpc1
       |
       └── banking-app-subnet1
                |
                ├── banking-app-vm1
                |
                └── banking-app-vm2
```

---

# 13. Create VM3 — Data Server

VM:

```text
banking-data-vm2
```

Command:

```bash
gcloud compute instances create banking-data-vm2 \
  --zone=us-central1-a \
  --machine-type=e2-micro \
  --network=banking-data-vpc2 \
  --subnet=banking-data-subnet2 \
  --tags=banking-data
```

---

# 14. Create VM4 — Monitoring Server

VM:

```text
banking-monitoring-vm3
```

Command:

```bash
gcloud compute instances create banking-monitoring-vm3 \
  --zone=us-central1-a \
  --machine-type=e2-micro \
  --network=banking-monitoring-vpc3 \
  --subnet=banking-monitoring-subnet3 \
  --tags=banking-monitoring
```

---

# 15. Verify All VMs

```bash
gcloud compute instances list
```

Get VM private IP addresses:

```bash
gcloud compute instances list \
  --format="table(name,networkInterfaces[0].networkIP,networkInterfaces[0].network)"
```

Example:

```text
NAME                       INTERNAL_IP
banking-app-vm1            10.10.0.2
banking-app-vm2            10.10.0.3
banking-data-vm2           10.20.0.2
banking-monitoring-vm3     10.30.0.2
```

Your actual IP addresses may be different.

---

# 16. Create SSH Firewall Rules

We need SSH access to the VMs.

## VPC1

```bash
gcloud compute firewall-rules create banking-app-allow-ssh \
  --network=banking-app-vpc1 \
  --direction=INGRESS \
  --action=ALLOW \
  --rules=tcp:22 \
  --source-ranges=0.0.0.0/0 \
  --target-tags=banking-app
```

## VPC2

```bash
gcloud compute firewall-rules create banking-data-allow-ssh \
  --network=banking-data-vpc2 \
  --direction=INGRESS \
  --action=ALLOW \
  --rules=tcp:22 \
  --source-ranges=0.0.0.0/0 \
  --target-tags=banking-data
```

## VPC3

```bash
gcloud compute firewall-rules create banking-monitoring-allow-ssh \
  --network=banking-monitoring-vpc3 \
  --direction=INGRESS \
  --action=ALLOW \
  --rules=tcp:22 \
  --source-ranges=0.0.0.0/0 \
  --target-tags=banking-monitoring
```

> For this temporary training lab, `0.0.0.0/0` is used for simplicity. In production, SSH access should be restricted.

---

# 17. Create ICMP Firewall Rules

We will use `ping` to test connectivity.

## VPC1

```bash
gcloud compute firewall-rules create banking-app-allow-icmp \
  --network=banking-app-vpc1 \
  --direction=INGRESS \
  --priority=1000 \
  --action=ALLOW \
  --rules=icmp \
  --source-ranges=10.10.0.0/24,10.20.0.0/24,10.30.0.0/24 \
  --target-tags=banking-app
```

## VPC2

```bash
gcloud compute firewall-rules create banking-data-allow-icmp \
  --network=banking-data-vpc2 \
  --direction=INGRESS \
  --priority=1000 \
  --action=ALLOW \
  --rules=icmp \
  --source-ranges=10.10.0.0/24,10.20.0.0/24,10.30.0.0/24 \
  --target-tags=banking-data
```

## VPC3

```bash
gcloud compute firewall-rules create banking-monitoring-allow-icmp \
  --network=banking-monitoring-vpc3 \
  --direction=INGRESS \
  --priority=1000 \
  --action=ALLOW \
  --rules=icmp \
  --source-ranges=10.10.0.0/24,10.20.0.0/24,10.30.0.0/24 \
  --target-tags=banking-monitoring
```

Verify:

```bash
gcloud compute firewall-rules list
```

---

# 18. Test 1 — VM1 ↔ VM2

Before creating any VPC Peering, we demonstrate communication between two servers in the same VPC.

```text
VPC1
 |
 └── Subnet1
       |
       ├── VM1
       |
       └── VM2
```

SSH to VM1:

```bash
gcloud compute ssh banking-app-vm1 \
  --zone=us-central1-a
```

Ping VM2:

```bash
ping -c 4 <VM2_PRIVATE_IP>
```

Example:

```bash
ping -c 4 10.10.0.3
```

Expected:

```text
VM1 → VM2 ✅
```

Exit:

```bash
exit
```

SSH to VM2:

```bash
gcloud compute ssh banking-app-vm2 \
  --zone=us-central1-a
```

Ping VM1:

```bash
ping -c 4 <VM1_PRIVATE_IP>
```

Expected:

```text
VM2 → VM1 ✅
```

### Result

```text
VM1 ↔ VM2
   ✅

Same VPC
Same Subnet
Private IP Communication
```

---

# 19. Test 2 — Before VPC Peering

Now we have separate VPCs:

```text
VPC1
10.10.0.0/24

VPC2
10.20.0.0/24

VPC3
10.30.0.0/24
```

Before peering:

```text
VPC1 ────X──── VPC2

VPC2 ────X──── VPC3
```

Separate VPCs do not automatically provide the private connectivity we want for this lab.

---

# 20. Create VPC1 ↔ VPC2 Peering

## VPC1 → VPC2

```bash
gcloud compute networks peerings create app-to-data-peering \
  --network=banking-app-vpc1 \
  --peer-network=banking-data-vpc2
```

## VPC2 → VPC1

```bash
gcloud compute networks peerings create data-to-app-peering \
  --network=banking-data-vpc2 \
  --peer-network=banking-app-vpc1
```

Check peering:

```bash
gcloud compute networks peerings list
```

Both peering relationships should become:

```text
ACTIVE
```

---

# 21. Test VPC1 ↔ VPC2

Get the private IP of VM2:

```bash
gcloud compute instances describe banking-data-vm2 \
  --zone=us-central1-a \
  --format="get(networkInterfaces[0].networkIP)"
```

SSH to VM1:

```bash
gcloud compute ssh banking-app-vm1 \
  --zone=us-central1-a
```

Ping the data VM:

```bash
ping -c 4 <DATA_VM_PRIVATE_IP>
```

Expected:

```text
VM1 → VM2
     ✅
```

Now test the reverse direction:

```text
VPC2 → VPC1
       ✅
```

---

# 22. Create VPC2 ↔ VPC3 Peering

## VPC2 → VPC3

```bash
gcloud compute networks peerings create data-to-monitoring-peering \
  --network=banking-data-vpc2 \
  --peer-network=banking-monitoring-vpc3
```

## VPC3 → VPC2

```bash
gcloud compute networks peerings create monitoring-to-data-peering \
  --network=banking-monitoring-vpc3 \
  --peer-network=banking-data-vpc2
```

Check:

```bash
gcloud compute networks peerings list
```

Expected:

```text
app-to-data-peering
data-to-app-peering
data-to-monitoring-peering
monitoring-to-data-peering
```

The relationships should be:

```text
ACTIVE
```

---

# 23. Test VPC2 ↔ VPC3

Get VM3 private IP:

```bash
gcloud compute instances describe banking-monitoring-vm3 \
  --zone=us-central1-a \
  --format="get(networkInterfaces[0].networkIP)"
```

SSH to the data VM:

```bash
gcloud compute ssh banking-data-vm2 \
  --zone=us-central1-a
```

Ping VM3:

```bash
ping -c 4 <VM3_PRIVATE_IP>
```

Expected:

```text
VM2 → VM3
     ✅
```

Test reverse direction:

```text
VM3 → VM2
     ✅
```

---

# 24. Demonstrate Non-Transitive Peering

Our current architecture:

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

We have:

```text
VPC1 ↔ VPC2    ✅

VPC2 ↔ VPC3    ✅
```

But we have NOT created:

```text
VPC1 ↔ VPC3
```

Therefore:

```text
VPC1 → VPC3    ❌
```

### Important Concept

> **VPC Network Peering is not transitive.**

VPC2 cannot be used as a transit network between VPC1 and VPC3.

---

# 25. Final Connectivity Matrix

| Source | Destination | Result |
|---|---|---|
| `banking-app-vm1` | `banking-app-vm2` | ✅ |
| `banking-app-vm2` | `banking-app-vm1` | ✅ |
| VPC1 | VPC2 | ✅ |
| VPC2 | VPC1 | ✅ |
| `banking-data-vm2` | `banking-monitoring-vm3` | ✅ |
| `banking-monitoring-vm3` | `banking-data-vm2` | ✅ |
| VPC1 | VPC3 | ❌ |

---

# 26. Verification Commands

### List VPCs

```bash
gcloud compute networks list
```

### List Subnets

```bash
gcloud compute networks subnets list
```

### List VMs

```bash
gcloud compute instances list
```

### List Firewall Rules

```bash
gcloud compute firewall-rules list
```

### List VPC Peerings

```bash
gcloud compute networks peerings list
```

### Get VM Private IP

```bash
gcloud compute instances describe VM_NAME \
  --zone=us-central1-a \
  --format="get(networkInterfaces[0].networkIP)"
```

---

# 27. Final Architecture

```text
                    VPC PEERING LAB


┌───────────────────────────────────────┐
│ VPC1                                  │
│ banking-app-vpc1                      │
│ 10.10.0.0/24                          │
│                                       │
│  VM1 ◄──────────────► VM2             │
│                                       │
│      SAME VPC / SAME SUBNET           │
└───────────────────┬───────────────────┘
                    │
                    │ PEERING
                    ▼
┌───────────────────────────────────────┐
│ VPC2                                  │
│ banking-data-vpc2                     │
│ 10.20.0.0/24                          │
│                                       │
│          banking-data-vm2             │
└───────────────────┬───────────────────┘
                    │
                    │ PEERING
                    ▼
┌───────────────────────────────────────┐
│ VPC3                                  │
│ banking-monitoring-vpc3               │
│ 10.30.0.0/24                          │
│                                       │
│      banking-monitoring-vm3           │
└───────────────────────────────────────┘


VM1 ↔ VM2              ✅
Same VPC / Same Subnet


VPC1 ↔ VPC2            ✅
VPC Peering


VPC2 ↔ VPC3            ✅
VPC Peering


VPC1 ↔ VPC3            ❌
Not Transitive
```

---

# 28. Key Interview Points

### 1. What is VPC Peering?

VPC Network Peering provides private connectivity between two VPC networks.

### 2. Can separate VPCs communicate automatically?

No. A suitable connectivity mechanism is required.

### 3. Is VPC Peering transitive?

No.

### 4. If VPC1 ↔ VPC2 and VPC2 ↔ VPC3, can VPC1 communicate with VPC3?

No.

### 5. Can VPCs with overlapping IP ranges be peered?

Overlapping subnet ranges are not supported for standard VPC Network Peering.

### 6. Are firewall rules shared between peered VPCs?

No. Each VPC maintains its own firewall rules.

---

