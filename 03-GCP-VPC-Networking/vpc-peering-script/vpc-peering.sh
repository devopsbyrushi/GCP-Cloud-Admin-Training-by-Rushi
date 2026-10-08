#!/bin/bash

# ============================================================
# GCP VPC PEERING LAB
# RushiInfotech
#
# Creates:
#   3 VPC Networks
#   3 Subnets
#   4 VM Instances
#   SSH Firewall Rules
#   ICMP Firewall Rules
#
# VPC1:
#   banking-app-vpc1
#   banking-app-subnet1
#   banking-app-vm1
#   banking-app-vm2
#
# VPC2:
#   banking-data-vpc2
#   banking-data-subnet2
#   banking-data-vm2
#
# VPC3:
#   banking-monitoring-vpc3
#   banking-monitoring-subnet3
#   banking-monitoring-vm3
# ============================================================

set -e

echo "============================================================"
echo "       RushiInfotech - GCP VPC Peering Lab"
echo "============================================================"

# ------------------------------------------------------------
# PROJECT
# ------------------------------------------------------------

PROJECT_ID="rushi-gcp-vpc-lab-2026"
REGION="us-central1"
ZONE="us-central1-a"

echo ""
echo "Setting GCP Project..."
echo "Project: $PROJECT_ID"

gcloud config set project "$PROJECT_ID"

echo ""
echo "Current Project:"
gcloud config get-value project


# ------------------------------------------------------------
# ENABLE COMPUTE ENGINE API
# ------------------------------------------------------------

echo ""
echo "============================================================"
echo "Enabling Compute Engine API"
echo "============================================================"

gcloud services enable compute.googleapis.com


# ------------------------------------------------------------
# VPC 1
# ------------------------------------------------------------

echo ""
echo "============================================================"
echo "STEP 1: Creating VPC 1"
echo "============================================================"

gcloud compute networks create banking-app-vpc1 \
  --subnet-mode=custom


# ------------------------------------------------------------
# VPC 1 SUBNET
# ------------------------------------------------------------

echo ""
echo "Creating VPC 1 Subnet..."

gcloud compute networks subnets create banking-app-subnet1 \
  --network=banking-app-vpc1 \
  --region="$REGION" \
  --range=10.10.0.0/24


# ------------------------------------------------------------
# VPC 2
# ------------------------------------------------------------

echo ""
echo "============================================================"
echo "STEP 2: Creating VPC 2"
echo "============================================================"

gcloud compute networks create banking-data-vpc2 \
  --subnet-mode=custom


# ------------------------------------------------------------
# VPC 2 SUBNET
# ------------------------------------------------------------

echo ""
echo "Creating VPC 2 Subnet..."

gcloud compute networks subnets create banking-data-subnet2 \
  --network=banking-data-vpc2 \
  --region="$REGION" \
  --range=10.20.0.0/24


# ------------------------------------------------------------
# VPC 3
# ------------------------------------------------------------

echo ""
echo "============================================================"
echo "STEP 3: Creating VPC 3"
echo "============================================================"

gcloud compute networks create banking-monitoring-vpc3 \
  --subnet-mode=custom


# ------------------------------------------------------------
# VPC 3 SUBNET
# ------------------------------------------------------------

echo ""
echo "Creating VPC 3 Subnet..."

gcloud compute networks subnets create banking-monitoring-subnet3 \
  --network=banking-monitoring-vpc3 \
  --region="$REGION" \
  --range=10.30.0.0/24


# ------------------------------------------------------------
# CREATE VM1
# ------------------------------------------------------------

echo ""
echo "============================================================"
echo "STEP 4: Creating Application VM1"
echo "============================================================"

gcloud compute instances create banking-app-vm1 \
  --zone="$ZONE" \
  --machine-type=e2-micro \
  --network=banking-app-vpc1 \
  --subnet=banking-app-subnet1 \
  --tags=banking-app


# ------------------------------------------------------------
# CREATE VM2
# ------------------------------------------------------------

echo ""
echo "============================================================"
echo "STEP 5: Creating Application VM2"
echo "============================================================"

gcloud compute instances create banking-app-vm2 \
  --zone="$ZONE" \
  --machine-type=e2-micro \
  --network=banking-app-vpc1 \
  --subnet=banking-app-subnet1 \
  --tags=banking-app


# ------------------------------------------------------------
# CREATE DATA VM
# ------------------------------------------------------------

echo ""
echo "============================================================"
echo "STEP 6: Creating Data VM"
echo "============================================================"

gcloud compute instances create banking-data-vm2 \
  --zone="$ZONE" \
  --machine-type=e2-micro \
  --network=banking-data-vpc2 \
  --subnet=banking-data-subnet2 \
  --tags=banking-data


# ------------------------------------------------------------
# CREATE MONITORING VM
# ------------------------------------------------------------

echo ""
echo "============================================================"
echo "STEP 7: Creating Monitoring VM"
echo "============================================================"

