#BugBounty automation

subenum() {
	subfinder -d $1 -all -silent |anew $1-subs.txt;
	assetfinder --subs-only $1 |anew $1-subs.txt;
	shuffledns -d $1 -w $wordlists.txt -r $resolvers.txt -silent | $1-subs.txt;
	findomain-linux -t $1 -quiet | anew $1-subs.txt;
	amass enum -d $1 -config ~/.config/amass/config.ini | anew $1-subs.txt;
	gau --subs $1 | unfurl -u domains | anew $1-subs.txt;
	waybackurls $1 | unfurl -u domains | anew $1-subs.txt;
	crobat -s $1 | anew $1-subs.txt
	ctfr.py -d $1 | anew $1-subs.txt 
	cero $1 | anew $1-subs.txt 
}

naabu() {
	naabu -l $1 -port 1-65535 -o -nmap $1-ports.txt
}

alive() {
	httpx -l $1 -o $1-alive.txt
}

httpx_all() {
	httpx -l $1 -td -sc -cl -ct -title -o $1-httpx_all.txt
}

subtake() {
	subzy -targets $1 --hide_fails --verify_ssl | anew sto.txt;
	SubOver -l $1 | anew sto.txt;
}

nuclei() {
	nuclei -l $1 \
	-eid expired-ssl,tls-version,ssl-issuer,deprecated-tls,revoked-ssl-certificate,self-signed-ssl,kubernetes-fake-certificate,ssl-dns-names,weak-cipher-suites,mismatched-ssl-certificate,untrusted-root-certificate,metasploit-c2,openssl-detect,default-ssltls-test-page,wordpress-really-simple-ssl,wordpress-ssl-insecure-content-fixer,cname-fingerprint,mx-fingerprint,txt-fingerprint,http-missing-security-headers,nameserver-fingerprint,caa-fingerprint,ptr-fingerprint,wildcard-postmessage,symfony-fosjrouting-bundle,exposed-sharepoint-list,CVE-2022-1595,CVE-2017-5487,weak-cipher-suites,unauthenticated-varnish-cache-purge,dwr-index-detect,sitecore-debug-page,python-metrics,kubernetes-metrics,loqate-api-key,kube-state-metrics,postgres-exporter-metrics,CVE-2000-0114,node-exporter-metrics,kube-state-metrics,prometheus-log,express-stack-trace,apache-filename-enum,debug-vars,elasticsearch,springboot-loggers \
	-ss template-spray \
	-ept openssh,headers,caa \
	-es info,unknown \
	-rl 150 -c 25 \
	-o $1_nuclei.txt
}

nuclei_all() {
	nuclei -l $1 -severity low,medium,high,critical \
		-t nuclei-templates/ \
		-rl 200 -c 50 -o $1-nuclei.txt
}

ffuf() {
	dom=$(echo $1 | unfurl format %s%d)
	ffuf -c -w wordlists.txt \
		-recursion -recursion-depth 5 \
		-H "User-Agent: Mozilla Firefox Mozilla/5.0" \
		-H "X-Originating-IP: 127.0.0.1" \
		-H "X-Forwarded-For: 127.0.0.1"
		-H "X-Forwarded: 127.0.0.1"
		-H "Forwarded-For: 127.0.0.1"
		-H "X-Remote-IP: 127.0.0.1"
		-H "X-Remote-Addr: 127.0.0.1"
		-H "X-ProxyUser-Ip: 127.0.0.1"
		-H "X-Original-URL: 127.0.0.1"
		-H "Client-IP: 127.0.0.1"
		-H "True-Client-IP: 127.0.0.1"
		-H "Cluster-Client-IP: 127.0.0.1"
		-H "X-ProxyUser-Ip: 127.0.0.1"
		-ac -mc all -of csv -o $1-ffuf.csv
	}

ffuf_multi() {
	ffuf -c -w $1.txt:URL \
	-w $wordlists:FUZZ \
	-u URL/FUZZ \
	-mc all -of json -o $1-ffuf.json
}

ffuf_json_2_txt() {
	cat $1-ffuf.json | jq | grep "url" | sed 's/"//g' | sed 's/url://g' | sed 's/^ *//' | sed 's/,//g' | anew $1-ffuf.txt
}

archive() {
	echo $1 | gau --subs --threads 10 | anew urls;
	echo $1 | waybackurls | anew urls;
	echo $1 | hakrawler -timeout 15 -subs | anew urls;
	katana -u $1 -jc -kf -silent | anew urls;
}

jsfiles() {
	cat $1 | waybackurls | grep -iE '\.js' | grep -iEv '(\.jsp|\.json)' | anew js1;
	cat $1 | gau | grep -iE '\.js' | grep -iEv '(\.jsp|\.json)' | anew js1;
	cat $1 | hakrawler | grep -iE '\.js' | grep -iEv '(\.jsp|\.json)' | anew js1;
	subjs -i $1 | anew js1;
	katana -u $1 -jc -kf -silent | grep -iE '\.js' | grep -iEv '(\.jsp|\.json)' | anew js1;
}
