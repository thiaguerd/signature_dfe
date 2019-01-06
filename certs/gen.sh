openssl req -newkey rsa:2048 -keyout key.pem -x509 -days 365 -out certificate.pem -subj '/C=US/ST=New York/L=New York/O=IT/OU=Hosting Team/CN=www.domain.com/emailAddress=your@email.com/subjectAltName=domain.com'
openssl x509 -text -noout -in certificate.pem
openssl pkcs12 -inkey key.pem -in certificate.pem -export -out certificate.p12
openssl pkcs12 -in certificate.p12 -noout -info