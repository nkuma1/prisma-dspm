#!/bin/bash

# Custom list of AWS regions
aws_regions=("us-east-1" "us-east-2" "us-west-1" "us-west-2" "eu-central-1" "eu-west-1" "eu-west-2" "eu-west-3")

# Services to count
services_to_count=(
  "rds"
  "elasticache"
  "s3"
  "efs"
  "emr"
  "dynamodb"
  "dax"
  "fsx"
  "documentdb"
  "opensearch"
  "redshift"
)

# Print the introduction
echo "We're going to count the following services:"
printf '%s\n' "${services_to_count[@]}"
echo
echo "In the next regions:"
printf '%s\n' "${aws_regions[@]}"
echo
echo "It's going to take approximately 5-10 minutes per account."
echo
echo
echo

# Function to count resources for RDS
count_rds_resources() {
  aws rds describe-db-instances --region $1 | jq '.DBInstances | length'
}

# Function to count resources for ElastiCache
count_elasticache_resources() {
  aws elasticache describe-cache-clusters --region $1 | jq '.CacheClusters | length'
}

# Function to count resources for S3
count_s3_resources() {
  aws s3api list-buckets --region $1 | jq '.Buckets | length'
}

# Function to count resources for EFS
count_efs_resources() {
  aws efs describe-file-systems --region $1 | jq '.FileSystems | length'
}

# Function to count resources for EMR
count_emr_resources() {
  aws emr list-clusters --region $1 | jq '.Clusters | length'
}

# Function to count resources for DynamoDB
count_dynamodb_resources() {
  aws dynamodb list-tables --region $1 | jq '.TableNames | length'
}

# Function to count resources for DAX
count_dax_resources() {
  aws dax describe-clusters --region $1 | jq '.Clusters | length'
}

# Function to count resources for FSx
count_fsx_resources() {
  aws fsx describe-file-systems --region $1 | jq '.FileSystems | length'
}

# Function to count resources for DocumentDB
count_documentdb_resources() {
  aws docdb describe-db-clusters --region $1 | jq '.DBClusters | length'
}

# Function to count resources for OpenSearch
count_opensearch_resources() {
  aws opensearch list-domain-names --region $1 | jq '.DomainNames | length'
}

# Function to count resources for Redshift
count_redshift_resources() {
  aws redshift describe-clusters --region $1 | jq '.Clusters | length'
}

all_services_count=0

for region in "${aws_regions[@]}"; do
  echo "Region: $region"

  total_count=0

  # Iterate over each service
  for service in "${services_to_count[@]}"; do
    count=0

    # Count the resources for the service in the region
    case $service in
      "rds")
        count=$(count_rds_resources $region)
        ;;
      "elasticache")
        count=$(count_elasticache_resources $region)
        ;;
      "s3")
        if [ "$region" = "us-east-1" ]; then
          count=$(count_s3_resources $region)
          echo "  Service: $service    Count: $count"
        fi
        ;;
      "efs")
        count=$(count_efs_resources $region)
        ;;
      "emr")
        count=$(count_emr_resources $region)
        ;;
      "dynamodb")
        count=$(count_dynamodb_resources $region)
        ;;
      "dax")
        count=$(count_dax_resources $region)
        ;;
      "fsx")
        count=$(count_fsx_resources $region)
        ;;
      "documentdb")
        count=$(count_documentdb_resources $region)
        ;;
      "opensearch")
        count=$(count_opensearch_resources $region)
        ;;
      "redshift")
        count=$(count_redshift_resources $region)
        ;;
    esac

    if [ "$service" != "s3" ]; then
      echo "  Service: $service    Count: $count"
    fi

    total_count=$((total_count + count))
  done

  all_services_count=$((all_services_count + total_count))

  echo "  Total Assets for the Region: $total_count"
  echo
done

echo ""
echo "Total Count for the current Account: $all_services_count"
