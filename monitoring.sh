#!/bin/bash

# Extend PATH with Go's binary directory
export PATH=$PATH:$(go env GOPATH)/bin

# Create a folder named with today's date
folder_name=$(date +"%d-%m-%Y")
mkdir -p "$folder_name"

# Download and update domains
python chaospy.py --download-new
python chaospy.py --download-rewards

# Process ZIP files if they exist
if ls *.zip &> /dev/null; then
    # Extract ZIP files into the dated folder
    unzip '*.zip' -d "$folder_name" &> /dev/null
    
    # Combine and clean up domain lists
    cat "$folder_name"/*.txt | anew newdomains.md > "$folder_name"/subs.txtls
    cat "$folder_name/subs.txtls" | sed 's/\*.//g' > "$folder_name"/domains.txtls
    
    # Remove temporary files
    rm "$folder_name"/*.txt
    rm *.zip
    
    # Save new subdomains
    cat "$folder_name"/domains.txtls | anew "$folder_name"/newsubs.txtls
    
    # Send notification about new domains
    echo "Hourly scan result $(date +%F-%T)" | notify -silent -provider telegram
    echo "Total $(wc -l < "$folder_name"/domains.txtls) new domains found" | notify -silent -provider telegram
fi
