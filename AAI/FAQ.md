---
layout: page
title: AAI FAQ
permalink: aai-faq
---

A collection of questions (and hopefully useful answers).

{% hr2 %}

## Flows

The following sequence diagrams are included to help explain the intended flows
documented in the accompanying specification. 

### What is the complete end to end flow using token exchange?

(last updated June 2022)

**This flow is the preferred flow for v1.2+ of the specification.**

The exchange flow does not ever distribute the initial *Passport-Scoped Access Token* beyond
the client application. A token exchange operation is executed by the client, in
exchange for a *Passport* JWT that may be used downstream to access resources. In this example flow, the
*Passport* is included as authorization in the POST to a DRS server. The token
exchange has also specified known resources that will limit the audience
of the *Passport*.

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

box "Data Controller"
collections "Visa Issuer(s)"            as issuers
end box

box "Data Holder"
participant "Clearing House"            as clearing
participant "Data"                      as data
end box

==OIDC==

ref over user, client, broker, idps
OIDC flow results in the client holding a *Passport-Scoped Access Token*.
end ref

==Exchange==

client -> broker : Token exchange
note right
(note: for clarity these form values have not actually been URL encoded)
Content-Type: application/x-www-form-urlencoded

grant_type=urn:ietf:params:oauth:grant-type:token-exchange
&requested_token_type=urn:ga4gh:params:oauth:token-type:passport
&subject_token_type=urn:ietf:params:oauth:token-type:access_token
&subject_token=<Passport-Scoped Access Token>
&resource=https://drs.example.com/dataset1
&resource=https://drs.example.com/dataset2
end note

group#DeepSkyBlue #LightSkyBlue Informative Only (not defined in the specification)
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
  "access_token": "<Passport>",
  "issued_token_type": "urn:ga4gh:params:oauth:token-type:passport",
  "token_type": "Bearer",
  "expires_in": 60
}

▼ Passport content as example (decoded from the base64 of the JWT Passport) ▼

{
  "typ": "vnd.ga4gh.passport+jwt",
  "alg": "RS256",
  "kid": "<key-identifier>"
} .
{
  "iss": "https://<issuer-website>",
  "sub": "<subject-identifier>",
  "aud": [
    "https://drs.example.com"
  ],
  "iat": <seconds-since-epoch>,
  "exp": <seconds-since-epoch>,
  "jti": "<token-identifier>",
  "ga4gh_passport_v1": [
    "<visa1>",
    "<visa2>",
    ...
  ]
} . <signature>
end note

==Use==

client -> clearing : Client requests data
note right 
POST /ga4gh/drs/v1/objects/dataset1/access/s3 HTTP/1.1
Host: drs.example.com
Content-Type: application/json

{
  "passports": [
    "<Passport>"
  ]
}
end note

note over clearing, data  #FFCCCB
Decision is made to release data using information contained in the
passport token - and this decision is coordinated with the data system to
facilitate that actual data release.
end note

client <- clearing : Client is given data

{% endplantuml %}

<hr style="width: 10em; margin: 2em auto;"/>   

### What is the complete end to end flow using `/userinfo`?

(last updated June 2022)

**This flow is the flow for v1.0 implementations of the specification.**

The flow as used by Elixir uses the initial *Passport-Scoped Access Token* as
a token handed to downstream resource servers. These servers can use this token, in conjunction
with a callback to the broker's *Userinfo Endpoint*, to obtain the *Passport* content in
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

box "Data Controller"
collections "Visa Issuer(s)"            as issuers
end box

box "Data Holder"
participant "Clearing House"            as clearing
participant "Data"                      as data
end box

==OIDC==

ref over user, client, broker, idps
OIDC flow results in the client holding a *Passport-Scoped Access Token*.
end ref

==Use==

client -> clearing : Client requests data
note right
{
  Authorization: Bearer <Passport-Scoped Access Token>
}
end note

clearing -> broker : Clearing house asks for list of signed visa(s)
note right
{
  Authorization: Bearer <Passport-Scoped Access Token>
}
end note

group#DeepSkyBlue #LightSkyBlue Informative Only (not defined in the specification)
broker -> issuers : Fetch signed visa(s) for user
broker <- issuers : Return signed visa(s) for user
note right
[
  "<visa1>",
  "<visa2>"
]
end note
end

