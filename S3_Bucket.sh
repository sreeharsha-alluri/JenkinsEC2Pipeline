while true ; do   count=$(aws s3 ls s3://kamailio-bucket-new/ | grep ${1} | wc -l);   if [[ $count == 1 ]] ; then      echo "Image is ready in S3 Bucket...";      break;   fi;   printf "." ; done
