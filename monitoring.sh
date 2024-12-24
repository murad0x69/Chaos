#!/bin/bash
export PATH=$PATH:$(go env GOPATH)/bin

# Create a folder named with today's date
folder_name=$(date +"%d-%m-%Y")
mkdir -p "$folder_name"

# Download and update domains
./chaospy.py --download-new
./chaospy.py --download-rewards

# Check for zip files and process them
if ls *.zip &> /dev/null; then
    unzip '*.zip' -d "$folder_name" &> /dev/null
    
    # Combine and clean up domains
    cat "$folder_name"/*.txt | anew newdomains.md  > "$folder_name/subs.txtls"
    cat "$folder_name/subs.txtls" | sed 's/\*.//g' > "$folder_name/domains.txtls"
    
    # Clean up temporary files
    rm "$folder_name"/*.txt
    rm *.zip
    # Save new subs
    cat "$folder_name/domains.txtls" | anew "$folder_name/newsubs.txtls"
    
    # Send notifications about new domains
    echo "Hourly scan result $(date +%F-%T)" | notify -silent -provider telegram
    echo "Total $(wc -l < "$folder_name/domains.txtls") new domains found" | notify -silent -provider telegram
fi