clearing <- broker : UserInfo endpoint returns list of signed visa(s)
note right
{
  "iss": "https://<issuer-website>/",
  "sub": "<subject-identifier>",
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


{% hr2 %}

## Trust

### What's with all the signed passports and visas etc? Why so complex?

(last updated July 2022)

The practical operation of a loosely coupled
federated ecosystem like GA4GH Passports requires establishing trust
relationships between the participating entities (see
[OpenID Connect Federation](https://openid.net/specs/openid-connect-federation-1_0.html)
for an interesting discussion of the properties of multilateral federations).

Any entity that is asked to make a decision about sharing data needs to have apriori
made the decision "which other entities do I trust?". In genomics, a single decision
to allow data sharing might involve simultaneous trusting of
multiple entities - human genomics is complex!

When presented with a
Passport and Visas from entities that they trust - they can rely on the information (claims) provided
to make data sharing decisions. If presented with information from entities that are
untrusted - the content of the message is irrelevant as there is no basis on which to believe
the content.

So we can see that trust is a crucial element of a working federation. How do we establish
these trust relationships?

GA4GH Passports and Visas leverage the mechanisms
present in [JWT](https://datatracker.ietf.org/doc/html/rfc7519) as used
by the [OIDC standards](https://openid.net/specs/openid-connect-core-1_0.html) 
to cryptographically "sign" tokens containing claims. Signed tokens can be
"verified" using public/private keys.


### Why are the Visa claims formatted as JWTs inside the Passport?

(last updated August 2022)

If visas were not signed separately from a Passport, then Clearinghouses would require a high degree of confidence that
the signing Passport Issuer or Broker was accurately representing the contents of Visas from the original Visa Issuer;
there would be no mechanisms to prevent a malicious or defective Passport Issuer from misrepresenting Visa contents.
By signing Visas separately from Passports, we prevent intermediate parties from tampering with Visa contents,
allowing Clearinghouses to safely rely on Visa contents based on their trust relationship with the Visa Issuer.

### What are the ways that key management is done in practice?

(last updated July 2022)

There are a variety of approaches that can be used for key
management for Passports and Visas. We will first detail those that can be used for Passports
and then discuss some extra wrinkles for Visas.

For this discussion we assume there is a concrete JWT from issuer `https://issuer.example.org`
(possibly a Broker *or* a Visa Issuer).

My clearing house service 'trusts' the above issuer to help make data
access decisions - and that trust is stated probably through some sort of explicit
configuration. For our example lets imagine it has a hypothetical YAML configuration file

```yaml
trusted_brokers:
  - https://issuer.example.org
  - https://login.broker.com

trusted_visa_issuers:
  - https://dac.gov.world
``` 
 
The service now wants to verify a Passport or Visa
JWT purporting to be from that issuer.

---

#### Use `jku` in the header of the JWT

The JKU is the URL of a JSON file containing the issuers' public keys.

```json
{
  "iss": "https://issuer.example.org",
  "jku": "https://issuer.example.org/public-keys.json",
  "kid": "key-october-1"
}
```

For our concrete example we say that it is a JSON file residing
at `https://issuer.example.org/public-keys.json` (see
[RFC 7517 "JSON Web Key"](https://datatracker.ietf.org/doc/html/rfc7517)).

**IMPORTANTLY**, for the secure use of this key management technique - the JKU 
**MUST** also be whitelisted as part of the configuration of **OUR** service.
For example, maybe we expand out of service configuration file to include the JKU.

```yaml
trusted_brokers:
  - issuer: https://issuer.example.org
    jku: https://issuer.example.org/public-keys.json

  - issuer: https://login.broker.com
    jku: https://keys.broker.com/set
```

It is **NEVER** valid to even attempt to access a JKU from a JWT header - unless the URL
is already known to belong to the given issuer. See
["JWT Forgery via unvalidated jku parameter"](https://www.invicti.com/web-vulnerability-scanner/vulnerabilities/jwt-forgery-via-unvalidated-jku-parameter/).

To verify a JWT, the content of the JKU file is loaded and the `kid` is
looked up in key set. The signature is validated using the public key found.

Although this configuration requires explicit registration of JKUs, the content
of the key sets can allow the best practice of key rotation.

The content of the JKU file is designed to be cached aggressively - but as long as
the files is fetched every few days/weeks the set of keys
can evolve/rotate.

---

#### Use the `kid` in the header of the JWT along with OIDC Discovery

The [OpenID Connect Discovery](https://openid.net/specs/openid-connect-discovery-1_0.html)
protocol allows the use of the JWT issuer URL - in conjunction with a fetch
of a `/.well-known/openid-configuration` - to look up the location of the public key set file. See
[OpenID Provider Metadata specification](https://openid.net/specs/openid-connect-discovery-1_0.html#ProviderMetadata)
and the `jwks_uri` entry.

As with JKU - it is important that OIDC discovery is limited only to JWT issuer URLs that are
in some way whitelisted. It is **NEVER** valid to perform discovery on an arbitrary issuer
encountered in a JWT. Luckily, the concept of whitelisting issuers is already in some way
inherent to the way trust relationships are established, and hence this whitelist should
already be present in the system.

Also as with JKU, the content of the discovery protocol and key sets can be cached
aggressively. This means that the double step of the discovery protocol is not
required on every JWT verification.


---

#### Exchange public keys beforehand with each trusted entity

This is an approach used by the [NIH](https://www.nih.gov) - and is appropriate if the number
of trusted entities is small - such that the public keys of each trusted entity can be exchanged
out of band (and their rotation/updating can also be managed out of band).

Configuration may be

```yaml
trusted_brokers:
  - issuer: https://issuer.example.org
    keys:
      key-october-1: "ABCDTRTFDSFSDFSF...."

  - issuer: https://login.broker.com
    keys:
      kid123456: "ABCDTRTFDSFSDFSF...."
```

For any `kid`
encountered in a JWT, the corresponding public key is already available for signature validation.

An even safer version of this approach is to perform
the key verification across every public key you hold before even decoding the JWT JSON
and then confirm the `kid`. This avoids ever even needing to JSON decode
data from untrusted entities.

---

#### Requirement for JKU in Visas

When it comes to Visas, there is an extra wrinkle - unlike Brokers, Visa Issuers do not
need to have been part of an OIDC flow. It is possible that the visa issuer URI is not
even a locatable reference
(e.g. `urn:example.com:dac-world-visa-issuer`).

Therefore the OIDC Discovery technique is not appropriate and hence the requirements
of the AAI standard regarding the presence of JKUs.


{% hr2 %}

## Threat Analysis

### What is the danger of using a fully scoped (or audience-less) token in a multi node workflow

The *Passport Scoped Access Token* is
a token that can unlock **all** data that the user is entitled to, and not just
a subset of data needed for any particular analysis. 

The result of this is that if passed to a bad actor (some service that has been
compromised for example) - the bad actor can use the token
for sideways movement amongst the other nodes.

In the below example - a passport has been passed via a compute service to a resource server that
is compromised. The assumption now is that data controlled by that resource
server may be lost. This is bad - but at least the scope of the loss is limited.

However, if the token in use is the *Passport Scoped Access Token* (or any other token
that has no restrictions on use) - the bad actor
can also move sideways in the system to access Dataset #2 and #3 via Resource
Server #B - and not just Dataset #1
that has already been compromised.

The safer alternative is a system where passports can be down-scoped before use -
the Passport that is maliciously being passed from Resource Server #A
to Resource Server #B would then be rejected - because
it would be scoped only for Resource Server #A / Dataset #1. 

{% plantuml %}
left to right direction

rectangle Client 
rectangle "Compute Server #1\ne.g. WES" as Compute
rectangle "Resource Server #A\ne.g. DRS\n (compromised)" as RSA #pink;line:red;line.bold
rectangle "Resource Server #B\ne.g. DRS" as RSB
rectangle "Authorization Server\n(GA4GH Broker)" as Auth
database "Dataset #1\n(assumed\ncompromised)" as DS1 #orange;line:red;line.bold
database "Dataset #2\n(now possibly compromised)" as DS2 #gold;line:red;line.bold
database "Dataset #3\n(now possibly compromised)" as DS3 #gold;line:red;line.bold

[Client] <---right---> [Auth]

[RSA] --> [DS1]
[RSB] --> [DS2]
[RSB] --> [DS3]

[Client] --> [Compute] : asked to run job\n(sending passport downstream)
[Compute] --> [RSA]
[Compute] --> [RSB]

[RSA] -[#red,plain,thickness=16]-> [RSB] : attack

{% endplantuml %}

The addition of audiences to the token, or down-scoping of permissions - possible via token exchange - limits
the scope of damage if the token ends up with a bad actor.

{% hr2 %}

## Client Software

### Use of GA4GH passport/visas in Single Page Apps (SPAs)

A Single Page App (SPA) such as a React/VueJs website
contains all the source of the application in public - and hence cannot
possess a 'secret' in an OIDC flow (the 'secret' is used to prove the identity of the
client software and is an important risk mitigation that prevents unconstrained
use of an accidentally leaked/stolen token).

The registration of a callback URL - in conjunction with the cryptographic techniques
of PKCE - does allow a SPA to safely participate in an OIDC authorization flow - though
it makes weak guarantees regarding the client identity.

However, when it comes to token exchange - there is no equivalent of a registered
callback URL - that can even weakly assert client identity.

It is impossible for the SPA to prove that is correct/desired piece of code
executing the exchange - and not some other system that has somehow captured a
*Passport-Scoped Access Token* from the browser and is making an exchange.

For these reasons, it is recommended at this point that SPAs are not used for
applications where the SPA is solely responsible for the dissemination of
genomic data.

It is possible for a SPA to predominantly execute in browser - but to still use
a (small) backend set of services to execute any OIDC flows and token exchanges. These
backend service *can* retain a secret and hence can prove client identity. These
techniques are recommended for any genomic application that is predominantly deployed
as a SPA.

There is also an emerging standard DPoP
([OAuth 2.0 Demonstrating Proof-of-Possession at the Application Layer](https://datatracker.ietf.org/doc/html/draft-ietf-oauth-dpop-09))
which will be considered for future versions of the AAI specification.

{% hr2 %}

{% comment %}
## Legacy

### Can a JWT alone be used for authentication even if the spec mostly talks about OIDC Flow?

(last updated 2020 - Removed from the 1.2 version of the FAQ. If not missed - then can be deleted entirely in 2.0)

Yes. This specification allows for groups to organize themselves in many ways.

A trusted group of Brokers and Passport Clearinghouses are permitted to
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

![JWT-Only Flow between trusted stacks](./AAI/GA4GH_JWT-only_flow.png)
{% endcomment %}
