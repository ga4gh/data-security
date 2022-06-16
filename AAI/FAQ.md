---
layout: page
title: AAI FAQ
permalink: aai-faq
---

## Flows

The following sequence diagrams are included to help explain the intended flows
documented in this specification. These diagrams should be considered non-normative - if there are
any discrepancies between the diagrams and the text of the specification, the text
of the specification will take precedence.

#### What is the complete end to end flow using `/userinfo`?

(last updated June 2022)

The flow as used by Elixir uses the initial *Passport-Scoped OAuth Access Token* as
a token handed to downstream resource servers. These servers can use this token, in conjunction
with a callback to the *Userinfo Endpoint* of the broker, to obtain the *Passport* content in
JSON format.

{% plantuml %}

hide footbox
skinparam BoxPadding 10
skinparam ParticipantPadding 20

box "Researcher"  #eee
actor       "User Agent"                as user
participant Client                      as client
end box

box "AAI"
participant Broker                      as broker
collections "IdP"                       as idps
end box

box "Data Owner"
collections "Visa Issuer(s)"            as issuers
end box

box "Data Holder"
participant "Clearing House"            as clearing
participant "Data"                      as data
end box

==OIDC==

ref over user, client, broker, idps
OIDC flow results in the client holding a *Passport-Scoped OAuth Access Token*.
end ref

==Use==

client -> clearing : Client requests data
note right
{
Authorization: Bearer <Passport-Scoped OAuth Access Token>
}
end note

clearing -> broker : Clearing house asks for passport content
note right
{
Authorization: Bearer <Passport-Scoped OAuth Access Token>
}
end note

group#DeepSkyBlue #LightSkyBlue Informative Only (not defined in this specification)
broker -> issuers : Fetch signed visa(s) for user
broker <- issuers : Return signed visa(s) for user
note right
[
"<visa1>",
"<visa2>"
]
end note
end

clearing <- broker : UserInfo Endpoint returns passport content (plain JSON, not signed JWT)
note right
{
"iss": "https://<issuer-website>/",
"sub": "<subject-identifier>",
"jti": "<token-identifier>",
"ga4gh_passport_v1": [
"<visa1>",
"<visa2>",
...
]
}
end note


note over clearing, data  #FFCCCB
Decision is made to release data using information contained in the
passport - and this decision is coordinated with the data system to
facilitate that actual data release.
end note

client <- clearing : Client is given data


{% endplantuml %}

#### What is the complete end to end flow using token exchange?

(last updated June 2022)

The exchange flow does not ever distribute the initial *Passport-Scoped OAuth Access Token* beyond
the client application. A token exchange operation is executed by the client, in
exchange for a *Passport Token* - or any
other token that may be used downstream to access resources. In this example flow, the
*Passport Token* is included as authorisation in the POST to a DRS server. The token
exchange has also specified a known resource server website that will limit the audience
of the returned token.

{% plantuml %}

hide footbox
skinparam BoxPadding 10
skinparam ParticipantPadding 20

box "Researcher"  #eee
actor       "User Agent"                as user
participant Client                      as client
end box

box "AAI"
participant Broker                      as broker
collections "IdP"                       as idps
end box

box "Data Owner"
collections "Visa Issuer(s)"            as issuers
end box

box "Data Holder"
participant "Clearing House"            as clearing
participant "Data"                      as data
end box

==OIDC==

ref over user, client, broker, idps
OIDC flow results in the client holding a *Passport-Scoped OAuth Access Token*.
end ref

==Exchange==

client -> broker : Token exchange
note right
Content-Type: application/x-www-form-urlencoded

grant_type=urn:ietf:params:oauth:grant-type:token-exchange
requested_token_type=urn:ietf:params:oauth:token-type:jwt
subject_token=<Passport-Scoped OAuth Access Token>
subject_token_type=urn:ietf:params:oauth:token-type:access_token
audience=https://<drs-resource-server-website>/
end note

group#DeepSkyBlue #LightSkyBlue Informative Only (not defined in this specification)
broker -> issuers : Fetch signed visa(s) for user
broker <- issuers : Return signed visa(s) for user
note right
[
"<visa1>",
"<visa2>"
]
end note
end

client <- broker : Token exchange return
note right
{
"access_token": "<passport token (base64 encoded)>",
"issued_token_type": "<TBD>",
"token_type": "Bearer",
"expires_in": 60
}

▼ passport token content decoded from base64 (generally opaque to the client) ▼

{
"typ": TBD,
"alg": "RS256",
"kid": "<key-identifier>"
} .
{
"iss": "https://<issuer-website>/",
"sub": "<subject-identifier>",
"aud": [
"https://<drs-resource-server-website>/"
],
"iat": <seconds-since-epoch>,
"exp": <seconds-since-epoch>,
"jti": "<token-identifier>",
"ga4gh_passport_v1": [
"<visa1>",
"<visa2>",
...
]
} . <secret>
end note

==Use==

client -> clearing : Client requests data
note right
{
REPLACE WITH CORRECT DRS DETAILS
}
end note

note over clearing, data  #FFCCCB
Decision is made to release data using information contained in the
passport token - and this decision is coordinated with the data system to
facilitate that actual data release.
end note

client <- clearing : Client is given data

{% endplantuml %}

### Can a JWT alone be used for authentication even if the spec mostly talks about OIDC Flow?

(last updated ??? 2020)

Yes. This specification allows for groups to organize themselves in many ways.

A trusted group of Brokers and Claims Clearinghouses are permitted to
format `/userinfo` output as a JWT and use that as a means of how their
services communicate. They can also take `/userinfo` JSON output and
format it through some other means into a JWT. Proper due-diligence and
handling of tokens must be followed.

This specification does not prohibit services from using JWTs as authentication
outside of an OIDC flow.

An example: Two different stacks of software all have a similar user-base and
often use the same shared data resource -- a biobank, for instance. The User
authenticates with Biobank Broker on Software stack S1 and gets `/userinfo` output
as a JWT. The JWT includes GA4GH Passport Visas for a Dataset that the Broker holds
permissions for. S1 might not hold the data, S2 might hold the data. The User may
be allowed to bring that JWT to Software Stack S2 and get data authorized by the
claim in the JWT and held by S2, provided that S2 can trust S1 as a valid and
trustworthy client.

This enables two or more software stacks to work together more fluidly than having
the same user authenticate twice across two stacks to access the same data. There
is an assumption that these two software stacks have agreements and risk assessment
in place in order to make this a secure method of authentication and that the User
is aware that they are exchanging information with another stack without
explicit OIDC-style consent.

![JWT-Only Flow between trusted stacks](GA4GH_JWT-only_flow.png)

## Threat Analysis

### What is the danger of using a fully scoped (or audience-less) token in a multi node workflow





## Legacy

### Can the output of `/userinfo` be used as a JWT for Authentication?

The spec says that `/userinfo` may be formatted as a JWT. A Clearinghouse that
sends an access token to a `/userinfo` endpoint might get either JSON or a
formatted and signed JWT from a broker. The JWT can be used downstream as
an authentication mechanism if downstream services like Clearinghouses
support it and know what to do with it. 

It is probable that a special token endpoint will exist in a future
version of this profile that should prevent the `/userinfo` endpoint
from being overloaded.

