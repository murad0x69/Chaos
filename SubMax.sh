#!/bin/bash
#input_file="listdomains.txt"

domain=$1

subdomain(){

mkdir -p output_passive_subdomains/$domain >/dev/null

echo "🔁 Started Subfinder"
subfinder -d $domain  -all -recursive -o output_passive_subdomains/$domain/subfinder.txt >/dev/null 
printf "✅ Total subfinder-subdomains   :  $(wc -l output_passive_subdomains/$domain/subfinder.txt)\n\n"

echo "🔁 Started subdominator"
subdominator -d $domain  -o output_passive_subdomains/$domain/subdominator.txt  >/dev/null  
printf "✅ Total subdominator   :  $(wc -l output_passive_subdomains/$domain/subdominator.txt)\n\n" 

echo "🔁 Started assetfinder"
assetfinder -subs-only $domain > output_passive_subdomains/$domain/assetfinder.txt >/dev/null  
printf "✅ Total assetfinder-subdomains :  $(wc -l output_passive_subdomains/$domain/assetfinder.txt)\n\n" 

echo "🔁 Start riddler.io"
curl -s "https://riddler.io/search/exportcsv?q=pld:$domain" | grep -Po "(([\w.-]*)\.([\w]*)\.([A-z]))\w+" | sort -u > output_passive_subdomains/$domain/riddler.txt >/dev/null  
printf "✅ Total riddler-subdomains     :  $(wc -l output_passive_subdomains/$domain/riddler.txt)\n\n" 
echo "🔁 Started Amass"                           ### add your config.ini location
amass enum -passive -norecursive  -d $domain > output_passive_subdomains/$domain/amass.txt >/dev/null  
printf "✅ Total amass-subdomains       :  $(wc -l output_passive_subdomains/$domain/amass.txt)\n\n"  

echo "🔁 Started WaybackMachine"
curl -sk "http://web.archive.org/cdx/search/cdx?url=*.$domain&output=txt&fl=original&collapse=urlkey&page=" | awk -F/ '{gsub(/:.*/, "", $3); print $3}' | sort -u > output_passive_subdomains/$domain/WaybackMachine.txt >/dev/null  
printf "✅ Total WaybackMachine         :  $(wc -l output_passive_subdomains/$domain/WaybackMachine.txt)\n\n"

echo "🔁 Started crt.sh"
curl -sk "https://crt.sh/?q=%.$domain&output=json" | tr ',' '\n' | awk -F'"' '/name_value/ {gsub(/\*\./, "", $4); gsub(/\\n/,"\n",$4);print $4}' > output_passive_subdomains/$domain/crt.txt >/dev/null  
printf "✅ Total crt-subdomains         :  $(wc -l output_passive_subdomains/$domain/crt.txt)\n\n" 

echo "🔁 Started jldc"
curl -s "https://jldc.me/anubis/subdomains/$domain" | grep -Po "((http|https):\/\/)?(([\w.-]*)\.([\w]*)\.([A-z]))\w+" | sort -u > output_passive_subdomains/$domain/jldc.txt >/dev/null  
printf "✅ Total jldc                   :  $(wc -l output_passive_subdomains/$domain/jldc.txt)\n\n" 

echo "🔁 Started findomain"
findomain -t $domain --unique-output output_passive_subdomains/$domain/findomain.txt >/dev/null  
printf "✅ Total findomain                   :  $(wc -l output_passive_subdomains/$domain/findomain.txt)\n\n" 

echo "🔁 Started urlscan"
curl -s "https://urlscan.io/api/v1/search/?q=domain:$domain&size=10000" | jq -r '.results[]?.page?.domain' | grep -E "^[a-zA-Z0-9.-]+\.$domain$" | sort -u > output_passive_subdomains/$domain/urlscan.txt >/dev/null  
printf "✅ Total urlscan                   :  $(wc -l output_passive_subdomains/$domain/urlscan.txt)\n\n" 


echo "🔁 Started rapiddns"
curl -s "https://rapiddns.io/subdomain/$domain?full=1#result" | grep "<td><a" | cut -d '"' -f 2 | grep http | cut -d '/' -f3 | sed 's/#results//g' | sort -u > output_passive_subdomains/$domain/rapiddns.txt >/dev/null  
printf "✅ Total rapiddns                   :  $(wc -l output_passive_subdomains/$domain/rapiddns.txt)\n\n"  

echo "🔁 Started github-subdomains"
github-subdomains  -d $domain  -t config.txt -o output_passive_subdomains/$domain/github-subdomains.txt >/dev/null  
printf "✅ Total github-subdomains                   :  $(wc -l output_passive_subdomains/$domain/github-subdomains.txt)\n\n"

echo "🔁 Started gau"
gau --threads 10 --subs $domain | unfurl -u domains > output_passive_subdomains/$domain/gau.txt >/dev/null  
printf "✅ Total gau                   :  $(wc -l output_passive_subdomains/$domain/gau.txt)\n\n"  

echo "🔁 Started haktrails"
echo "$domain" | haktrails subdomains  > output_passive_subdomains/$domain/haktrails.txt >/dev/null  
printf "✅ Total haktrails                   :  $(wc -l output_passive_subdomains/$domain/haktrails.txt)\n\n" 

echo "🔁 Started gitlab-subdomains"
gitlab-subdomains -d $domain -t config.txt > output_passive_subdomains/$domain/gitlab-subdomains.txt >/dev/null  
printf "✅ Total gitlab-subdomains                   :  $(wc -l output_passive_subdomains/$domain/gitlab-subdomains.txt)\n\n"

echo "🔁 Started cero"
cero $domain > output_passive_subdomains/$domain/cero.txt >/dev/null  
printf "✅ Total cero                   :  $(wc -l output_passive_subdomains/$domain/cero.txt)\n\n" 

echo "🔁 Started alienvault"
curl -s "https://otx.alienvault.com/api/v1/indicators/domain/$domain/url_list?limit=1000&page=100" | grep -o '"hostname": *"[^"]*' | sed 's/"hostname": "//' | sort -u > output_passive_subdomains/$domain/alienvault.txt >/dev/null  
printf "✅ Total alienvault                   :  $(wc -l output_passive_subdomains/$domain/alienvault.txt)\n\n" 

echo "🔁 Started subdomaincenter"
curl "https://api.subdomain.center/?domain=$domain" -s | jq -r '.[]' | sort -u > output_passive_subdomains/$domain/subdomaincenter.txt >/dev/null  
printf "✅ Total subdomaincenter                   :  $(wc -l output_passive_subdomains/$domain/subdomaincenter.txt)\n\n" 

echo "🔁 Started certspotter"
curl -sk "https://api.certspotter.com/v1/issuances?domain=$domain&include_subdomains=true&expand=dns_names" | jq -r '.[].dns_names[]' | sort -u > output_passive_subdomains/$domain/certspotter.txt >/dev/null  
printf "✅ Total certspotter                   :  $(wc -l output_passive_subdomains/$domain/certspotter.txt)\n\n" 


#puredns bruteforce $WORDLISTS $DOMAIN --resolvers $RESOLVERS -q > tmp-certspotter-$domain




cat output_passive_subdomains/$domain/*.txt > output_passive_subdomains/$domain/all-subd.txt 
cat output_passive_subdomains/$domain/all-subd.txt | sort -u > output_passive_subdomains/$domain/uniq-subd.txt 
cat output_passive_subdomains/$domain/uniq-subd.txt | httpx > output_passive_subdomains/$domain/live.txt 

echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"

printf "Total subfinder-subdomains   :  $(wc -l output_passive_subdomains/$domain/subfinder.txt)\n"
printf "Total subdominator   :  $(wc -l output_passive_subdomains/$domain/subdominator.txt)\n\n"
printf "Total assetfinder-subdomains :  $(wc -l output_passive_subdomains/$domain/assetfinder.txt)\n"
printf "Total riddler-subdomains     :  $(wc -l output_passive_subdomains/$domain/riddler.txt)\n"
printf "Total amass-subdomains       :  $(wc -l output_passive_subdomains/$domain/amass.txt)\n"
printf "Total WaybackMachine         :  $(wc -l output_passive_subdomains/$domain/WaybackMachine.txt)\n"
printf "Total crt-subdomains         :  $(wc -l output_passive_subdomains/$domain/crt.txt)\n"
printf "Total jldc                   :  $(wc -l output_passive_subdomains/$domain/jldc.txt)\n"
printf "Total findomain              :  $(wc -l output_passive_subdomains/$domain/findomain.txt)\n\n"
printf "Total rapiddns                   :  $(wc -l output_passive_subdomains/$domain/rapiddns.txt)\n\n"
printf "Total github-subdomains                   :  $(wc -l output_passive_subdomains/$domain/github-subdomains.txt)\n\n"
printf "Total gau                   :  $(wc -l output_passive_subdomains/$domain/gau.txt)\n\n"
printf "Total haktrails                   :  $(wc -l output_passive_subdomains/$domain/haktrails.txt)\n\n"
printf "Total gitlab-subdomains                   :  $(wc -l output_passive_subdomains/$domain/gitlab-subdomains.txt)\n\n"
printf "Total cero                   :  $(wc -l output_passive_subdomains/$domain/cero.txt)\n\n"
printf "Total alienvault                   :  $(wc -l output_passive_subdomains/$domain/alienvault.txt)\n\n"
printf "Total subdomaincenter                   :  $(wc -l output_passive_subdomains/$domain/subdomaincenter.txt)\n\n"
printf "Total certspotter                   :  $(wc -l output_passive_subdomains/$domain/certspotter.txt)\n\n"
printf "Total urlscan                   :  $(wc -l output_passive_subdomains/$domain/urlscan.txt)\n\n" 

echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"

printf "Total all-subdomains  :  $(wc -l output_passive_subdomains/$domain/all-subd.txt)\n"
printf "Total uniq-subdomians :  $(wc -l output_passive_subdomains/$domain/uniq-subd.txt)\n"
printf "Total live-subdomians :  $(wc -l output_passive_subdomains/$domain/live.txt)\n"

echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"

}
subdomain