gcloud compute instances create banking-monitoring-vm3 \
  --zone="$ZONE" \
  --machine-type=e2-micro \
  --network=banking-monitoring-vpc3 \
  --subnet=banking-monitoring-subnet3 \
  --tags=banking-monitoring


# ------------------------------------------------------------
# SSH FIREWALL - VPC1
# ------------------------------------------------------------

echo ""
echo "============================================================"
echo "STEP 8: Creating SSH Firewall Rules"
echo "============================================================"

gcloud compute firewall-rules create banking-app-allow-ssh \
  --network=banking-app-vpc1 \
  --direction=INGRESS \
  --action=ALLOW \
  --rules=tcp:22 \
  --source-ranges=0.0.0.0/0 \
  --target-tags=banking-app


# ------------------------------------------------------------
# SSH FIREWALL - VPC2
# ------------------------------------------------------------

gcloud compute firewall-rules create banking-data-allow-ssh \
  --network=banking-data-vpc2 \
  --direction=INGRESS \
  --action=ALLOW \
  --rules=tcp:22 \
  --source-ranges=0.0.0.0/0 \
  --target-tags=banking-data


# ------------------------------------------------------------
# SSH FIREWALL - VPC3
# ------------------------------------------------------------

gcloud compute firewall-rules create banking-monitoring-allow-ssh \
  --network=banking-monitoring-vpc3 \
  --direction=INGRESS \
  --action=ALLOW \
  --rules=tcp:22 \
  --source-ranges=0.0.0.0/0 \
  --target-tags=banking-monitoring


# ------------------------------------------------------------
# ICMP FIREWALL - VPC1
# ------------------------------------------------------------

echo ""
echo "============================================================"
echo "STEP 9: Creating ICMP Firewall Rules"
echo "============================================================"

gcloud compute firewall-rules create banking-app-allow-icmp \
  --network=banking-app-vpc1 \
  --direction=INGRESS \
  --priority=1000 \
  --action=ALLOW \
  --rules=icmp \
  --source-ranges=10.10.0.0/24,10.20.0.0/24,10.30.0.0/24 \
  --target-tags=banking-app


# ------------------------------------------------------------
# ICMP FIREWALL - VPC2
# ------------------------------------------------------------

gcloud compute firewall-rules create banking-data-allow-icmp \
  --network=banking-data-vpc2 \
  --direction=INGRESS \
  --priority=1000 \
  --action=ALLOW \
  --rules=icmp \
  --source-ranges=10.10.0.0/24,10.20.0.0/24,10.30.0.0/24 \
  --target-tags=banking-data


# ------------------------------------------------------------
# ICMP FIREWALL - VPC3
# ------------------------------------------------------------

gcloud compute firewall-rules create banking-monitoring-allow-icmp \
  --network=banking-monitoring-vpc3 \
  --direction=INGRESS \
  --priority=1000 \
  --action=ALLOW \
  --rules=icmp \
  --source-ranges=10.10.0.0/24,10.20.0.0/24,10.30.0.0/24 \
  --target-tags=banking-monitoring


# ------------------------------------------------------------
# VERIFICATION
# ------------------------------------------------------------

echo ""
echo "============================================================"
echo "STEP 10: VPC VERIFICATION"
echo "============================================================"

gcloud compute networks list


echo ""
echo "============================================================"
echo "SUBNET VERIFICATION"
echo "============================================================"

gcloud compute networks subnets list


echo ""
echo "============================================================"
echo "VM VERIFICATION"
echo "============================================================"

gcloud compute instances list


echo ""
echo "============================================================"
echo "VM PRIVATE IP ADDRESSES"
echo "============================================================"

gcloud compute instances list \
  --format="table(name,zone,networkInterfaces[0].networkIP,networkInterfaces[0].network)"


echo ""
echo "============================================================"
echo "FIREWALL VERIFICATION"
echo "============================================================"

gcloud compute firewall-rules list


echo ""
echo "============================================================"
echo "             LAB FOUNDATION COMPLETED"
echo "============================================================"

echo ""
echo "VPCs:"
echo "  banking-app-vpc1"
echo "  banking-data-vpc2"
echo "  banking-monitoring-vpc3"

echo ""
echo "Subnets:"
echo "  banking-app-subnet1        10.10.0.0/24"
echo "  banking-data-subnet2       10.20.0.0/24"
echo "  banking-monitoring-subnet3 10.30.0.0/24"

echo ""
echo "VMs:"
echo "  banking-app-vm1"
echo "  banking-app-vm2"
echo "  banking-data-vm2"
echo "  banking-monitoring-vm3"

echo ""
echo "Next:"
echo "  1. Test VM1 <-> VM2"
echo "  2. Create VPC1 <-> VPC2 peering"
echo "  3. Test VPC1 <-> VPC2"
echo "  4. Create VPC2 <-> VPC3 peering"
echo "  5. Test VPC2 <-> VPC3"
echo "  6. Demonstrate non-transitive peering"

echo ""
echo "============================================================"
echo "                 LAB READY"
echo "============================================================"
