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
    cat "$folder_name/*.txt" | anew newdomains.md > "$folder_name/subs.txtls"
    cat "$folder_name/subs.txtls" | sed 's/\*.//g' > "$folder_name/domains.txtls"
    
    # Remove temporary files
    rm "$folder_name"/*.txt
    rm *.zip
    
    # Save new subdomains
    cat "$folder_name/domains.txtls" | anew "$folder_name/newsubs.txtls"
    
    # Send notification about new domains
    echo "Hourly scan result $(date +%F-%T)" | notify -silent -provider telegram
    echo "Total $(wc -l < "$folder_name/domains.txtls") new domains found" | notify -silent -provider telegram
fi

# Find live hosts/domains using httpx
if [ -s "$folder_name/domains.txtls" ]; then
    # Append domains to a cumulative target file
    cat "$folder_name/domains.txtls" >> "$folder_name/alltargets.txtls"

    # Discover open ports using naabu
    #portlst=$(naabu -l "$folder_name/domains.txtls" -p 80,443,8008,2082,2086,2087,5001,5000,2096 | \
              #cut -d ":" -f2 | anew | tr "\n" "," | sed 's/,$//') &> /dev/null
    
    # Scan for live URLs using httpx
    httpx -l "$folder_name/domains.txtls" -p "$portlst" -fr -fl 0 -o "$folder_name/newurls.txtls" &> /dev/null
    
    # Process newurls.txtls to extract live URLs
cat "$folder_name/newurls.txtls" | cut -d " " -f2 | cut -d "[" -f1 >> "$folder_name/live.txtls"
cat "$folder_name/newurls.txtls" | cut -d " " -f1 >> "$folder_name/live.txtls"

# Remove the intermediate file
rm "$folder_name/newurls.txtls"

# Deduplicate, remove empty lines, and save clean results
cat "$folder_name/live.txtls" | anew | sed '/^$/d' > "$folder_name/newurls.txtls"

# Clean up the temporary live.txtls
rm "$folder_name/live.txtls"

    
    # Notify about live websites
    echo "Total $(wc -l < "$folder_name/newurls.txtls") live websites found" | notify -silent -provider telegram

    # Update cumulative targets
    cat "$folder_name/alltargets.txtls" | anew >> "$folder_name/alltargets2.txtls"
    rm "$folder_name/alltargets.txtls"
    mv "$folder_name/alltargets2.txtls"  "$folder_name/alltargets.txtls"

    # Notify about vulnerability scanning
    echo "Below vulnerabilities $(date +%F-%T)" | notify -silent -provider telegram

    # Perform vulnerability scan using nuclei
    echo "Starting nuclei" | notify -silent -provider telegram
    "$folder_name/newurls.txtls" | nuclei -t /home/max/.local/nuclei-templates/ -severity critical,medium,high,low -rl 30 -c 2  -o "$folder_name/bugs.txt" | notify -silent -provider telegram 
    echo "nuclei completed" | notify -silent -provider telegram
    
    # Clean up new URLs list
    # rm newurls.txtls

else
    # Notify if no new domains are found
    echo "No new domains $(date +%F-%T)" | notify -silent -provider telegram
fi
