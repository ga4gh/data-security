---
layout: page
title: AAI OIDC Profile
permalink: aai-openid-connect-profile
---

## Abstract
{:.no_toc}

This specification profiles the OpenID Connect protocol (OIDC) to provide a federated
(multilateral) authorization infrastructure for greater
interoperability between genomics institutions in a manner specifically
applicable to (but not limited to) the sharing of restricted datasets.

In particular, this specification profiles tokens, endpoints and flows that
enable an OIDC provider (called a [Broker](#term-broker)) to
provide [Passports](#term-passport) and [Visas](#term-visa) to downstream consumers
called [Passport Clearinghouses](#term-passport-clearinghouse).

[GA4GH DURI Passports](https://github.com/ga4gh-duri/ga4gh-duri.github.io/blob/master/researcher_ids/ga4gh_passport_v1.md) can then be used for authorization purposes by downstream
systems.

{% hr2 %}

## Table of Contents
{:.no_toc}

* toc
{:toc}

{% hr2 %}

## Requirements Notation and Conventions

This specification inherits terminology from the [OpenID
Connect](http://openid.net/specs/openid-connect-core-1_0.html) and the [OAuth
2.0 Framework (RFC 6749)](https://tools.ietf.org/html/rfc6749) specifications.

The key words "MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL NOT", "SHOULD",
"SHOULD NOT", "RECOMMENDED", "MAY", and "OPTIONAL" in this specification are to
be interpreted as described in [RFC2119](https://www.ietf.org/rfc/rfc2119.txt).

{% hr2 %}

## Terminology

<a name="term-jwt"></a>
**JWT** -- JSON Web Token as defined in [RFC7519](https://datatracker.ietf.org/doc/html/rfc7519).
A JWT contains a set of [claims](https://datatracker.ietf.org/doc/html/rfc7519#section-2).
A claim is a piece of information asserted about a subject, represented as a name/value pair consisting of
a claim name (a string) and a claim value (any JSON value). This definiton of claims
is inherited by [OIDC](http://openid.net/specs/openid-connect-core-1_0.html) from RFC7519.

<a name="term-ga4gh-claim"></a> **GA4GH Claim** -- A JWT claim as defined by a GA4GH
documented technical standard that is making use of this AAI specification. Typically
this is the `ga4gh_passport_v1` or `ga4gh_visa_v1` claim for GA4GH Passports v1.x (see 
[GA4GH DURI Passport](https://github.com/ga4gh-duri/ga4gh-duri.github.io/blob/master/researcher_ids/ga4gh_passport_v1.md)).
Note that GA4GH is not the organization making the claim nor taking responsibility
for the claim as this is a reference to a GA4GH documented standard only.

<a name="term-identity-provider"></a> **Identity Provider (IdP)** -- a
service that provides to users an identity, authenticates it; and provides
assertions to a Broker using standard protocols, such as OpenID Connect, SAML or
other federation protocols. Example: eduGAIN, Google Identity, Facebook, NIH
ERACommons. IdPs MAY be [Visa Assertion Sources](#term-visa-assertion-source).

<a name="term-broker"></a> **Broker** -- An OIDC Provider service that
authenticates a user (potentially by an Identity Provider), collects user's
[Visas](#term-visa) from internal and/or external [Visa Issuers](#term-visa-issuer) and provides them
to [Passport Clearinghouses](#term-passport-clearinghouse).
Brokers may also be Passport Clearinghouses of other upstream Brokers (i.e.
create a chain of Brokers).

<a name="term-passport-clearinghouse"></a> **Passport Clearinghouse** -- A consumer
of [Visas](#term-visa) (i.e. an OIDC Relying Party or a service
downstream), that were provided by a [Broker](#term-broker), to make an
authorization decision at least in part based on inspecting Visas and
allows access to a specific set of underlying resources in the target
environment or platform. This abstraction allows for a variety of models for
how systems consume these Visas in order to provide access to resources.
Access can be granted by either issuing new access tokens for downstream
services (i.e. the Passport Clearinghouse may act like an authorization server)
or by providing access to the underlying resources directly (i.e. the Passport
Clearinghouse may act like a resource server). Some Passport Clearinghouses may
issue Passports that contain a new set or subset of Visas for downstream consumption.

<a name="term-data-holder"></a> **Data Holder** -- An organization that
holds a specific set of data (or its copy) and respects
and enforces the data controller's decisions on who can access it. A data controller
can also be a data holder. Data holders run a
[Passport Clearinghouse Server](#term-passport-clearinghouse) at a minimum.

<a name="term-data-controller"></a> **Data Controller** -- An organization that manages
data and, in that role, has capacity to decide who can access it. For
instance, a Data Access Committee (DAC).

<a name="term-passport-scoped-access-token"></a> **Passport-Scoped Access Token** --
An OIDC access token with [scope](https://datatracker.ietf.org/doc/html/rfc6749#section-3.3)
including the identifier `ga4gh_passport_v1`.

The access token MUST be a JWS-encoded JWT token containing `openid` and `ga4gh_passport_v1`
entries in the value of its `scope` claim.
It is RECOMMENDED that Passport-Scoped Access Tokens follow the [RFC9068 JWT Profile for OAuth 2.0 Access Tokens](https://datatracker.ietf.org/doc/html/rfc9068) specification.

<a name="term-passport"></a> **Passport** -- A signed and verifiable JWT container for holding [Visas](#term-visa).

<a name="term-passport-issuer"></a> **Passport Issuer** --
a service that creates and signs [Passports](#term-passport).

<a name="term-token-endpoint"></a> **Token Endpoint** -- 
as defined by [OIDC-Core](http://openid.net/specs/openid-connect-core-1_0.html); see [Token Endpoint](https://openid.net/specs/openid-connect-core-1_0.html#TokenEndpoint).

<a name="term-userinfo-endpoint"></a> **UserInfo Endpoint** -- 
as defined by [OIDC-Core](http://openid.net/specs/openid-connect-core-1_0.html); see [UserInfo Endpoint](https://openid.net/specs/openid-connect-core-1_0.html#UserInfo).

<a name="term-token-exchange"></a> **Token Exchange** --
the protocol defined in [RFC 8693](https://www.rfc-editor.org/info/rfc8693) as extension of OAuth 2
for exchanging access tokens for other tokens. A token exchange is performed at a [Token Endpoint](#term-token-endpoint)

<a name="term-visa-assertion"></a>
**Visa Assertion** -- a piece of information about a user that is asserted by a [Visa Assertion Source](#term-visa-assertion-source). It is then encoded by a [Visa Issuer](#term-visa-issuer) into a [Visa](#Visa).

<a name="term-visa"></a> 
**Visa** -- A JWT conforming to the [Visa Format](https://github.com/ga4gh-duri/ga4gh-duri.github.io/blob/master/researcher_ids/ga4gh_passport_v1.md#visa-format) defined in the [GA4GH DURI Passport](https://github.com/ga4gh-duri/ga4gh-duri.github.io/blob/master/researcher_ids/ga4gh_passport_v1.md) specification.
Visa encodes a [Visa Assertion](#term-visa-assertion) in compact and digitally signed format that can be passed as a URL-safe string value.

Visa MUST be signed by a [Visa Issuer](#term-visa-issuer). A Visa MAY be passed
through various [Brokers](#term-broker) as needed while retaining the
signature of the original Visa Issuer.

<a name="term-visa-issuer"></a>
**Visa Issuer** -- a service that signs
[Visas](#term-visa). This service:
* may be a [Broker](#term-broker) itself
* may be used by a [Broker](#term-broker) as part of collecting Visas.

<a name="term-visa-assertion-source"></a> **Visa Assertion Source** -- the source organization of
a [Visa Assertion](#term-visa-assertion) which at a minimum includes the organization associated with
making the assertion, although can optionally identify a sub-organization or a
specific assignment within the organization that made the assertion.

-   This is NOT necessarily the organization that stores the assertion, nor the
    [Visa Issuer](#term-visa-issuer)’s organization that signs the Visa; it is the
    organization that has the authority to make the assertion on behalf of the
    user and is responsible for making and maintaining the assertion.

{% hr2 %}

## Relevant Specifications

[OIDC-Core](http://openid.net/specs/openid-connect-core-1_0.html) -
        Authorization Code Flow will generate id_tokens and
        access_tokens from the Broker.

[RFC7519](https://tools.ietf.org/html/rfc7519) - JSON Web Token (JWT) - Specific implementations MAY extend
        this structure with their own service-specific JWT claim names as top-level
        members of this JSON object. The JWTs specified here follow JWS
        specification from [RFC7515 JWS](https://tools.ietf.org/html/rfc7515).

[RFC7515](https://tools.ietf.org/html/rfc7515) - JSON Web Signature (JWS) is the
        specific JWT to use for this spec.

[RFC5246](https://tools.ietf.org/html/rfc5246) - Transport Layer Security.
        Information passed among clients, Applications, Brokers, and Passport
        Clearinghouses MUST be protected using TLS.

[OIDC-Discovery](https://openid.net/specs/openid-connect-discovery-1_0.html)

[GA4GH-Passport](https://github.com/ga4gh-duri/ga4gh-duri.github.io/blob/master/researcher_ids/ga4gh_passport_v1.md) - DURI

[RFC8693](https://www.rfc-editor.org/info/rfc8693) - Jones, M., Nadalin, A., Campbell, B., Ed., Bradley, J.,
        and C. Mortimore, "OAuth 2.0 Token Exchange", RFC 8693,
        DOI 10.17487/RFC8693, January 2020.

[RFC6819](https://www.rfc-editor.org/info/rfc6819) -
        Lodderstedt, T, McGloin, M., and P. Hunt, 
        "OAuth 2.0 Threat Model and Security Considerations", 
        RFC 6819, January 2013.

[RFC8725](https://www.rfc-editor.org/info/rfc8725) - Sheffer, Y., Hardt, D., and M. Jones, "JSON Web Token Best
        Current Practices", BCP 225, RFC 8725,
        DOI 10.17487/RFC8725, February 2020.

{% hr2 %}

## Flow of Assertions

@startuml
skinparam componentStyle rectangle
left to right direction

package "Unspecified clients, additional services, protocols" {
component "<b>Visa Assertion Source</b> (1)\norganisation" as VisaSource1
component "<b>Visa Assertion Source</b> (2)\norganisation" as VisaSource2
component "<b>Visa Assertion Source</b> (...)\norganisation" as VisaSourceN

database "<b>Visa Assertion Repository</b>\nabstract service" as VisaRepository
component "<b>Visa Issuer</b>\nabstract service\n(optional)" as ETI
}

package "Specified GA4GH AAI clients, services, protocols" {
component "<b>Broker</b>\nservice" as Broker #FAFAD2
component "<b>Passport Clearinghouse</b>\nservice" as ClearingHouse #9E7BB5
}

VisaSource1 --> VisaRepository : (unspecified)
VisaSource2 --> VisaRepository : (unspecified)
VisaSourceN --> VisaRepository : (unspecified)
VisaRepository --> ETI : (unspecified)


VisaRepository --> Broker : (unspecified)
ETI --> Broker : (unspecified)
Broker --> ClearingHouse : GA4GH AAI spec

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

1. Confidential clients (defined in [section 2.1 of RFC6749](https://datatracker.ietf.org/doc/html/rfc6749#section-2.1),
   keep the client secret secure, typically server-side web-applications) MUST implement OAuth2 Authorization Code
   Flow (see [OIDC Basic Client Implementer's Guide](http://openid.net/specs/openid-connect-basic-1_0.html)).
   Public clients (Single Pages Apps or Mobile Apps) SHOULD implement Authorization Code Flow with [PKCE](https://datatracker.ietf.org/doc/html/rfc7636).

2.  Conform to [revocation requirements](#token-revocation).

3.  Protection of Confidential Information

    1.  Sensitive information (e.g., including client secrets,
        authorization codes, id_tokens, access_tokens) will be passed over
        encrypted channels as per
        [OIDC Implementation Guide](https://openid.net/specs/openid-connect-basic-1_0.html).

    2.  All responses that contain tokens, secrets, or other sensitive
        information MUST include the following HTTP response header fields and
        values (as per [OIDC Implementation Guide](https://openid.net/specs/openid-connect-basic-1_0.html)).

        1.  `Cache-Control: no-cache, no-store`

        2.  `Pragma: no-cache`

4.  MUST provide protection against Client attacks as outlined in
    [RFC 6819](https://tools.ietf.org/html/rfc6819).

{% hr3 %}

### Conformance for Brokers

1.  Brokers operate downstream from IdPs or provide their own IdP service. They
    issue id_tokens and access_tokens (and potentially refresh tokens) for
    consumption within the GA4GH compliant environment.

    1.  A Broker MUST issue both [Passport-Scoped Access Tokens](#term-passport-scoped-access-token)
        (access_tokens) and id_tokens.

        1.  This document makes no specifications for id_tokens.

    2.  Access_tokens MUST be in JWS format

        1.  Access tokens for GA4GH use MUST be a [GA4GH JWT](#ga4gh-jwt-format) using
            [Passport-Scoped Access Token format](#passport-scoped-access-token-issued-by-broker).

        2.  Access tokens MAY contain additional non-GA4GH Claims directly in the access token.

2. Broker MUST be an OpenID Provider
 
    1. Broker MUST conform to the [OIDC Core Specification](http://openid.net/specs/openid-connect-core-1_0.html)

    2. Broker MUST support [OIDC Discovery spec](https://openid.net/specs/openid-connect-discovery-1_0.html)
       and provide proper [metadata](https://openid.net/specs/openid-connect-discovery-1_0.html#ProviderMetadata)
       (i.e. must have a `jwks_uri` as required that’s reachable by a Passport Clearinghouse)

3.  Broker MUST support a Token Endpoint or UserInfo Endpoint.

    1. [Token Exchange](#term-token-exchange) at the Token Endpoint SHOULD be used for [Visas](#term-visa) in 
       preference to the UserInfo Endpoint.

    2. When presented with a valid [Passport-scoped Access Token](#term-passport-scoped-access-token),
       the UserInfo endpoint MUST provide [Visas](#term-visa) as described in the section
       [Visas provided by a Broker via UserInfo Endpoint](#visas-provided-by-a-broker-via-userinfo-endpoint).

4.  Broker MAY support [Token Exchange](#term-token-exchange). If implemented, it MUST behave as described 
    for passport issuance in [Conformance For Passport Issuers](#conformance-for-passport-issuers).

5.  Broker MUST provide protection against attacks as outlined in
    [RFC 6819](https://tools.ietf.org/html/rfc6819).

6.  The user represented by the identity of the access token MUST have agreed to
    release claims related to the requested scopes as part of generating tokens.
    Brokers MUST adhere to
    [section 3.1.2.4 of the OIDC specification](https://openid.net/specs/openid-connect-core-1_0.html#Consent).

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

7.  When a Broker acts as a Visa Issuer then it adheres to [Conformance
    for Visa Issuers](#conformance-for-visa-issuers) section of this
    specification.

    When a Broker provides Visas from other Visa Issuers, it is providing
    them "as is" (i.e. it provides no additional assurance as to the quality,
    authenticity, or trustworthiness of the claims from such tokens and any such
    assurances are made by the issuer of the Visa, i.e. the Visa Issuer).

{% hr3 %}

<a name="conformance-for-visa-issuers"></a>
### Conformance for Visa Issuers

1. A [Visa Issuer](#term-visa-issuer) MUST provide one or more of the following
    types of [Visas](#term-visa):

    1. <a name="term-visa-access-token"></a> <a name="term-embedded-access-token"></a>
       **Visa Access Token** -- The Visa Issuer is providing an OIDC provider
       service and issues OIDC-compliant access tokens in a specific format that can
       be used as a Visa. Note: The **Visa Access Token** may be removed in a future 
       version of the specification. New implementations should prefer to issue Visas 
       as [Visa Document Tokens](#visa-document-token-format).

        1.  The Visa payload MUST contain the "openid" scope. That
            is, it has a `scope` JWT claim that contains "openid" as a
            space-delimited substring.

        2.  Visa is a JWS string and follows the [Visa Access Token
            Format](#visa-access-token-format). This includes
            having GA4GH Claims as JWT claims directly in the Visa.

        3.  Visa Issuers issuing Visa Access Tokens MUST support [OIDC Discovery
            spec](https://openid.net/specs/openid-connect-discovery-1_0.html),
            and provide `jwks_uri` as
            [Metadata](https://openid.net/specs/openid-connect-discovery-1_0.html#ProviderMetadata)
            that may be reachable by a Passport Clearinghouse.

        4.  Visa Issuer MUST support public-facing UserInfo Endpoint. When presented with a valid 
            Visa Access Token, the UserInfo Endpoint MUST return a success status and MAY return 
            the current values for GA4GH Claims that were included within the Visa Access Token, 
            however returning GA4GH Claims from the UserInfo Endpoint for Visa Access Tokens is 
            OPTIONAL.

        5.  If the Visa Access Token's `exp` exceeds the `iat` by
            more than 1 hour, the Visa Issuer should expect
            Passport Clearinghouses to use [Access Token Polling](#at-polling) and
            MUST provide a means to revoke Visa Access Tokens. The
            Token or UserInfo Endpoint MUST return an HTTP status 401 as per
            [RFC6750 section 3.1](https://tools.ietf.org/html/rfc6750#section-3.1)
            when provided an Visa Access Token that has completed the
            revocation process.

        6.  The JWS header MUST NOT have `jku` specified.

        7.  Visa Issuer MUST provide protection against
            attacks as outlined in [RFC
            6819](https://tools.ietf.org/html/rfc6819).

        8. A Visa Issuer MAY generate the `exp` timestamp to enforce
           its policies and allow Passport Clearinghouses to understand the intent of
           how long the assertion may be used before needing to return to the Visa Issuer
           to refresh the Visa. As a non-normative example, if an
           assertion expires in 25 years, the Visa Issuer could set the `exp` to
           1 day into the future plus issue a refresh token in order to force the
           refresh token to be used when a downstream Passport Clearinghouse is still
           interested in using such an assertion after 1 day elapses.

    2. <a name="term-visa-document-token"></a> <a name="term-embedded-document-token"></a>
       **Visa Document Token** -- The Visa Issuer does not need to
       be an OIDC provider, and MAY provide tokens of this type without any
       revocation process.

        1.  The JWS header contains `jku` as specified by [RFC7515 Section
            4.1.2](https://tools.ietf.org/html/rfc7515#section-4.1.2), and
            provides the corresponding endpoint to fetch
            the public key used to sign the Visa Document Token.

        2.  Follows the [Visa Document Token
            Format](#visa-document-token-format).

        3.  The token is not treated as an access token, but validity
            checks outlined elsewhere in this specification still apply.

        4.  MUST conform to [token limited-life or revocation
            requirements](#token-revocation), even if no Visa token
            revocation process is provided.

        5.  The `scope` JWT claim, if included, MUST NOT contain "openid" as
            a space-delimited substring.

2. By signing a Visa, a Visa Issuer asserts that
    the [Visa Assertions](#term-visa-assertion) made available by the Visa were legitimately derived
    from their [Visa Assertion Sources](#term-visa-assertion-source), and the content is
    presented and/or transformed without misrepresenting the original intent.

{% hr3 %}

### Conformance for Passport Issuers

1.  Passport Issuers are used to package Visas into signed Passports.

2.  Passport Issuers SHOULD be Brokers.

3.  Passports themselves are signed JWTs that contain Visas. Passports use [this format](#passport-format).
    
4.  Passports MUST be signed with a [conformant signing algorithm](#signing-algorithms).
    
5.  Passports MAY be issued from a [Token Endpoint](#term-token-endpoint) using [Token Exchange](#term-token-exchange), with the following clarifications:

    1. The Token Endpoint MAY support other OAuth2 grant types.

    2. Client authentication is REQUIRED (using [OAuth2 client authentication](https://datatracker.ietf.org/doc/html/rfc6749#section-2.3.1) is RECOMMENDED).

    3. The `requested_token_type` parameter MUST be present with the value `urn:ga4gh:params:oauth:token-type:passport`.

    4. The `subject_token` parameter value MUST be a valid [Passport-Scoped Access Token](#term-passport-scoped-access-token).

    5. The `subject_token_type` parameter value MUST be `urn:ietf:params:oauth:token-type:access_token`.

    6. The Token Endpoint MAY accept or require any other optional parameters defined in [RFC8693](https://datatracker.ietf.org/doc/html/rfc8693).

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

VisaIssuer1 --up--> VisaNote : Visa A, B
VisaIssuer2 --up--> VisaNote : Visa C

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
    [RFC 6819](https://tools.ietf.org/html/rfc6819).

    1. Section 5.1.6 of RFC 6819 contains a SHOULD section that states `Ensure that client applications do not share tokens with 3rd parties.` This profile provides a mechanism for Clearinghouses to consume access tokens from multiple brokers in a manner that does not involve 3rd parties. Client applications SHOULD take care to not spread the tokens to any other services that would be considered 3rd parties.
        
5.  If making use of [Visas](#term-visa):

    1.  The Passport Clearinghouse MUST validate that all JWT checks pass (such as
        the JWT hasn’t expired) as described elsewhere in this specification and
        the underlying OIDC specifications.

    2.  If making use of [Visa Access Tokens](#term-visa-access-token):

        1. Token checks MUST be performed to ensure it complies with the access
           token specification.

        2. In addition to other validation checks, a Visa is considered
           invalid if it is more than 1 hour old (as per the `iat` claim) AND
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
        claims is no longer needed by the user. For example, all downstream cloud
        tasks have terminated and the related systems will no longer be using the
        access token nor any downstream tokens that were authorized by evaluating
        access requirements against claims in the token.

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

A well-formed JWS-Encoded JSON Web Token (JWT) consists of three concatenated
Base64url-encoded strings, separated by dots (.) The three sections are: header,
payload and signature. These JWTs follow [RFC7515](https://tools.ietf.org/html/rfc7515) (JWS)
and utilize a number of [standard JWT claim names](https://www.iana.org/assignments/jwt/jwt.xhtml)
as per the registration process.
This profile is agnostic to the format of the id_token.

{% hr3 %}

<a name="access_token-issued-by-broker"></a>
### Passport-Scoped Access Token issued by Broker

**Header**

```
{
 "typ": "<jwt-type-identifier>",
 "alg": "<algorithm-identifier>",
 "kid": "<key-identifier>"
}
```
- `typ`: REQUIRED. Media type of the JWT. Value should be either 
   `JWT` as recommended in [RFC7519](https://datatracker.ietf.org/doc/html/rfc7519#section-5.1)
   or `at+jwt` as required in [RFC9068](https://datatracker.ietf.org/doc/html/rfc9068#section-2.1)
   if the token format follows RFC9068.

- `alg`: REQUIRED. See [Signing Algorithms](#signing-algorithms).

- `kid`: REQUIRED. Key ID, see [RFC7515 section 4.1.4](https://tools.ietf.org/html/rfc7515#section-4.1.4)

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
    can be used just to help inform if that is what a data controller or data holder
    needs.

-   `aud`: OPTIONAL. If provided, it MUST contain the OAuth Client ID of the
    relying party.

-   `iat`: REQUIRED. Time issued.

-   `exp`: REQUIRED. Time expired.

-   `jti`: RECOMMENDED. a unique identifier for the token as per
    [RFC7519 Section 4.1.7](https://tools.ietf.org/html/rfc7519#section-4.1.7)

-   `scope`: REQUIRED. Includes verified scopes. MUST include `openid` and `ga4gh_passport_v1`.
    The `scope` claim is defined by [RFC8693 section 4.2](https://datatracker.ietf.org/doc/html/rfc8693#section-4.2).

-   GA4GH Claims (`ga4gh_passport_v1` or `ga4gh_visa_v1`): MUST NOT be included.

-   additional claims: OPTIONAL. Any other additional non-GA4GH claims are allowed. This specification does not dictate the format of other claims.

{% hr3 %}

### Visas provided by a Broker via UserInfo Endpoint

The [UserInfo](https://openid.net/specs/openid-connect-core-1_0.html#UserInfo) endpoint MAY use `application/json`
or `application/jwt` response content type. It is RECOMMENDED that if desiring to return a JWT, a Token Endpoint supporting
[Token Exchange](#term-token-exchange) exists to do that and that the UserInfo Endpoint returns an `application/json` response.
Only the GA4GH claims must be as prescribed here. Refer to OIDC Spec for more information.

The UserInfo response MUST include a `ga4gh_passport_v1` claim with a list of [Visas](#term-visa)
if a [Passport-Scoped Access Token](#term-passport-scoped-access-token) was used for accessing it.

{% hr3 %}

### Passport Format

Passport Issuers MUST issue a Passport conforming to the requirements in this section when a [Token Exchange](#term-token-exchange)
with the `requested_token_type=urn:ga4gh:params:oauth:token-type:passport` is successfully performed
(as described in the [Conformance for Passport Issuers](#conformance-for-passport-issuers) section).

Passports are defined as signed JWTs. [RFC7519 (JWT)](https://datatracker.ietf.org/doc/html/rfc7519)
states that JWTs can be either signed and encoded using JWS Compact Serialization, 
or encrypted and encoded using JWE Compact Serialization. 
Passports are signed JWTs, which implies that they must be encoded using JWS Compact Serialization.

**Header**

This spec prescribes the following JWS headers for Passports 
in addition to the guidelines established in [RFC7515](https://datatracker.ietf.org/doc/html/rfc7515):

- `typ`: REQUIRED where the value must be `vnd.ga4gh.passport+jwt` for Passports.

**Payload**

Only the GA4GH claims must be as prescribed here. See the
[JWT specification](https://datatracker.ietf.org/doc/html/rfc7519) for more details.

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

- `ga4gh_passport_v1`: REQUIRED. An array of GA4GH Visas. May be empty if a user has no visas. See the
[Passport spec](https://github.com/ga4gh-duri/ga4gh-duri.github.io) for more details on types of visas.

{% hr3 %}

<a name="visa-issued-by-visa-issuer"></a>
### Visa issued by Visa Issuer

There are two supported formats for Visas.

{% hr4 %}

<a name="embedded-document-token-format"></a>
#### Visa Document Token Format

Conforms with JWS format requirements and is signed by a Visa Issuer.

1. MUST be a JWS string.

2. MUST contain a `jku` in the header.

3. MUST NOT contain "openid" as a space-delimited substring of the `scope`
   JWT claim, if the `scope` claim is provided.

4. Payload claims are specified in [Visa Format](https://github.com/ga4gh-duri/ga4gh-duri.github.io/blob/master/researcher_ids/ga4gh_passport_v1.md#visa-format)

{% hr4 %}

<a name="embedded-access-token-format"></a>
#### Visa Access Token Format

Conforms with JWS format requirements and is signed by an OpenID Provider.

1. MUST be a JWS string.

2. The header MUST NOT contain a `jku`.

3. `scope` is REQUIRED and MUST be a string containing a space-delimited set of
    scope names. "openid" MUST be included as a scope name.

4. Payload claims are specified in [Visa Format](https://github.com/ga4gh-duri/ga4gh-duri.github.io/blob/master/researcher_ids/ga4gh_passport_v1.md#visa-format)

5. The payload claims MUST NOT include `aud`.

{% hr3 %}

### Signing Algorithms

JWTs MUST be issued with signatures using the `ES256` or `RS256` algorithm.
Clients, applications, and clearinghouses must validate signatures and must
take care to perform validation securely and resist tampering with the validation
process, taking
[RFC8725 JSON Web Token Best Current Practices](https://www.rfc-editor.org/rfc/rfc8725.html#name-best-practices)
into consideration.

{% hr2 %}

## Token Revocation

### Visa Assertion Source Revokes a Visa Assertion

Given that [Visa Assertions](#term-visa-assertion) can cause downstream access tokens to be minted by Passport
Clearinghouses and such downstream access tokens may have little knowledge or no
connectivity to [Visa Assertion Sources](#term-visa-assertion-source), it can be challenging to build robust
revocation capabilities across highly federated and loosely coupled systems.
During the lifetime of the downstream access token, some systems may require
that [Visas](#term-visa) are no longer inspected nor updated.

In the event that a [Visa Assertion Source](#term-visa-assertion-source) revokes a [Visa Assertion](#term-visa-assertion),
downstream Visa Issuers, Brokers, Passport Clearinghouses, and other Authorization or Resource
Servers MUST at a minimum provide a means to limit the lifespan of any given
access tokens generated as a result of [Visa Assertions](#term-visa-assertion). To achieve this goal, servers
involved with access may employ one or more of the following options:

1. Have each [Visa](#term-visa) in the form of [Visa Document Token](#visa-document-token-format) contain an expiry timestamp.
    Expiry timestamps would require users to log in occasionally via
    a Broker in order to refresh [Visas](#term-visa). On a refresh, expiry timestamps can
    be extended from what the previous [Visa](#term-visa) may have indicated.

2. Provide [Visas](#term-visa) in the form of [Visa Access Tokens](#visa-access-token-format)
    to allow downstream Passport  
    Clearinghouses to periodically check the validity of the token via calls
    to the Introspection Endpoint as per [Access Token Polling](#at-polling).

3. Provide refresh tokens at every level in the system hierarchy and use
    short-lived access tokens. This may require all contributing systems to
    support [OIDC offline
    access](https://openid.net/specs/openid-connect-core-1_0.html#OfflineAccess)
    refresh tokens to deal with execution of processes where the user is no
    longer actively involved. In the event that refresh tokens experience
    errors, the systems involved must eventually revoke the ability for
    downstream access tokens to be replaced via refresh tokens (although some
    level of delay to reach out to a user to try to resolve the issue may be
    desirable).

4. Provide some other means for downstream Passport Clearinghouses or other
    systems that create downstream access tokens to be informed of a material
    change in upstream assertions such that action can be taken to revoke the token,
    revoke the refresh token, or revoke the access privileges associated with
    such tokens.

{% hr3 %}

### Revoking Access Tokens from Bad Actors

In the event that a system or user detects that a specific user is misbehaving or
has falsified assertions despite previous assurances that access was appropriate,
there MUST be a mechanism to withdraw access from existing tokens and update
assertions to prevent further tokens from being minted.

1.  Systems MUST have a means to revoke existing refresh tokens or remove
    permissions from access tokens that are sufficiently long-lived enough to
    warrant taking action.

    -   If an access token is long-lived, then the access token MUST be
        revocable, and once revoked the UserInfo Endpoint MUST NOT return
        claims. In this event, an appropriate error status MUST be returned like UserInfo errors as per
        [section 5.3.3 of the OIDC specification](https://openid.net/specs/openid-connect-core-1_0.html#UserInfoError).

    -   [Access Token Polling](#at-polling) can allow downstream systems to detect
        token revocation and remove access accordingly.

2.  A process MUST exist, manual or automated, to eventually remove or invalidate
    related assertions at source and intermediate systems.

{% hr3 %}

### Limited Damage of Leaked Tokens

In order to limit damage of leaked tokens, systems MUST provide all of the
following where applicable:

1.  Be able to leverage mechanisms in place for revoking claims and tokens
    for other purposes to also limit exposure of leaked tokens.

2.  Follow best practices for the safekeeping of refresh tokens or longer lived
    tokens (should longer lived tokens be needed).

3.  Employ refresh token rotation. (A refresh token can be used at most once,
    for exchanging it for a new access token and a new refresh token.)

4.  Any signed tokens that may be stored by participating services SHOULD be
    encrypted at rest and follow best practices to limit the ability of
    administrators from decrypting this content.

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
