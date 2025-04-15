```
curl https://raw.githubusercontent.com/AWS-First-Cloud-Journey/Lab-000035-DataLake-on-AWS/master/tracks_list.json | aws s3 cp - s3://lab35-datalake-bucket-0804/data/reference_data/tracks_list.json --region us-east-1
```