## Environment variables

Needed for Production, Test and Development modes

### JWT

- `JWT_KEY` Secret that JWT uses to encrypt tokens.
### Hosts
- `CORS_HOST` Host where responses originates. In development or test modes, set it to http://localhost:3000;
if your rails is configured to run in another port, change accordingly.
- `MAIL_HOST` In development, set it to http://localhost:3000; if your rails is configured to run in another port, change accordingly.
### Mailer
- `MAIL_SMTP_ADDR` SMTP Address.
- `MAILER_EMAIL` Email address that will be used to send recovery password email.
- `MAIL_SMTP_PORT` SMTP Port. Default `587`.
- `MAIL_SMTP_USER` Your SMTP User credential.
- `MAIL_SMTP_PASS` Your SMTP Password credential.
- `MAIL_SMTP_AUTH_TYPE` Auth type. Default is `plain`.
### Database (Postgresql)
- `DB_URL` Full connection url with credentials.
### Rails
- `RAILS_MASTER_KEY` Master key used by Rails.

Bear in mind that the Dockerfile is configured to run rails *in production mode*.

## Endpoints

## Public
```
Verb   URI Pattern                           Description                     Params (Form URL Encoded)
POST   /recovery(.:format)                   Check password reset token      token; is required
PATCH  /recovery(.:format)                   Resets password                 token, password, password_confirmation; all required
POST   /reset_password(.:format)             Requests password reset         email; is required
POST   /auth(.:format)                       Authenticate user               email, password; all required
POST   /signup(.:format)                     Creates user account            name, email, password; all required
```
## Authenticated
```
Verb   URI Pattern                            Description                                                                                                              Parameters (Form URL Encoded)
GET    /api/v1/reports(.:format)              Show all Reports (Supports search by description and sorted scopes, see Parameters)                                      description=string, newest_first,oldest_first,updated_recently,updated_oldest =(true|false); all optional
POST   /api/v1/reports(.:format)              Create a Report                                                                                                          description=text, lat=decimal, lng=decimal; all required                                      
GET    /api/v1/reports/:id(.:format)          Show a Report
PATCH  /api/v1/reports/:id(.:format)          Edit/Update a Report                                                                                                     description=text,lat=decimal,lng=decimal,response=text; all optional
PUT    /api/v1/reports/:id(.:format)          Edit/Update a Report                                                                                                      *
DELETE /api/v1/reports/:id(.:format)          Delete a Report
GET    /api/v1/users(.:format)                Show logged User information                                                                                              -
PATCH  /api/v1/users(.:format)                Allows logged User to edit his account information                                                                        name, email, password; all optional;
DELETE /api/v1/users(.:format)                Allows logged Usert to delete his account                                                                                 -
DELETE /auth(.:format)                        Loggout user                                                                                                              -
POST   /refresh(.:format)                     Refresh access token                                                                                                      -
```

## Equivalência entre os modelos definidos na aplicação (inglês) e os requisitados (português); e schema.
```
User            Usuário          --   Schema                     Validation
Name            Nome                  name                       min 13, only alphabetic. Only middle names can be preceded by whitespace
Password        Senha                 password
Email             -                   email                      yes, follows RFC standard

Report          Denúncia      
Description     Descrição             description (text)
Status          -                     status (string)
Latitude        -                     lat (decimal (10,6))
Longitude       -                     lng (decimal (10,6))
Response        Medida adotada        response (text)
```
## Docker
https://github.com/pmop/studious-rotary-phone-docker
