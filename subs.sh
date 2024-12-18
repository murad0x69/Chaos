#!/bin/bash

# Download and update domains
#./chaospy.py --download-new
./chaospy.py --download-rewards

if ls | grep ".zip" &> /dev/null; then
	unzip '*.zip' &> /dev/null
	cat *.txt | anew  domains.txtls
	rm *.txt
	################################################################################## Send new domains result to notify
	echo "Hourly scan result $(date +%F-%T)"  | notify -silent -provider telegram
	echo "Total $(wc -l < domains.txtls) new domains found" | notify -silent -provider telegram

	################################################################################## Update nuclei and nuclei-templates
 nuclei -silent -ut
	rm *.zip
	else
	echo "No new programs found" | notify -silent -provider telegram
fi
