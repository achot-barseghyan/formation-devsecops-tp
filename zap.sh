#!/bin/bash

PORT=30180
REPORT_DIR="/var/www/html/zap-reports"
LATEST_REPORT="$REPORT_DIR/latest_zap_report.html"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
TIMESTAMPED_REPORT="$REPORT_DIR/zap_report_$TIMESTAMP.html"

# Ensure the report directory exists
sudo mkdir -p $REPORT_DIR
sudo chmod 755 $REPORT_DIR

# Run the ZAP scan
docker run --rm --memory=8gb -v $REPORT_DIR:/zap/wrk/:rw -t ictu/zap2docker-weekly zap-full-scan.py -I -j -m 10 -T 60 \
  -t http://mytpm.eastus.cloudapp.azure.com:30802/v3/api-docs \
  -r $TIMESTAMPED_REPORT

exit_code=$?

# Create a symlink to the latest report
sudo ln -sf $TIMESTAMPED_REPORT $LATEST_REPORT

echo "Exit Code : $exit_code"

if [[ ${exit_code} -ne 0 ]];  then
    echo "OWASP ZAP Report has either Low/Medium/High Risk. Please check the HTML Report"
    exit 1;
else
    echo "OWASP ZAP did not report any Risk"
fi