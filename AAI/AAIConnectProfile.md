---
layout: page
title: AAI OIDC Profile
permalink: aai-openid-connect-profile
---

### Abstract
{:.no_toc}

This specification defines a profile for using the OpenID Connect protocol
[[OIDC-Core]](#ref-oidc-core)
to provide federated multilateral authorization infrastructure for greater
interoperability between biomedical institutions sharing restricted datasets.  (OpenID Connect is a simple identity layer, on top of the OAuth 2.0 protocol, that supports identity verification and the ability to obtain basic profile information about end users.)

In particular, this specification defines tokens, endpoints, and flows that
enable an OIDC provider (called a [Broker](#term-broker)) to
provide [Passports](#term-passport) and [Visas](#term-visa) to downstream consumers
called [Passport Clearinghouses](#term-passport-clearinghouse).

[Passports](#term-passport) can then be used for authorization purposes by downstream systems.

### Table of Contents
{:.no_toc}

* toc
{:toc}

{% hr2 %}

## Introduction

This specification
leverages OpenID Connect (OIDC) to authenticate researchers
desiring to access clinical and genomic resources from [data
holders]({% link AAI/AAIConnectProfile.md %}#term-data-holder)
adhering to GA4GH standards. Beyond standard OIDC authentication, AAI enables
data holders to obtain security-related attributes and authorizations of those
researchers. The Data Use and Researcher Identity (DURI) Work Stream has developed a standard
representation for researcher authorizations and attributes [[Researcher-ID]](#ref-researcher-ids).

### Technical Summary

At its core, the AAI specification defines cryptographically secure tokens for exchanging
researcher attributes called [Visas](#term-visa), and how various
participants can interact to authenticate researchers, and obtain and validate [Visas](#term-visa).

The main components identified in the specification are:
* [Visa Issuers](#term-visa-issuer), that cryptographically sign researcher attributes in the
  form of [Visas](#term-visa).
* [Brokers](#term-broker), that authenticate researchers and broker access to [Visas](#term-visa) associated
  with researchers.
* [Clients](#term-client), that perform actions that may require data access on behalf of researchers,
  relying on tokens issued by [Brokers](#term-broker) and [Visa Issuers](#term-visa-issuer).
* [Passport Clearinghouses](#term-passport-clearinghouse), that accept tokens containing or
  otherwise availing researcher visas for the purposes of enforcing access control.

### Visa Tokens

The recommended approach to using AAI involves signed JWTs called [Visas](#term-visa),
for securely transmitting authorizations or attributes of a researcher.
[Visas](#term-visa) are signed by the [Visa Issuer](#term-visa-issuer), which may be a service other than
the Broker. Using JWTs signed by private key allows Passport Clearinghouses to
validate [Visas](#term-visa) from known issuers in situations where they may not have
network connections to the issuers.

### Separation of Data Holders and Data Access Committees

It is a fairly common situation that, for a single dataset, the Data Access Committee (DAC) (the authority managing 
who has access to dataset) is not the same party as the
[Data Holder](#term-data-holder) (the organization
that hosts the data, while respecting the DAC's access policies).

For these situations, AAI is a standard mechanism for data holders to obtain
and validate authorizations from DACs, by specifying the interactions
between [Visa Issuers](#term-visa-issuer), [Brokers](#term-broker), and 
[Passport Clearinghouses](#term-passport-clearinghouse).

The AAI standard enables [Data Holders](#term-data-holder) and [Visa Issuers](#term-visa-issuer) to recognize
and accept identities from multiple [Brokers](#term-broker) --- allowing for an even more federated
approach. An organization can still use this specification with a single 
[Broker](#term-broker) and [Visa Issuer](#term-visa-issuer),
though they may find in that case that there are few benefits beyond standard OIDC.

{% hr2 %}

## Notation and Conventions

Terms defined in [Terminology](#terminology) appear as capitalized 
links, e.g. [Passport](#term-passport).

References to [Relevant Specifications](#relevant-specifications) appear 
as bracket-enclosed links, e.g. [[OIDC-Core]](#ref-oidc-core).

The key words "MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL NOT", "SHOULD",
"SHOULD NOT", "RECOMMENDED", "MAY", and "OPTIONAL" in this specification are to
be interpreted as described in [[RFC2119]](#ref-rfc2119).

{% hr2 %}

## Terminology

This specification inherits terminology from the OpenID
Connect [[OIDC-Core]](#ref-oidc-core) 
and OAuth 2.0 Authorization Framework [[RFC6749]](#ref-rfc6749) specifications.

<a name="term-broker"></a> **Broker** -- An OIDC Provider service that
authenticates a user (potentially by relying on an [Identity Provider](#term-identity-provider)), 
collects user's [Visas](#term-visa) from internal and/or external [Visa Issuers](#term-visa-issuer), 
and provides them to [Passport Clearinghouses](#term-passport-clearinghouse).
Brokers may also be Passport Clearinghouses of other upstream Brokers.

**Claim**{: #term-claim} -- as [defined](https://datatracker.ietf.org/doc/html/rfc7519#section-2) 
by the JWT specification [[RFC7519]](#ref-rfc7519) -- A piece of information asserted about a subject, 
represented as a name/value pair consisting of
a claim name (a string) and a claim value (any JSON value). 

**Client**{: #term-client} -- as discussed in the OAuth 2.0 Authorization Framework [[RFC6749]](#term-rfc6749) specification

<a name="term-data-holder"></a> **Data Holder** -- An organization that
holds a specific set of data (or its copy) and respects
and enforces the Data Access Committee's (DAC's) decisions on who can access it. A DAC
can also be a [Data Holder](#term-data-holder). A [Data Holder](#term-data-holder) runs a
[Passport Clearinghouse](#term-passport-clearinghouse) server at a minimum.

<a name="term-ga4gh-claim"></a>
**GA4GH Claim** -- A [Claim](#term-claim) as defined by a GA4GH
documented technical standard that is making use of this AAI specification. Typically
this is the `ga4gh_passport_v1` or `ga4gh_visa_v1` [Claim](#term-claim) for [Passports v1.x](#term-passport).
A GA4GH Claim is asserted by the entity that signed the token in which it is contained (not by GA4GH).

<a name="term-identity-provider"></a> **Identity Provider (IdP)** -- A
service that provides to users an identity, authenticates it; and provides
assertions to a Broker using standard protocols, such as OpenID Connect, SAML or
other federation protocols. Example: eduGAIN, Google Identity, Facebook, NIH
eRA Commons. IdPs MAY be [Visa Assertion Sources](#term-visa-assertion-source).

**JWT**{: #term-jwt} -- JSON Web Token as defined in [[RFC7519]](#ref-rfc7519).
A JWT contains a set of [Claims](#term-claim).

<a name="term-passport-clearinghouse"></a> **Passport Clearinghouse** -- 
An OIDC Relying Party service that consumes
[Visas](#term-visa) provided by a [Broker](#term-broker), uses them to make an
authorization decision at least in part based on inspecting Visas and
allows access to a specific set of underlying resources in the target
environment or platform. This abstraction allows for a variety of models for
how systems consume these Visas in order to provide access to resources.
Access can be granted by either issuing new access tokens for downstream
services (i.e. the Passport Clearinghouse may act like an authorization server)
or by providing access to the underlying resources directly (i.e. the Passport
Clearinghouse may act like a resource server). Some Passport Clearinghouses may
issue Passports that contain a new set or subset of Visas for downstream consumption.

<a name="term-passport-scoped-access-token"></a> **Passport-Scoped Access Token** --
An OIDC access token with [scope](https://datatracker.ietf.org/doc/html/rfc6749#section-3.3)
including the identifier `ga4gh_passport_v1`.

The access token MUST be a JWS-encoded JWT token containing `openid` and `ga4gh_passport_v1`
entries in the value of its `scope` [Claim](#term-claim).
It is RECOMMENDED that Passport-Scoped Access Tokens follow the JWT Profile for OAuth 2.0 Access Tokens specification [[RFC9068]](#ref-rfc9068).

<a name="term-passport"></a> **Passport** -- A signed and verifiable JWT that contains [Visas](#term-visa).

<a name="term-passport-issuer"></a> **Passport Issuer** --
A service that creates and signs [Passports](#term-passport).

<a name="term-token-endpoint"></a> **Token Endpoint** -- a [Broker](#term-broker)'s implementation of the [[OIDC-Core]](#ref-oidc-core) [Token Endpoint](https://openid.net/specs/openid-connect-core-1_0.html#TokenEndpoint).

<a name="term-token-exchange"></a> **Token Exchange** --
The protocol defined in [[RFC 8693]](#ref-rfc8693) as an extension of OAuth 2.0
for exchanging access tokens for other tokens. A token exchange is performed by calling the [Token Endpoint](#term-token-endpoint).

<a name="term-userinfo-endpoint"></a> **UserInfo Endpoint** -- a [Broker](#term-broker)'s implementation of the [[OIDC-Core]](#ref-oidc-core) [UserInfo Endpoint](https://openid.net/specs/openid-connect-core-1_0.html#UserInfo).

<a name="term-visa"></a> 
**Visa** -- A 
Visa encodes a [Visa Assertion](#term-visa-assertion) in compact and digitally signed 
format that can be passed as a URL-safe string value.

A Visa MUST be signed by a [Visa Issuer](#term-visa-issuer). A Visa MAY be passed
through various [Brokers](#term-broker) as needed while retaining the
signature of the original [Visa Issuer](#term-visa-issuer).

<a name="term-visa-assertion"></a>
**Visa Assertion** -- a piece of information about a user that is asserted by a [Visa Assertion Source](#term-visa-assertion-source). It is then encoded by a [Visa Issuer](#term-visa-issuer) into a [Visa](#Visa).

<a name="term-visa-assertion-source"></a> **Visa Assertion Source** -- the source organization of
a [Visa Assertion](#term-visa-assertion) which at a minimum includes the organization associated with
making the assertion, although can optionally identify a sub-organization or a
specific assignment within the organization that made the assertion.

-   This is NOT necessarily the organization that stores the assertion, nor the
    [Visa Issuer](#term-visa-issuer)’s organization that signs the Visa; it is the
    organization that has the authority to make the assertion on behalf of the
    user and is responsible for making and maintaining the assertion.

<a name="term-visa-issuer"></a>
**Visa Issuer** -- A service that signs [Visas](#term-visa). This service:
* may be a [Broker](#term-broker) itself
* may be used by a [Broker](#term-broker) as part of collecting [Visas](#term-visa).

{% hr2 %}

## Relevant Specifications

<a name="ref-iana-jwt"></a>
[[IANA-JWT]](https://www.iana.org/assignments/jwt/jwt.xhtml) -- Standard JWT [Claim](#term-claim) name assignments, 
Internet Assigned Numbers Authority

<a name="ref-oidc-core"></a>
[[OIDC-Core]](http://openid.net/specs/openid-connect-core-1_0.html) -- OpenID Connect Core 1.0 (OIDC) -- 
        [Authorization Code Flow](http://openid.net/specs/openid-connect-core-1_0.html#rfc.section.3.1) 
        will generate id_tokens and access_tokens from the [Broker](#term-broker).

<a name="ref-oidc-client"></a>
[[OIDC-Client]](https://openid.net/specs/openid-connect-basic-1_0.html) -- OpenID Connect Basic Client Implementer's Guide 1.0 

<a name="ref-oidc-discovery"></a>
[[OIDC-Discovery]](https://openid.net/specs/openid-connect-discovery-1_0.html) -- OpenID Connect Discovery 1.0

<a name="ref-passport"></a>
[[Passport]](https://github.com/ga4gh-duri/ga4gh-duri.github.io/blob/master/researcher_ids/ga4gh_passport_v1.md) -- GA4GH Passport Specification, Data Use and Researcher Identity (DURI) Work Stream -- Defines Passport and Visa formats.

<a name="ref-researcher-ids"></a>
[[Researcher-ID]](https://github.com/ga4gh-duri/ga4gh-duri.github.io/blob/master/researcher_ids) -- GA4GH Passport Specification, Data Use and Researcher Identity (DURI) Work Stream -- Defines researcher identities for GA4GH [Passports](#term-passport) and [Visas](#term-visa).

<a name="ref-rfc2119"></a>
[[RFC2119]](https://www.ietf.org/rfc/rfc2119.txt) - Key words for use in RFCs to Indicate Requirement Levels

<a name="ref-rfc5246"></a>
[[RFC5246]](https://tools.ietf.org/html/rfc5246) - Transport Layer Security (TLS).
        Information passed among clients, applications, resource servers,
        [Brokers](#term-broker), and [Passport Clearinghouses](#term-passport-clearinghouse) 
        MUST be protected using TLS.

<a name="ref-rfc6749"></a>
[[RFC6749]](https://tools.ietf.org/html/rfc6749) -- The OAuth 2.0 Authorization Framework

<a name="ref-rfc6819"></a>
[[RFC6819]](https://www.rfc-editor.org/info/rfc6819) -
        Lodderstedt, T, McGloin, M., and P. Hunt, 
        "OAuth 2.0 Threat Model and Security Considerations", 
        RFC 6819, January 2013.

<a name="ref-rfc7515"></a>
[[RFC7515]](https://tools.ietf.org/html/rfc7515) -- JSON Web Signature (JWS) is the
        specific JWT to use for this spec.

<a name="ref-rfc7519"></a>
[[RFC7519]](https://tools.ietf.org/html/rfc7519) -- JSON Web Token (JWT) -- Specific implementations MAY extend
        this structure with their own service-specific JWT [Claim](#term-claim) names as top-level
        members of this JSON object. The JWTs specified here follow the JWS
        specification [[RFC7515]](#ref-rfc7515).

<a name="ref-rfc7636"></a>
[[RFC7636]](https://datatracker.ietf.org/doc/html/rfc7636) -- Proof Key for Code Exchange by OAuth Public Clients (PKCE) 

<a name="ref-rfc8693"></a>
[[RFC8693]](https://www.rfc-editor.org/info/rfc8693) - Jones, M., Nadalin, A., Campbell, B., Ed., Bradley, J.,
        and C. Mortimore, "OAuth 2.0 Token Exchange", RFC 8693,
        DOI 10.17487/RFC8693, January 2020.

<a name="ref-rfc8725"></a>
[[RFC8725]](https://www.rfc-editor.org/info/rfc8725) - Sheffer, Y., Hardt, D., and M. Jones, "JSON Web Token Best
        Current Practices", BCP 225, RFC 8725,
        DOI 10.17487/RFC8725, February 2020.

<a name="ref-rfc9068">
[[RFC9068]](https://datatracker.ietf.org/doc/html/rfc9068) --  JWT Profile for OAuth 2.0 Access Tokens


{% hr2 %}

## Overview of Interactions

### Full Login and Token Exchange Interaction in AAI/Passport 1.2

In the full token exchange flow recommended in this document, the client does not ever distribute the initial
*Passport-Scoped Access Token* to other services. A token exchange operation is executed by the client, in
exchange for a *Passport* JWT that may be used downstream to access resources. In this example flow, the
*Passport* is included as authorization in the POST to a Clearinghouse that holds data.

{% plantuml %}

hide footbox
skinparam BoxPadding 10
skinparam ParticipantPadding 20

box "Researcher"  #eee
actor       "User Agent"                as user
participant Client                      as client
end box

box "AAI"
participant "Broker and Passport Issuer"                      as broker
end box

box "Data Access Committee"
collections "Visa Issuer"            as issuer
end box

box "Data Holder"
participant "Passport Clearinghouse"            as clearing
end box

==OIDC==

user -> client : Initiates login
client -> user : Send redirect to Broker
user -> broker : Follow redirects
ref over user, client, broker
Broker authenticates user (potentially with external IdP)
end ref
broker -> user : Send redirect to client with authorization code
user -> client : Follow redirect with code
client -> broker : Request Passport-Scoped Access Token with code and client credentials
broker -> client : Respond with Passport-Scoped Access Token

==Exchange==

client -> broker : Request to exchange Passport-Scoped Access Token for Passport
broker <-> issuer : Exchange of visas, if needed (protocol unspecified)
client <- broker : Response with Passport

==Use==

user -> client : User initiates action requiring data
client -> clearing : Client requests data with Passport
clearing -> issuer : Request public keys
issuer -> clearing : Respond with public keys
client <- clearing : Clearinghouse responds with data

{% endplantuml %}

Notable differences between this diagram and interaction specified in AAI/Passport 1.0:
* The Passport Clearinghouse is no longer required to be a Client of the Broker
* The Passport-Scoped Access Token is only ever shared between the Client and the Broker
* An additional Token Exchange request is used to exchange the Passport-Scoped Access Token for a Passport Token,
  which can be sent to a Passport Clearinghouse.

### Flow of Assertions

@startuml
skinparam componentStyle rectangle
left to right direction

package "Unspecified clients, additional services, protocols" {
component "<b>Visa Assertion Source</b> (1)\norganisation" as VisaSource1
component "<b>Visa Assertion Source</b> (2)\norganisation" as VisaSource2
component "<b>Visa Assertion Source</b> (...)\norganisation" as VisaSourceN

database "<b>Visa Assertion</b>\n<b>Repository</b>\nabstract service" as VisaRepository
component "<b>Visa Issuer</b>\nabstract service\n(optional)" as VisaIssuer
}

package "Specified GA4GH AAI clients, services, protocols" {
component "<b>Broker</b>\nservice" as Broker #FAFAD2
component "<b>Client</b>\napplication" as Client #FAFAD2
component "<b>Passport</b>\n<b>Clearinghouse</b>\nservice" as ClearingHouse #FAFAD2
}

VisaSource1 ..> VisaRepository 
VisaSource2 ..> VisaRepository 
VisaSourceN ..> VisaRepository 
VisaRepository ..> VisaIssuer 


VisaRepository ..> Broker 
VisaIssuer ..> Broker 
Broker --> Client 
Client --> ClearingHouse

@enduml

The above diagram shows how [Visa Assertions](#term-visa-assertion) flow from [Visa Assertion Sources](#term-visa-assertion-source)
to a [Passport Clearinghouse](#term-passport-clearinghouse) that uses them. Only the
right hand portion of the flow is normative in that it is fully documented in this
specification.

Implementations may introduce clients, additional services, and protocols
to provide the mechanisms to move the data between the
[Visa Assertion Sources](#term-visa-assertion-source) and the [Broker](#term-broker). This diagram
shows *one possible mechanism* involving a repository service that persists assertions from a variety of
organisations, and optionally then involving a separate visa issuer which
signs some visas.

These mechanisms are unspecified by the scope of this specification except that
they MUST adhere to security and privacy best practices, such as those outlined
in this specification, in their handling of protocols, claims, tokens and
related data. The flow between these components (represented by black arrows)
MAY not be direct or conversely services shown as being separate MAY be
combined into one service. For example, some implementations MAY deploy one
service that handles the responsibilities of both the Visa Issuer and
the Broker.

{% hr2 %}

## Profile Requirements

### Conformance for Clients/Applications

Clients are applications which want to access data on behalf of users, and are responsible for using the standard described here to do so securely. 

1. OAuth defines two client types in [section 2.1](https://datatracker.ietf.org/doc/html/rfc6749#section-2.1) of [[RFC6749]](#ref-rfc6749).
   1. Confidential clients (which are able to keep the client secret secure, typically server-side web-applications) 
        MUST implement OAuth2 Authorization Code
        Flow (see OIDC Basic Client Implementer's Guide 1.0 [[OIDC-Client]](#ref-oidc-client)).
   
   2. Public clients (Single Pages Apps or Mobile Apps) SHOULD implement Authorization Code Flow 
        with [[PKCE]](#ref-rfc7636).

2.  Protection of Confidential Information

    1.  Sensitive information (e.g., including client secrets,
        authorization codes, id_tokens, access_tokens) MUST be passed over
        encrypted channels as per [[OIDC-Client]](#ref-oidc-client).

    2.  All responses that contain tokens, secrets, or other sensitive
        information MUST include the following HTTP response header fields and
        values as per [[OIDC-Client]](#ref-oidc-client).

        1.  `Cache-Control: no-cache, no-store`

        2.  `Pragma: no-cache`

3.  Clients MUST provide protection against client attacks as outlined in
    [[RFC6819]](#ref-rfc6819).

{% hr3 %}

### Conformance for Brokers
Brokers operate downstream from IdPs or provide their own IdP service. They issue id_tokens 
and access_tokens (and potentially refresh tokens) for consumption within the GA4GH compliant environment.

1. Broker MUST be an OpenID Provider
 
    1. Broker MUST conform to the OIDC Core specification [[OIDC-Core]](#ref-oidc-core).

    2. Broker MUST support the OIDC Discovery specification [[OIDC-Discovery]](#ref-oidc-discovery)
       and provide proper [metadata](https://openid.net/specs/openid-connect-discovery-1_0.html#ProviderMetadata)
       (i.e. must have a `jwks_uri` as required that’s reachable by a Passport Clearinghouse)

2.  Broker MUST support a [Token Endpoint](#term-token-endpoint) and [UserInfo Endpoint](#term-userinfo-endpoint).

    1. [Token Exchange](#term-token-exchange) at the Token Endpoint SHOULD be used for [Visas](#term-visa) in 
       preference to the UserInfo Endpoint.

    2. When presented with a valid [Passport-scoped Access Token](#term-passport-scoped-access-token),
       the UserInfo endpoint MUST provide [Visas](#term-visa) as described in the section
       [Visas provided by a Broker via UserInfo Endpoint](#visas-provided-by-a-broker-via-userinfo-endpoint).

3.  Brokers operate downstream from IdPs or provide their own IdP service. They
    issue id_tokens and access_tokens (and potentially refresh tokens) for
    consumption within the GA4GH compliant environment.

    1.  A Broker MUST issue [Passport-Scoped Access Tokens](#term-passport-scoped-access-token)
        (access_tokens).

        1.  This document makes no specifications beyond those in [[OIDC-Core]](#ref-oidc-core).

    2.  Access tokens MUST be in JWS format

        1.  Access tokens for GA4GH use MUST be a [GA4GH JWT](#ga4gh-jwt-format) using
            [Passport-Scoped Access Token format](#passport-scoped-access-token-issued-by-broker).

        2.  Access tokens MUST NOT contain [GA4GH Claims](#term-ga4gh-claims) directly in the access token.

        3.  Access tokens MAY contain additional non-GA4GH Claims directly in the access token.

4.  Broker MAY support [Token Exchange](#term-token-exchange). If implemented, it MUST behave as described 
    for passport issuance in [Conformance For Passport Issuers](#conformance-for-passport-issuers).

5.  Broker MUST provide protection against attacks as outlined in
    [[RFC6819]](#ref-rfc6819).

6.  The user represented by the identity of the access token MUST have agreed to
    release claims related to the requested scopes as part of generating tokens.
    Brokers MUST adhere to
    [section 3.1.2.4](https://openid.net/specs/openid-connect-core-1_0.html#Consent) 
    of [[OIDC-Core]](#ref-oidc-core).

    1.  The user represented by a Researcher Identity MUST approve the release
        of these claims to relying parties with sufficient granularity to
        allow for responsible disclosure of information best practices as well
        as to meet privacy regulations that may be applicable within or between
        jurisdictions where the user’s identity will be used (e.g. GDPR for
        a European Union user).

    2.  If the user’s release agreement has been remembered as part of a user’s
        settings such that the user no longer needs to be prompted, then the
        user MUST have the ability to remove this setting (i.e. be prompted
        again in the future). If a feature is to bypass prompts by remembering
        settings is available, it MUST only be used as an opt-in feature with
        explicit controls available to the user.

    3.  A user's withdrawal of this agreement does not need to apply to
        previously generated access tokens.

7.  When a Broker acts as a Visa Issuer then it MUST adhere to the [Conformance
    for Visa Issuers](#conformance-for-visa-issuers) section of this
    specification.

    When a Broker provides Visas from other Visa Issuers, it is providing
    them "as is" (i.e. it provides no additional assurance as to the quality,
    authenticity, or trustworthiness of the [Claims](#term-claim) from such tokens and any such
    assurances are made by the issuer of the Visa, i.e. the Visa Issuer).

{% hr3 %}

<a name="conformance-for-visa-issuers"></a>
### Conformance for Visa Issuers

Visa Issuers issue signed JWTs (Visas) asserting facts about researchers, which may be used by Passport Clearinghouses
to justify granting access to data. This specification defines the format of the Visas and endpoints Visa Issuers
should have in order for Passport Clearinghouses to validate those Visas. This document _does not_ specify how a Broker
obtains Visas contained in a Passport or returned from the Userinfo Endpoint.

1. A [Visa Issuer](#term-visa-issuer) MUST provide one or more of the following
    types of [Visas](#term-visa):
   
    1. <a name="term-visa-document-token"></a> 
       <a name="term-embedded-document-token"></a> 
       <a name="visa-document-token-format"></a>
       <a name="embedded-document-token-format"></a>
       **Visa Document Token** -- The Visa Issuer does not need to
       be an OIDC provider, and MAY provide tokens of this type without any
       revocation process.

        1.  The token MUST conform with JWS format [[RFC7515]](#term-rfc7515) requirements
        2.  The token MUST be signed by a [Visa Issuer](#term-visa-issuer).
        3.  The JWS header MUST contain `jku` as specified by [section
            4.1.2](https://tools.ietf.org/html/rfc7515#section-4.1.2) of [[RFC7515]](#term-rfc7515), and
            MUST provide the corresponding endpoint to fetch
            the public key used to sign the Visa Document Token.
        4.  The token is not treated as an access token, but validity
            checks outlined elsewhere in this specification still apply.
        5.  MUST conform to [token limited-life or revocation
            requirements](#token-revocation), even if no Visa token
            revocation process is provided.
        6.  The `scope` [Claim](#term-claim), if included, MUST NOT contain "openid" as
            a space-delimited substring of the `scope` JWT [Claim](#term-claim).
        7.  Payload [Claims](#term-claim) are specified in 
            [Visa Format](https://github.com/ga4gh-duri/ga4gh-duri.github.io/blob/master/researcher_ids/ga4gh_passport_v1.md#visa-format) in [[Passport]](#ref-passport).

    2. <a name="term-visa-access-token"></a> <a name="term-embedded-access-token"></a> <a name="embedded-access-token-format"></a>
       **Visa Access Token** -- The Visa Issuer is providing an OIDC provider
       service and issues OIDC-compliant access tokens in a specific format that can
       be used as a Visa. Details are specified in the AAI Profile 1.0 specification.

    <p class="deprecation">The <b>Visa Access Token</b> is proposed for removal in a future
     version of the specification. New implementations should issue Visas
     as <b>Visa Document Token</b>s.</p> 

2. By signing a Visa, a Visa Issuer asserts that
    the [Visa Assertions](#term-visa-assertion) made available by the Visa were legitimately derived
    from their [Visa Assertion Sources](#term-visa-assertion-source), and the content is
    presented and/or transformed without misrepresenting the original intent.

{% hr3 %}

### Conformance for Passport Issuers

Passport Issuers are used to package Visas into signed Passports. Passports are signed JWTs 
that use [this format](#passport-format) to contain Visas.

1.  Passport Issuers MUST be Brokers.

2.  Passports MUST be signed with a [conformant signing algorithm](#signing-algorithms).
    
3.  Passports MAY be issued from a [Token Endpoint](#term-token-endpoint) using [Token Exchange](#term-token-exchange), with the following clarifications:

    1. The Token Endpoint MAY also support other OAuth2 grant types.

    2. Client authentication is REQUIRED (using [OAuth2 client authentication](https://datatracker.ietf.org/doc/html/rfc6749#section-2.3.1) in [[RFC6749]](#ref-rfc6749) is RECOMMENDED).

    3. The `requested_token_type` parameter MUST be present with the value `urn:ga4gh:params:oauth:token-type:passport`.

    4. The `subject_token` parameter value MUST be a valid [Passport-Scoped Access Token](#term-passport-scoped-access-token).

    5. The `subject_token_type` parameter value MUST be `urn:ietf:params:oauth:token-type:access_token`.

    6. The Token Endpoint MAY accept or require any other optional parameters defined in [[RFC8693]](#ref-rfc8693).

<br/>
*Passport Issuing via [Token Exchange](#term-token-exchange) (non-normative)*

@startuml
skinparam componentStyle rectangle
left to right direction

component "<b>Client</b>" as Client

component "<b>Broker</b>" as Broker {
component "<b>Passport Issuer</b>\n(role)" as PassportIssuer {
interface "Token\nEndpoint" as TokenEndpoint
}
}

component "<b>Visa Issuer</b> (1)" as VisaIssuer1
component "<b>Visa Issuer</b> (2)" as VisaIssuer2

note "Signed visas can be sourced from\nmultiple visa issuers - either on\ndemand or via batch transfer/cached" as VisaNote

VisaIssuer1 --> VisaNote : Visa A, B
VisaIssuer2 --> VisaNote : Visa C

Client <-- Broker #text:red : (step 1) login flow results in\nan AAI passport-scoped access token
Client ---> TokenEndpoint #text:red : (step 2) request for token exchange
VisaNote ---right---> PassportIssuer #text:red : (step 3) visas obtained
Client <-- TokenEndpoint  #text:red : (step 4) passport issued (passport contains visa A,B,C)

@enduml    

{% hr3 %}

### Conformance for Passport Clearinghouses (consuming Passports or Visas to give access to data)

1.  Passport Clearinghouses MUST trust at least one Broker.

    1.  Passport Clearinghouses MAY trust more than one Broker
    
    2.  The responsibility of risk assessment of a Broker is on the Passport Clearinghouse to trust a token. 
    
2.  Passport Clearinghouses MUST process access tokens to access a Broker's Token or UserInfo Endpoint to get access to Visas OR MUST process Passports directly.

    1.  For access token flows, Passport Clearinghouses MUST either check the validity of the access token or treat the access
    token as opaque.

        1.  If treating the access token as a JWT, a Passport Clearinghouse:

            1. Even though access tokens are expected to be submitted against a Broker's Token or UserInfo Endpoint, a Passport Clearinghouse SHOULD check the access token’s signature via JWKS or having stored the
            public key.

                1.  A metadata URL (.well-known URL) SHOULD be used here to use the
                jwks_uri parameter.
                
            2.  MUST check `iss` attribute to ensure a trusted Broker has generated
            the token.
            
                1.  If evaluating Visa, trust MUST be established based
                on the signer of the Visa itself. In Passport
                Clearinghouses participating in open federation, the Passport
                Clearinghouse does not necessarily have to trust the Broker that
                includes Visas within another token in order to use
                the Visa (although the Passport Clearinghouse MAY require
                any other Broker involved in the propagation of the Visas to
                also be trusted if the Passport Clearinghouse needs to restrict its
                trust model).

            3.  MUST check `exp` to ensure the token has not expired.

            4.  MAY additionally check `aud` to make sure Relying Party is trusted
            (client_id).

        2.  If treating the token as opaque a Passport Clearinghouse MUST know in
        advance where to find a corresponding Introspection Endpoint. This may limit the
        functionality of accepting tokens from some Brokers. 

    2. For Passport flows, Passport Clearinghouses MUST check the validity of the Passport.

3.  Passport Clearinghouses service can be a Broker itself and would follow the
    [Conformance For Brokers](#conformance-for-brokers).

4.  Passport Clearinghouses MUST provide protection against attacks as outlined in
    [[RFC6819]](#ref-rfc6819).

    1. [Section 5.1.6](https://www.rfc-editor.org/rfc/rfc6819.html#section-5.1.6) of [[RFC6819]](#ref-rfc6819) states `Ensure that client applications do not share tokens with 3rd parties.` This profile provides a mechanism for Clearinghouses to consume access tokens from multiple brokers in a manner that does not involve 3rd parties. Client applications SHOULD take care to not spread the tokens to any other services that would be considered 3rd parties.
        
5.  If making use of [Visas](#term-visa):

    1.  The Passport Clearinghouse MUST validate that all JWT checks pass (such as
        the JWT hasn’t expired) as described elsewhere in this specification and
        the underlying OIDC specifications.

    2.  If making use of [Visa Access Tokens](#term-visa-access-token):

        1. Token checks MUST be performed to ensure it complies with the access
           token specification.

        2. In addition to other validation checks, a Visa is considered
           invalid if it is more than 1 hour old (as per the `iat` [Claim](#term-claim)) AND
           [Access Token Polling](#at-polling) does not confirm that the token is still
           valid (e.g. provide a success status code).

    3.  If making use of [Visa Document Tokens](#term-visa-document-token):

        1.  Fetching the public keys using the `jku` is not required if a Passport
            Clearinghouse has received the keys for the given `iss` via a trusted,
            out-of-band process.

        2.  If a Passport Clearinghouse is to use the `jku` URL to fetch the public
            keys to verify the signature, then it MUST verify that the `jku` is
            trusted for the given `iss` as part of the Passport Clearinghouse's
            trusted issuer configuration. This check MUST be performed before
            calling the `jku` endpoint.

6.  <a name="at-polling"></a> **Access Token Polling**: Clients MAY use access tokens,
    including Visas, to occasionally check which Visas are still valid
    at the associated Token or UserInfo Endpoint in order to establish 
    whether the user still meets the access requirements.

    This MUST NOT be done more than once per hour (excluding any optional retries)
    per Passport Clearinghouse. Any request retries MUST include exponential backoff
    delays based on best practices (e.g. include appropriate jitter). At a
    minimum, the client MUST stop checking once any of the following occurs:

    1.  The system can reasonably determine that authorization related to these
        [Claims](#term-claim) is no longer needed by the user. For example, all downstream cloud
        tasks have terminated and the related systems will no longer be using the
        access token nor any downstream tokens that were authorized by evaluating
        access requirements against [Claims](#term-claim) in the token.

    2.  The JWT access token has expired as per the `exp` field.

    3.  The client has detected that the user owning the identity or a system
        administrator has revoked the access token or a refresh token related to
        minting the access token.

    4.  The endpoint returns an HTTP status that is not retryable, e.g. HTTP status 400.

    5.  If the endpoint returns an updated set of Visas (this is
        an OPTIONAL feature of a Visa Issuer), then the Passport
        Clearinghouse MUST use the updated Visas and ignore the original
        GA4GH Claim values in the Visa Access Token. If the Passport
        Clearinghouse is unable to adjust for the updated Visas, then
        it MUST act as though the token was revoked.

{% hr2 %}

## GA4GH JWT Formats

This specification builds on the JWT format defined in [[RFC7519]](#ref-rfc7519).
A well-formed JWS-Encoded JSON Web Token (JWT) consists of three concatenated
Base64url-encoded strings, separated by dots (.) The three sections are: header,
payload and signature. These JWTs follow JWS [[RFC7515]](#ref-rfc7515)
and utilize a number of standard JWT [Claim](#term-claim) names [[IANA-JWT]](#ref-iana-jwt)
as per the registration process.
This profile is agnostic to the format of the id_token.

{% hr3 %}

<a name="access_token-issued-by-broker"></a>
### Passport-Scoped Access Token

This is the format for the token that is issued by [Brokers](#term-broker), extending the definition of 
the [[OIDC-Core]](#ref-oidc-core) access token.

**Header**

```
{
 "typ": "<jwt-type-identifier>",
 "alg": "<algorithm-identifier>",
 "kid": "<key-identifier>"
}
```
- `typ`: REQUIRED. Media type of the JWT. Value should be either 
   `JWT` as [recommended](https://datatracker.ietf.org/doc/html/rfc7519#section-5.1) 
   in [[RFC7519]](#ref-rfc7519)
   or `at+jwt` as [required](https://datatracker.ietf.org/doc/html/rfc9068#section-2.1) 
   in [[RFC9068]](#ref-rfc9068)
   if the token format follows [[RFC9068]](#ref-rfc9068).

- `alg`: REQUIRED. See [Signing Algorithms](#signing-algorithms).

- `kid`: REQUIRED. Key ID, see [section 4.1.4](https://tools.ietf.org/html/rfc7515#section-4.1.4) 
    of [[RFC7515]](#ref-7515).

**Payload**

```
{
 "iss": "https://<issuer-website>/",
 "sub": "<subject-identifier>",
 "idp": "<short-idp-identifier>",
 "aud": [
  "<client-id1>",
  "<client-id2>" ...
 ],
 "iat": <seconds-since-epoch>,
 "exp": <seconds-since-epoch>,
 "jti": <token-identifier>,
 "scope": "openid ga4gh_passport_v1 <additional-scopes>",
 <additional claims>
}
```
-   `iss`: REQUIRED. MUST be able to be appended with
    .well-known/openid-configuration to get spec of Broker.

-   `sub`: REQUIRED. Authenticated user unique identifier.

-   `idp`: OPTIONAL. SHOULD contain the IDP the user used to auth with.
    A non-normative example is "google". This does not have to be unique and
    can be used just to help inform if that is what a [Visa Issuer](#term-visa-issuer) 
    or [Data Holder](#term-data-holder) needs.

-   `aud`: OPTIONAL. If provided, it MUST contain the OAuth Client ID of the
    relying party.

-   `iat`: REQUIRED. Time issued.

-   `exp`: REQUIRED. Time expired.

-   `jti`: RECOMMENDED. a unique identifier for the token as per
    [section 4.1.7](https://tools.ietf.org/html/rfc7519#section-4.1.7) of [[RFC7519]](#ref-rfc7519)

-   `scope`: REQUIRED. Includes verified scopes. MUST include `openid` and `ga4gh_passport_v1`.
    The `scope` [Claim](#term-claim) is defined by [section 4.2](https://datatracker.ietf.org/doc/html/rfc8693#section-4.2)
    of [[RFC8693]](#ref-rfc8693).

-   [GA4GH Claims](#term-ga4gh-claim) (`ga4gh_passport_v1` or `ga4gh_visa_v1`): MUST NOT be included.

-   additional [Claims](#term-claim): OPTIONAL. Any other additional non-GA4GH [Claims](#term-claim) are allowed. This specification does not dictate the format of other [Claims](#term-claim).

{% hr3 %}

### Visas provided by a Broker via UserInfo Endpoint

The [UserInfo Endpoint](#term-userinfo-endpoint) MAY use `application/json`
or `application/jwt` response content type. It is RECOMMENDED that if desiring to return a JWT, a Token Endpoint supporting
[Token Exchange](#term-token-exchange) exists to do that and that the UserInfo Endpoint returns an `application/json` response.
Only the [GA4GH claims](#term-ga4gh-claim) must be as prescribed here. Refer to [[OIDC-Core]](#ref-oidc-core) for more information.

The UserInfo response MUST include a `ga4gh_passport_v1` [Claim](#term-claim) with a list of [Visas](#term-visa)
if a [Passport-Scoped Access Token](#term-passport-scoped-access-token) was used for accessing it.

{% hr3 %}

### Passport Format

Passport Issuers MUST issue a Passport conforming to the requirements in this section when a [Token Exchange](#term-token-exchange)
with the `requested_token_type=urn:ga4gh:params:oauth:token-type:passport` is successfully performed
(as described in the [Conformance for Passport Issuers](#conformance-for-passport-issuers) section).

Passports are defined as signed JWTs. The JWT specification [[RFC7519]](#ref-rfc7519)
states that JWTs can be either signed and encoded using JWS Compact Serialization, 
or encrypted and encoded using JWE Compact Serialization. 
Passports are signed JWTs, which implies that they must be encoded using [JWS Compact Serialization](https://www.rfc-editor.org/rfc/rfc7515#section-3.1) [[RFC7515]](#ref-7515).

**Header**

This spec prescribes the following JWS headers for Passports 
in addition to the guidelines established in [[RFC7515]](#ref-rfc7515):

- `typ`: REQUIRED where the value must be `vnd.ga4gh.passport+jwt` for Passports.

**Payload**

Only the [GA4GH claims](#term-ga4gh-claim) must be as prescribed here. See the
JWT specification [[RFC7519]](#ref-rfc7519) for more details.

```
{
 "iss": "https://<issuer-website>/",
 "sub": "<subject-identifier>",
 "aud": [
  "<client-id1>",
  "<client-id2>" ...
 ],
 "iat": <seconds-since-epoch>,
 "exp": <seconds-since-epoch>,
 "ga4gh_passport_v1": [
    <Passport Visa>,
    <Passport Visa (if more than one)>,
    ...
 ]
}
```

- `iss` and `sub`: REQUIRED.

- `aud`: OPTIONAL.

- `iat`: REQUIRED.

- `exp`: REQUIRED.

- `jti`: RECOMMENDED.

- `ga4gh_passport_v1`: REQUIRED. An array of GA4GH Visas. May be empty if a 
    user has no visas. See the [[Passport]](#ref-passport) specification 
    for more details on types of visas.

{% hr3 %}

### Signing Algorithms

JWTs MUST be issued with signatures using the `ES256` or `RS256` algorithm.

{% hr2 %}

## Security Considerations

The confidentiality and integrity of tokens must be secured, taking
[JSON Web Token Best Current Practices](https://www.rfc-editor.org/rfc/rfc8725.html#name-best-practices) in [[RFC8725]](#term-rfc8725)
into consideration. Of special concern are:
* Revoking access tokens and Visa Assertions
* Limiting damage of leaked tokens

{% hr2 %}

## Specification Revision History

| Version       | Date    | Editor                                                                | Notes                                                                            |
|---------------|---------|-----------------------------------------------------------------------|----------------------------------------------------------------------------------|
| 1.2.0 (draft) | 2022-08 | Andrew Patterson, Martin Kuba, Kurt Rodarmer, Tom Conner, Max Barkley | Introduce token exchange and Passport format, incorporate Visas, update diagrams |
| 1.1.0         | 2021-07 | Craig Voisin                                                          | *abandoned* version now reserved, new concepts moved to v1.2                     |
| 1.0.4         | 2021-07 | Craig Voisin                                                          | Improve existing terminology and define Passport and Visa JWTs                   |
| 1.0.3         | 2021-06 | Craig Voisin                                                          | Links for "scope" claim                                                          |
| 1.0.2         | 2020-02 | David Bernick                                                         | Clarify risk scenarios                                                           |
| 1.0.1         | 2019-10 | David Bernick                                                         | Clarify that non-GA4GH claims are allowed in tokens                              |
| 1.0.0         | 2019-10 | Approved by GA4GH Steering Committee                                  |                                                                                  |
| 0.9.9         | 2019-10 | David Bernick, Craig Voisin, Mikael Linden                            | Approved standard                                                                |
| 0.9.5         | 2019-09 | Craig Voisin                                                          | Update claim flow diagram and definitions                                        |
| 0.9.4         | 2019-08 | Craig Voisin                                                          | Embedded tokens for signed RI Claim Objects                                      |
| 0.9.3         | 2019-08 | Craig Voisin                                                          | Support for RI's embedded tokens                                                 |
| 0.9.2         | 2019-07 | David Bernick                                                         | Made changes based on feedback from review                                       |
| 0.9.1         | 2019-06 | Craig Voisin                                                          | Added terminology links                                                          |
| 0.9.0         | 2017-   | Mikael Linden, Craig Voisin, David Bernick                            | Initial working version                                                          |
