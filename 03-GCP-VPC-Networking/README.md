In this lab, we will understand and implement:

- Communication between VMs in the same VPC
- VPC-to-VPC communication using VPC Peering
- VPC Peering between multiple VPCs
- Non-transitive VPC Peering

---

# 1. Lab Architecture

We are using three VPC networks.

```text
VPC 1
banking-app-vpc1
10.10.0.0/24

    ├── banking-app-vm1
    │
    └── banking-app-vm2


                │
                │ VPC PEERING
                ▼


VPC 2
banking-data-vpc2
10.20.0.0/24

    └── banking-data-vm2


                │
                │ VPC PEERING
                ▼


VPC 3
banking-monitoring-vpc3
10.30.0.0/24

    └── banking-monitoring-vm3
```

---

# 2. Network Details

| VPC | Subnet | CIDR |
|---|---|---|
| `banking-app-vpc1` | `banking-app-subnet1` | `10.10.0.0/24` |
| `banking-data-vpc2` | `banking-data-subnet2` | `10.20.0.0/24` |
| `banking-monitoring-vpc3` | `banking-monitoring-subnet3` | `10.30.0.0/24` |

### VMs

| VM | VPC |
|---|---|
| `banking-app-vm1` | VPC1 |
| `banking-app-vm2` | VPC1 |
| `banking-data-vm2` | VPC2 |
| `banking-monitoring-vm3` | VPC3 |

---

# 3. Step 1 — Same VPC Communication

Before VPC Peering, we first verify communication between two VMs in the same VPC.

```text
banking-app-vm1
       │
       │ Same VPC
       │ Same Subnet
       ▼
banking-app-vm2
```

Get private IP addresses:

```bash
gcloud compute instances list \
  --format="table(name,networkInterfaces[0].networkIP,networkInterfaces[0].network)"
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

Expected:

```text
VM1 → VM2 ✅
```

Now test the reverse direction.

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
Same VPC
   ↓
Same Subnet
   ↓
Private IP Communication
```

---

# 4. Step 2 — VPC1 ↔ VPC2 Peering

Now we have:

```text
VPC1
banking-app-vpc1

        │
        │ PEERING
        ▼

VPC2
banking-data-vpc2
```

Create peering from VPC1:

```bash
gcloud compute networks peerings create app-to-data-peering \
  --network=banking-app-vpc1 \
  --peer-network=banking-data-vpc2
```

Create the corresponding peering from VPC2:

```bash
gcloud compute networks peerings create data-to-app-peering \
  --network=banking-data-vpc2 \
  --peer-network=banking-app-vpc1
```

Check status:

```bash
gcloud compute networks peerings list
```

Both peering relationships should become:

```text
ACTIVE
```

---

# 5. Step 3 — Test VPC1 ↔ VPC2

Get the private IP of the data VM:

```bash
gcloud compute instances describe banking-data-vm2 \
  --zone=us-central1-a \
  --format="get(networkInterfaces[0].networkIP)"
```

From VM1:

```bash
ping -c 4 <DATA_VM_PRIVATE_IP>
```

Expected:

```text
VPC1 → VPC2 ✅
```

Test the reverse direction:

```text
VPC2 → VPC1 ✅
```

---

# 6. Step 4 — VPC2 ↔ VPC3 Peering

Now establish the second peering connection.

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

Create peering from VPC2:

```bash
gcloud compute networks peerings create data-to-monitoring-peering \
  --network=banking-data-vpc2 \
  --peer-network=banking-monitoring-vpc3
```

Create the corresponding peering from VPC3:

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

All should be:

```text
ACTIVE
```

---

# 7. Step 5 — Test VPC2 ↔ VPC3

Get VM3 private IP:

```bash
gcloud compute instances describe banking-monitoring-vm3 \
  --zone=us-central1-a \
  --format="get(networkInterfaces[0].networkIP)"
```

From `banking-data-vm2`:

```bash
ping -c 4 <VM3_PRIVATE_IP>
```

Expected:

```text
VM2 → VM3 ✅
```

Test reverse communication:

```text
VM3 → VM2 ✅
```

---

# 8. Step 6 — Non-Transitive Peering

Our current topology is:

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

But we have **not** created:

```text
VPC1 ↔ VPC3
```

Therefore:

```text
VPC1 → VPC3    ❌
```

### Important Concept

> **VPC Network Peering is not transitive.**

VPC2 cannot act as a transit network between VPC1 and VPC3.

---

# 9. Final Connectivity

```text
banking-app-vm1
       │
       │ Same VPC
       ▼
banking-app-vm2
       │
       │
       │ VPC1 ↔ VPC2
       ▼
banking-data-vm2
       │
       │
       │ VPC2 ↔ VPC3
       ▼
banking-monitoring-vm3
```

Expected results:

| Communication | Result |
|---|---|
| VM1 → VM2 | ✅ |
| VM2 → VM1 | ✅ |
| VPC1 → VPC2 | ✅ |
| VPC2 → VPC1 | ✅ |
| VM2 → VM3 | ✅ |
| VM3 → VM2 | ✅ |
| VPC1 → VPC3 | ❌ |

---

# 10. Important Commands

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

---

# 11. Key Interview Points

### What is VPC Peering?

VPC Network Peering provides private connectivity between two VPC networks.

### Can two VPCs communicate without peering?

Not through VPC networking by default. A suitable connectivity mechanism is required.

### Is VPC Peering transitive?

**No.**

### If VPC1 ↔ VPC2 and VPC2 ↔ VPC3, can VPC1 communicate with VPC3?

**No.**

### Do the VPC IP ranges need to be planned carefully?

**Yes.** Overlapping ranges are a major restriction for VPC Peering.

### Are firewall rules automatically shared between peered VPCs?

**No.** Each VPC maintains its own firewall rules.

---

# 12. Final Architecture

```text
                 VPC PEERING LAB


┌──────────────────────────────┐
│ banking-app-vpc1             │
│ 10.10.0.0/24                 │
│                              │
│  VM1 ◄────────────► VM2      │
│                              │
└──────────────┬───────────────┘
               │
               │ PEERING
               ▼
┌──────────────────────────────┐
│ banking-data-vpc2            │
│ 10.20.0.0/24                 │
│                              │
│       banking-data-vm2       │
│                              │
└──────────────┬───────────────┘
               │
               │ PEERING
               ▼
┌──────────────────────────────┐
│ banking-monitoring-vpc3      │
│ 10.30.0.0/24                 │
│                              │
│    banking-monitoring-vm3    │
│                              │
└──────────────────────────────┘


VM1 ↔ VM2             ✅ Same VPC

VPC1 ↔ VPC2           ✅ Peering

VPC2 ↔ VPC3           ✅ Peering

VPC1 ↔ VPC3           ❌ Not Transitive
```

---
