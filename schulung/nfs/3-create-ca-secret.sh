openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout tls.key -out tls.crt -subj "/CN=nginx/O=nginx"

kubectl create secret tls nginx-tls --key tls.key --cert tls.crt -n tt3
