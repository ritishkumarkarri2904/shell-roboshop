#!/bin/bash

SG_ID="sg-05307c98778f1da82" # replace with your security group id
AMI_ID="ami-0220d79f3f480ecf5" # replace with your ami id
ZONE_ID="Z0195337YR0S3O171S0A" # replace with your hosted zone id
DOMAIN_NAME="ritishkumarkarri.fun" # replace with your domain name

for instance in "$@"
do
    INSTANCE_ID=$(aws ec2 run-instances \
        --image-id "$AMI_ID" \
        --instance-type t3.micro \
        --security-group-ids "$SG_ID" \
        --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$instance}]" \
        --query 'Instances[0].InstanceId' \
        --output text)

    if [ "$instance" == "frontend" ]; then
        IP=$(aws ec2 describe-instances \
            --instance-ids "$INSTANCE_ID" \
            --query 'Reservations[].Instances[].PublicIpAddress' \
            --output text)
        RECORD_NAME="$DOMAIN_NAME"  #ritishkumarkarri.fun
    else
        IP=$(aws ec2 describe-instances \
            --instance-ids "$INSTANCE_ID" \
            --query 'Reservations[].Instances[].PrivateIpAddress' \
            --output text)
        RECORD_NAME="$instance.$DOMAIN_NAME" #mongodb.ritishkumarkarri.fun
    fi

    echo "IP Address : $IP"
    
    aws route53 change-resource-record-sets \
    --hosted-zone-id $ZONE_ID \
    --change-batch '
    {
        "Comment": "Updating a record set",
        "Changes": [
            {
                "Action": "UPSERT",
                "ResourceRecordSet": {
                    "Name": "'"$RECORD_NAME"'",
                    "Type": "A",
                    "TTL": 1,
                    "ResourceRecords": [
                        {
                            "Value": "'"$IP"'"
                        }
                    ]
                }
            }
        ]
    }'

    echo "Record updated for $instance"

done