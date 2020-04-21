## SRP

REST API backend done using Ruby on Rails and Postgresql. Supports jwt authentication. This application was designed from very basic requirements (job technical interview take-home assignment). But with the correct changes, it should serve as a nice backend for a "report something is happening here"-with-GPS-support application, e.g. , report people throwing parties during current lockdown. 

## Table of Contents
- [Environment variables](#environment-variables)
  * [JWT](#jwt)
  * [Hosts](#hosts)
  * [Mailer](#mailer)
  * [Database (Postgresql)](#database--postgresql-)
  * [Rails](#rails)
- [Endpoints](#endpoints)
- [Schema](#schema)
- [Docker](#docker)

## Environment variables

Needed for Production, Test and Development modes

### JWT

Defaults to memory store. If Redis store is preferred, [configure according](https://github.com/tuwukee/jwt_sessions#configuration).
### Hosts
- `CORS_HOST` Host where responses originates. In development or test modes, set it to http://localhost:3000;
if your rails is configured to run in another port, change accordingly.
- `MAIL_HOST` In development, set it to http://localhost:3000; if your rails is configured to run in another port, change accordingly.
- `HOSTURL` Host's URL (http://localhost:3000 in production).
### Mailer
- `MAIL_SMTP_ADDR` SMTP Address.
- `MAILER_EMAIL` Email address that will be used to send recovery password email.
- `MAIL_SMTP_PORT` SMTP Port. Default `587`.
- `MAIL_SMTP_USER` Your SMTP User credential.
- `MAIL_SMTP_PASS` Your SMTP Password credential.
- `MAIL_SMTP_AUTH_TYPE` Auth type. Default is `plain`.
### Database (Postgresql)
- `DATABASE_URL` Full connection url with credentials (production).
- `DATABASE_DEVELOPMENT_URL` Full connection url with credentials (development).
- `DATABASE_TEST_URL` Full connection url with credentials (test).
### Rails
- `RAILS_MASTER_KEY` Master key used by Rails.
## Endpoints
[Go to wiki.](https://github.com/pmop/studious-rotary-phone/wiki)

## Schema
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

[More information on the wiki.](https://github.com/pmop/studious-rotary-phone/wiki)
