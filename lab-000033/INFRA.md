# Infrastructure Plan for S3 Encryption with CloudTrail and Athena

## Project Overview

This document outlines the infrastructure required for a system that:
1. Uploads encrypted objects to S3 using KMS
2. Records all API activities with CloudTrail
3. Enables data querying using Amazon Athena

## AWS Resources Required

### 1. Key Management Service (KMS)

- **Custom KMS Key**
  - Type: Symmetric encryption key
  - Usage: Encrypt/decrypt S3 objects
  - Rotation: Enabled (annual)
  - Alias: `alias/s3-encryption-key`

### 2. Amazon S3

- **Data Bucket**
  - Name: `<company-prefix>-encrypted-data`
  - Encryption: SSE-KMS (using custom KMS key)
  - Versioning: Enabled
  - Lifecycle policies: Configure based on data retention requirements

- **Athena Query Results Bucket**
  - Name: `<company-prefix>-athena-results`
  - Encryption: SSE-KMS (using same KMS key)

### 3. AWS CloudTrail

- **Trail Configuration**
  - Name: `s3-data-activity-trail`
  - Management events: Enabled
  - Data events: Enabled (for S3 bucket)
  - Multi-region: Yes
  - Log file validation: Enabled
  - Encryption: Enabled (using KMS key)
  - Storage location: Dedicated S3 bucket

- **CloudTrail S3 Bucket**
  - Name: `<company-prefix>-cloudtrail-logs`
  - Encryption: SSE-KMS (using same KMS key)

### 4. Amazon Athena

- **Workgroup**
  - Name: `data-analysis-workgroup`
  - Query result location: Athena results bucket
  - Encryption: Enabled (using KMS key)

- **Database**
  - Name: `cloudtrail_logs`

- **Tables**
  - CloudTrail logs table
  - Any additional tables for specific query patterns

## IAM Resources

### 1. KMS Key Policy

Key policy allowing:
- Key administrators to manage the key
- S3 service to use the key for encryption/decryption
- CloudTrail service to use the key
- Application role to use the key
- Root account access for emergency recovery

### 2. Application IAM Role

- **Name**: `S3DataProcessingRole`
- **Trust Relationship**: EC2, Lambda, or specific AWS services as needed
- **Permissions**:
  - S3 access (read/write to data bucket)
  - KMS permissions (encrypt/decrypt)
  - Athena query permissions
  - CloudTrail read access

### 3. User Group

- **Name**: `DataAnalystsGroup`
- **Permissions**:
  - Policy to assume the application role
  - Direct Athena access (optional)

### 4. S3 Bucket Policies

- Enforce KMS encryption
- Restrict access to authorized roles
- Prevent public access

## Security Controls

1. **Encryption**
   - At-rest: S3 SSE-KMS
   - In-transit: TLS

2. **Access Control**
   - Principle of least privilege
   - Role-based access
   - MFA enforcement for human users

3. **Monitoring**
   - CloudTrail for API activity
   - CloudWatch alarms for suspicious activity
   - KMS key usage metrics

4. **Compliance**
   - Key rotation
   - Access reviews
   - Audit logging

## Implementation Plan

### Phase 1: Foundation
1. Create KMS key with appropriate policy
2. Create IAM roles and groups
3. Create S3 buckets with encryption settings

### Phase 2: Logging & Monitoring
1. Configure CloudTrail
2. Set up CloudWatch alarms
3. Validate logging is working correctly

### Phase 3: Analytics
1. Configure Athena workgroup and database
2. Create tables for CloudTrail logs
3. Develop sample queries

### Phase 4: Testing & Validation
1. Test end-to-end workflow
2. Validate encryption is working
3. Verify CloudTrail is capturing all relevant events
4. Confirm Athena can query encrypted data

## Cost Considerations

- KMS key: $1/month per key
- S3 storage: Based on data volume
- CloudTrail: Based on management/data events volume
- Athena: $5 per TB of data scanned

## Next Steps

1. Finalize resource naming convention
2. Determine exact permissions needed for application
3. Create CloudFormation/Terraform templates
4. Develop deployment pipeline