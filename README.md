# AWS Api Gateway Terraform

This project create an api gateway to [ViaCep](https://viacep.com.br) and expose it in a subdomain api (ex: api.example.com)

This project use the following aws resources
- Cognito (user pool)
- Api Gateway
- Certificate Manager (import)
- Route 53

### Configure

> You need to define the following variables

| Variable | Description | Example |
|-----------|---------------|-----------|
| domain_name | The domain has been registered in Route 53 | example.com |
| certificate | The path to file crt | /tmp/cert.crt |
| private_key | The path to file key | /tmp/cert.key |


After configure the variables you can apply. The script will create the following items:
- A cognito user pool with a client configured to oauth2
- An api gateway with two paths
- An api domain
- Import a certificate to certificate manager

### How to use the cep-api

Get a token
```sh
$ curl --location --request POST 'https://api.example.com/test/token' \
--header 'Content-Type: application/x-www-form-urlencoded' \
--data-urlencode 'client_id={client_id}' \
--data-urlencode 'client_secret={client_secret}' \
--data-urlencode 'grant_type=client_credentials' \
--data-urlencode 'scope=cep-api/read'
```

Get address from cep
```sh
$ curl --location --request GET 'https://api.example.com/test/cep/01001000' \
--header 'Authorization: Bearer {token}'
```