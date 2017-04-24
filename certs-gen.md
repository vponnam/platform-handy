### cert-generation process

##### 1. creating rsa private key 2048 bits
`openssl genrsa -out mykey 2048`

##### 2. generating a csr from rsa key
`openssl req -new -sha256 -key mykey -out mycert.csr`

##### 3. Verifying generated csr
`openssl req -noout -text -in mycert.csr`

##### 4. generating public cert outof csr (certificate signing request) 
`openssl x509 -req -days 365 -in mycert.csr -signkey mykey -out mycert.crt`

##### 5. decoding cert
`openssl x509 -in certificate.crt -text -noout`

##### Creating private key and cert with a single stroke
`openssl req -new -newkey rsa:2048 -nodes -out mycert2.csr -keyout mycert2.key`

##### Converting key to rsa format
`openssl rsa -in server.key -out server_rsa.key`