---
layout: page
permalink: aai-openid-connect-profile
---

| Version | Date    | Editor                                     | Notes                   |
|---------|---------|--------------------------------------------|-------------------------|
| 1.2.0   | 2021-07 | Craig Voisin                               | Introduce self-contained passports |
| 1.1.0   | 2021-07 | Craig Voisin                               | *abandoned* version now reserved, new concepts moved to v1.2 |
| 1.0.4   | 2021-07 | Craig Voisin                               | Improve existing terminology and define Passport and Visa JWTs |
| 1.0.3   | 2021-06 | Craig Voisin                               | Links for "scope" claim |
| 1.0.2   | 2020-02 | David Bernick                              | Clarify risk scenarios  |
| 1.0.1   | 2019-10 | David Bernick                              | Clarify that non-GA4GH claims are allowed in tokens |
| 1.0.0   | 2019-10 | Approved by GA4GH Steering Committee       |                         |
| 0.9.9   | 2019-10 | David Bernick, Craig Voisin, Mikael Linden | Approved standard       |
| 0.9.5   | 2019-09 | Craig Voisin                               | Update claim flow diagram and definitions |
| 0.9.4   | 2019-08 | Craig Voisin                               | Embedded tokens for signed RI Claim Objects |
| 0.9.3   | 2019-08 | Craig Voisin                               | Support for RI's embedded tokens |
| 0.9.2   | 2019-07 | David Bernick                              | Made changes based on feedback from review |
| 0.9.1   | 2019-06 | Craig Voisin                               | Added terminology links |
| 0.9.0   | 2017-   | Mikael Linden, Craig Voisin, David Bernick | Initial working version |

### Abstract

This specification profiles the OpenID Connect protocol to provide a federated
(multilateral) authentication and authorisation infrastructure for greater
interoperability between Genomics institutions in a manner specifically
applicable to (but not limited to) the sharing of restricted datasets.

In particular, this specification introduces a JSON Web Token
([JWT](#relevant-specifications)) syntax for an access token to
enable an OIDC provider (called a [Broker](#term-broker)) to allow a downstream
access token consumer (called a [Claim Clearinghouse](#term-claim-clearinghouse))
to locate the Broker’s /userinfo endpoint as a means to fetch [GA4GH
Claims](#term-ga4gh-claim). This specification is suggested to be used together
with others that specify the syntax and semantics of the GA4GH Claims exchanged.

### Table of Contents

- [Abstract](#abstract)
- [Requirements Notation and Conventions](#requirements-notation-and-conventions)
- [Terminology](#terminology)
- [Relevant Specifications](#relevant-specifications)
- [Flow of Claims](#flow-of-claims)
- [**Profile Requirements**](#profile-requirements)\
       - [Client/Application Conformance](#clientapplication-conformance)\
       - [Conformance for Brokers](#conformance-for-brokers)\
       - [Conformance for Visa Issuers](#conformance-for-visa-issuers)\
       - [Conformance for Claim Clearinghouses (consuming Access Tokens to give access to data)](#conformance-for-claim-clearinghouses-consuming-access-tokens-to-give-access-to-data)
- [**GA4GH JWT Format**](#ga4gh-jwt-format)\
       - [Passport-Scoped Access_Token issued by broker](#passport-scoped-access-token-issued-by-broker)\
       - [Claims sent to Data Holder by a Broker via /userinfo](#claims-sent-to-data-holder-by-a-broker-via-userinfo)\
       - [Visa issued by Visa Issuer](#visa-issued-by-visa-issuer)\
            - [Visa Access Token Format](#visa-access-token-format)\
            - [Visa Document Token Format](#visa-document-token-format)\
       - [Authorization/Claims](#authorizationclaims)
- [**Broker Passport Endpoint**](#broker-passport-endpoint)\
       - [Passport Endpoint Request](#passport-endpoint-request)\
       - [Broker Passport Endpoint Processing](#broker-passport-endpoint-processing)\
       - [Passport Endpoint Response](#passport-endpoint-response)
- [**Token Revocation**](#token-revocation)\
       - [Claim Source Revokes Claim](#claim-source-revokes-claim)\
       - [Revoking Access from Bad Actors](#revoking-access-from-bad-actors)\
       - [Limited Damage of Leaked Tokens](#limited-damage-of-leaked-tokens)
- [**Appendix**](#Appendix)

### Requirements Notation and Conventions

This specification inherits terminology from the [OpenID
Connect](http://openid.net/specs/openid-connect-core-1_0.html) and the [OAuth
2.0 Framework (RFC 6749)](https://tools.ietf.org/html/rfc6749) specifications.

The key words "MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL NOT", "SHOULD",
"SHOULD NOT", "RECOMMENDED", "MAY", and "OPTIONAL" in this specification are to
be interpreted as described in [RFC2119](https://www.ietf.org/rfc/rfc2119.txt).

### Terminology

<a name="term-ga4gh-claim"></a> **GA4GH Claim** -- A JWT claim as defined by a GA4GH
documented technical standard that is making use of this AAI specification. Typically
this is the `ga4gh_passport_v1` or `ga4gh_visa_v1` claim for GA4GH Passports v1.x.
Note that GA4GH is not the organization making the claim nor taking responsibility
for the claim as this is a reference to a GA4GH documented standard only.

<a name="term-claim-management-system"></a> **Claim Management System** -- a service
that allows [Claim Source](#term-claim-source) users to manage claims and update one
or more [Claim Repositories](#term-claim-repository). For instance, a data owner
of a controlled access dataset would typically interact with a Claim Management
System to add or remove claims from a [Claim Repository](#term-claim-repository).

<a name="term-claim-repository"></a> **Claim Repository** -- a service that
manages the durable storage and retrieval of claims (such as a database),
along with any metadata and/or audit logs related to claim creation,
modification, and deletion.

<a name="term-claim-source"></a> **Claim Source** -- the source organization of
a claim assertion which at a minimum includes the organization associated with
asserting the claim, although can optionally identify a sub-organization or a
specific assignment within the organization that made the claim.

-   This is NOT necessarily the organization that stores the claim, nor the
    [Broker](#term-broker)’s organization that signs the token; it is the
    organization that has the authority to assert the claim on behalf of the
    user and is responsible for making and maintaining the assertion.

<a name="term-identity-provider"></a> **Identity Provider (IdP)** -- a
service that provides to users an identity, authenticates it; and provides
claims to a Broker using standard protocols, such as OpenID Connect, SAML or
other federation protocols. Example: eduGAIN, Google Identity, Facebook, NIH
ERACommons. IdPs MAY be claims sources.

<a name="term-broker"></a> **Broker** -- An OIDC Provider service that
authenticates a user (potentially by an Identity Provider), collects their
claims from internal and/or upstream claim sources and issues conformant JWT
claims to be consumed by [Claim Clearinghouses](#term-claim-clearinghouse).
Brokers may also be Claim Clearinghouses of other upstream Brokers (i.e.
create a chain of Brokers like in the
[Flow of Claims diagram](#flow-of-claims)).

<a name="term-claim-clearinghouse"></a> **Claim Clearinghouse** -- A consumer
of [GA4GH Claims](#term-ga4gh-claim) (i.e. an OIDC Relying Party or a service
downstream), that were provided by a [Broker](#term-broker), to make an
authorization decision at least in part based on inspecting GA4GH claims and
allows access to a specific set of underlying resources in the target
environment or platform. This abstraction allows for a variety of models for
how systems consume these claims in order to provide access to resources.
Access can be granted by either issuing new access tokens for downstream
services (i.e. the Claim Clearinghouse may act like an authorization server)
or by providing access to the underlying resources directly (i.e. the Claim
Clearinghouse may act like a resource server). Some Claim Clearinghouses may
issue access tokens that may contain a new set of GA4GH Claims and/or a
subset of GA4GH claims for downstream consumption.

<a name="term-data-holder"></a> **Data Holder** -- An organization that
protects a specific set of data. They hold data (or its copy) and respects
and enforces the data owner's decisions on who can access it. A data owner
can also be a data holder. Data holders run an
[Claim Clearinghouse Server](#term-claim-clearinghouse) at a minimum.

<a name="term-data-owner"></a> **Data Owner** -- An organization that manages
data and, in that role, has capacity to decide who can access it. For
instance, a Data Access Committee (DAC).

<a name="term-passport-scoped-access-token"></a> **Passport-Scoped Access
Token** -- A JWT bearer token, returned as an OAuth2 access token as
described herein, encoded via JWS Compact Serialization per
[RFC7515](https://datatracker.ietf.org/doc/html/rfc7515), containing
`ga4gh_passport_v1` as a space-separated entry within the `scope` claim but
does not contain [GA4GH Claims](#term-ga4gh-claim).

<a name="term-passport-scoped-access-token"></a> **Self-Contained Passport** --
A JWT that contains one or more [GA4GH Claims](#term-ga4gh-claim) as per the
[Self-Contained Passport Format](#self-contained-passport-issued-by-broker)
section for use with some GA4GH-compatible service endpoints using the `POST`
method. The Self-Contained Passport is a JWT encoded via JWS Compact
Serialization per [RFC7515](https://datatracker.ietf.org/doc/html/rfc7515).
For more details, see the [Conformance for Brokers](#conformance-for-brokers)
section.

<a name="term-visa-issuer"></a> <a name="term-embedded-token-issuer"></a>
**Visa Issuer** (aka "Embedded Token Issuer") -- a service that signs
[Visas](#term-visa).

<a name="term-visa"></a> <a name="term-embedded-token"></a>
**Visa** (aka "Embedded Token") -- A [GA4GH Claim](#term-ga4gh-claim)
value or entry within a list or object of a GA4GH Claim that contains a JWT
encoded via JWS Compact Serialization per
[RFC7515](https://datatracker.ietf.org/doc/html/rfc7515).
It MUST be signed by a [Visa Issuer](#term-visa-issuer). A Visa MAY be passed
through various [Brokers](#term-broker) as needed while retaining the token
signature of the original Visa Issuer.

### Relevant Specifications

[OIDC Spec](http://openid.net/specs/openid-connect-core-1_0.html) -
Authorization Code Flow and Implicit Flow will generate id_tokens and
access_tokens from the Broker.

[JWT](https://tools.ietf.org/html/rfc7519) - Specific implementations MAY extend
this structure with their own service-specific JWT claim names as top-level
members of this JSON object. Recommended "extensions" are in the
[Permissions](#authorizationclaims) section. The JWT specified here follows JWS
headers specification from [RFC7515](https://tools.ietf.org/html/rfc7515).

[JWS](https://tools.ietf.org/html/rfc7515) - JSON Web Signature (JWS) is the
specific JWT to use for this spec.

[Transport Layer Security (TLS, RFC 5246](https://tools.ietf.org/html/rfc5246)).
Information passed among clients, Applications, Brokers, and Claim
Clearinghouses MUST be protected using TLS.

[OIDC Discovery](https://openid.net/specs/openid-connect-discovery-1_0.html)

[OAuth 2.0 Threat Model and Security Considerations (RFC 6819)](https://tools.ietf.org/html/rfc6819).

[GA4GH Passport](https://github.com/ga4gh-duri/ga4gh-duri.github.io/blob/master/researcher_ids/ga4gh_passport_v1.md)

### Flow of Claims 

![FlowOfClaims]({% link AAI/claim_flow_of_data_basic.svg %})

The above diagram shows how claims flow from a [Claim
Source](#term-claim-source) to a [Claim
Clearinghouse](#term-claim-clearinghouse) that uses them. This does not
label all of the Relying Party relationships along this chain, where
each recipient in the chain is typically -- but not always -- the
relying party of the auth flow that fetches the claims from upstream.

Implementations may introduce clients, additional services, and protocols --
not detailed in the above diagram -- to provide the mechanisms to move the data
between the Claim Repository and the [Broker](#term-broker).
These mechanisms are unspecified by the scope of this specification except that
they MUST adhere to security and privacy best practices, such as those outlined
in this specification, in their handling of protocols, claims, tokens and
related data. The flow between these components (represented by black arrows)
MAY not be direct or conversely services shown as being separate MAY be
combined into one service. For example, some implementations MAY deploy one
service that handles the responsibilities of both the Visa Issuer and
the Broker.

### Profile Requirements 

#### Client/Application Conformance 

1.  Confidential clients (keep the client secret secure - typically
    server-side web-applications) MUST implement OIDC Authorization Code
    Flow (with Confidential Client)
    <http://openid.net/specs/openid-connect-basic-1_0.html>

2.  Public Clients (typically javascript browser clients)
    SHOULD implement OIDC Implicit Flow
    (<http://openid.net/specs/openid-connect-implicit-1_0.html>)

    1.  MUST use "id_token token" response_type for authentication.

    2.  Public Clients like mobile apps that use Authorization Code Grant SHOULD implement some additional protection such as PKCE (<https://tools.ietf.org/html/rfc7636>) .

3.  Conform to [revocation requirements](#token-revocation).

4.  Protection of Confidential Information

    1.  Sensitive information (e.g., including client secrets,
        authorization codes, id_tokens, access_tokens) will be passed over
        encrypted channels as per
        [OpenIDC Implementation Guide](https://openid.net/specs/openid-connect-basic-1_0.html).

    2.  All responses that contain tokens, secrets, or other sensitive
        information MUST include the following HTTP response header fields and
        values (as per [OpenIDC Implementation Guide](https://openid.net/specs/openid-connect-basic-1_0.html)). 

        1.  Cache-Control: no-store

        2.  Pragma: no-cache
        
5.  MUST provide protection against Client attacks as outlined in
    [RFC 6819](https://tools.ietf.org/html/rfc6819).

6.  If using [Self-Contained Passports](#term-self-contained-passport) as part of calling a
    service endpoint:
    
    1.  Clients MUST use the `POST` method.

    2.  Clients MUST NOT attach the Self-Contained Passport as part of the `Authorization`
        or any other header.
        
    3.  Clients MUST include the Self-Contained Passport as part of the request
        payload as per the Resource Server service endpoint specification. Service endpoints
        MAY use one of:
        
        1.  Header of `Content-Type: application/x-www-form-urlencoded` or similar
            multipart form content types as per [RFC1867](https://www.ietf.org/rfc/rfc1867)
            with the Self-Contained Passport as one of the parameters specified to
            include.
        
        2.  A different `Content-Type` header that allows the Self-Contained Passport
            to be included as part of a structural field.
            (e.g. `Content-Type: application/json` as per [RFC4627](https://www.ietf.org/rfc/rfc4627)).

    4. Clients MAY discover if Self-Contained Passports are available from a given Broker
       via OIDC Discovery and determine all options where Visas may be obtained. If
       `ga4gh_visa_modes_supported` is not present, the Client SHOULD assume a value of
       "user_info".
            
#### Conformance for Brokers 

1.  Brokers operate downstream from IdPs or provide their own IdP service. They
    issue id_tokens and access_tokens (and potentially other tokens such as refresh
    tokens or Self-Contained Passports) for consumption within the GA4GH compliant
    environment.

    1.  A Broker MUST issue both [Passport-Scoped Access Tokens](#term-passport-scoped-access-token)
        (access_tokens) and id_tokens.

        1.  This document makes no specifications for id_tokens.

    2.  Access_tokens MUST be in JWS format  

        1.  Access tokens for GA4GH use MUST be a [GA4GH JWT](#ga4gh-jwt-format) using
            [Passport-Scoped Access Token format](#passport-scoped-access-token-issued-by-broker).

        2.  Access tokens do not contain GA4GH Claims directly in the access token.

        3.  Access tokens MAY contain non-GA4GH Claims directly in the access token.

    3.  A Broker MAY issue [Self-Contained Passports](#term-self-contained-passport).

        1.  Self-Contained Passports MAY be large and are only for use via POST within
            GA4GH-compatible service endpoints.

        2.  Self-Contained Passports MUST NOT be used with OAuth2 endpoints that require
            an `Authorization` header.

        3.  There is no need to call /userinfo to receive GA4GH Claims on a Self-Contained
            Passport as these claims are already included in the bearer token's payload.
            
        4.  If supporting Self-Contained Passports, a Broker MUST:

            1.  Include additional OIDC Discovery information as indicated below.

            2.  Provide the Passport Endpoint compliant with [Broker Passport
                Endpoint](#broker-passport-endpoint) section of this specification.

2.  Broker MUST support [OIDC Discovery
    spec](https://openid.net/specs/openid-connect-discovery-1_0.html)

    1.  MUST include and support proper
        [Metadata](https://openid.net/specs/openid-connect-discovery-1_0.html#ProviderMetadata)
        (i.e. must have a `jwks_uri` as required that’s reachable by a Claim
        Clearinghouse)
        
    2.  If supporting Self-Contained Passports, the Broker MUST:

        1.  Include `ga4gh_passport_endpoint` that is compliant with the [Broker Passport
            Endpoint](#broker-passport-endpoint) section of this specification.
        
        2.  Include `ga4gh_visa_modes_supported` this is an array of string values.
        
            1.  "user_info": Visas may be available as part of `<ga4gh-visa-cliams>`
                within the /userinfo response.
        
            2.  "ga4gh_passport_endpoint": Visas may be available as part of a
                Self-Contained Passport at the location indicated by looking up
                the `ga4gh_passport_endpoint` entry.

3.  Broker MUST support public-facing /userinfo endpoint as per [section 5.3 of the OIDC
    specification](https://openid.net/specs/openid-connect-core-1_0.html#UserInfo).

    1.  When presented with a valid Passport-Scoped Access Token, the /userinfo endpoint MUST return
        claims in the specified
        [User Info Format](#claims-sent-to-data-holder-by-a-broker-via-userinfo) using
        either an `application/json` or `application/jwt` encoding.

    2.  The Broker MUST include the claims_parameter_supported in the discovery service
        to indicate whether or not the Broker supports the [OIDC claims request
        parameter](https://openid.net/specs/openid-connect-core-1_0.html#ClaimsParameter)
        on /userinfo to subset which claim information will be returned. If the Broker
        does not support the OIDC claims request parameter, then all claim information
        for the provided scopes eligible for release to the requestor MUST be returned.
        
4.  Broker MUST provide protection against attacks as outlined in
    [RFC 6819](https://tools.ietf.org/html/rfc6819).

5.  The user represented by the identity of the access token MUST have agreed to
    release claims related to the requested scopes as part of generating tokens
    that can expose GA4GH Claims that represent user data or permissions.
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

6.  By signing an access token, an Broker asserts that the GA4GH Claims that
    token makes available at the /userinfo endpoint -- not including any
    Visas -- were legitimately derived from their [Claim
    Sources](#term-claim-source), and the content is presented and/or
    transformed without misrepresenting the original intent.
    
    When a Broker acts as a Visa Issuer and signs Visas, then those signatures
    adhere to the same assertion criteria as outlined in the [Conformance
    for Visa Issuers](#conformance-for-visa-issuers) section of this
    specification.

    When a Broker provides Visas from other Visa Issuers, it is providing
    them "as is" (i.e. it provides no additional assurance as to the quality,
    authenticity, or trustworthiness of the claims from such tokens and any such
    assurances are made by the issuer of the Visa, i.e. the Visa Issuer).

<a name="conformance-for-embedded-token-issuers"></a>
#### Conformance for Visa Issuers

1.  A [Visa Issuer](#term-visa-issuer) MUST provide one or more of the following
    types of [Visas](#term-visa):

    1.  <a name="term-visa-access-token"></a> <a name="term-embedded-access-token"></a>
        **Visa Access Token** -- The Visa Issuer is providing an OIDC provider
        service and issues OIDC-compliant access tokens in a specific format that can
        be used as a Visa.
    
        1.  The Visa payload MUST contain the "openid" scope. That
            is, it has a `scope` JWT claim that contains "openid" as a
            space-delimited substring.
            
        2.  Visa is a JWS string and follows the [Visa Access Token
            Format](#visa-access-token-format). This includes
            having GA4GH Claims as JWT claims directly in the Visa.
            
        3.  Visa Issuer MUST support [OIDC Discovery
            spec](https://openid.net/specs/openid-connect-discovery-1_0.html),
            and provide `jwks_uri` as
            [Metadata](https://openid.net/specs/openid-connect-discovery-1_0.html#ProviderMetadata)
            that may be reachable by a Claim Clearinghouse.
        
        4.  Visa Issuer MUST support public-facing
            /userinfo endpoint. When presented with a valid Visa Access
            Token, the /userinfo endpoint MUST return a success status
            and MAY return the current values for GA4GH Claims that were
            included within the Visa Access Token, however returning
            GA4GH Claims from the /userinfo endpoint for Visa Access
            Tokens is OPTIONAL.
            
        5.  If the Visa Access Token's `exp` exceeds the `iat` by
            more than 1 hour, the Visa Issuer should expect
            Claim Clearinghouses to use [Access Token Polling](#at-polling) and
            MUST provide a means to revoke Visa Access Tokens. The
            /userinfo endpoint MUST return an HTTP status 401 as per
            [RFC6750 section 3.1](https://tools.ietf.org/html/rfc6750#section-3.1)
            when provided an Visa Access Token that has completed the
            revocation process.

        6.  The JWS header MUST NOT have `jku` specified.

        7.  Visa Issuer MUST provide protection against
            attacks as outlined in [RFC
            6819](https://tools.ietf.org/html/rfc6819).
        
    2.  <a name="term-visa-document-token"></a> <a name="term-embedded-document-token"></a>
        **Visa Document Token** -- The Visa Issuer does not need to be a
        be a OIDC provider, and MAY provide tokens of this type without any
        revocation process.
        
        1.  The JWS header contains `jku` as specified by [RFC7515 Section
            4.1.2](https://tools.ietf.org/html/rfc7515#section-4.1.2), and
            provides the corresponding public-facing endpoint to fetch
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
    
2.  A Visa Issuer MAY generate the `exp` timestamp to enforce
    its policies and allow Claim Clearinghouses to understand the intent of
    how long the claim may be used before needing to return to the Visa Issuer
    to refresh the claim. As a non-normative example, if a
    GA4GH claim expires in 25 years (or even never expires explicitly in the
    Claim Repository), the Visa Issuer could set the `exp` to
    1 day into the future plus issue a refresh token in order to force the
    refresh token to be used when a downstream Claim Clearinghouse is still
    interested in using such a claim after 1 day elapses.

3.  By signing a Visa, a Visa Issuer asserts that
    the GA4GH claims made available by the token were legitimately derived
    from their [Claim Sources](#term-claim-source), and the content is
    presented and/or transformed without misrepresenting the original intent,
    except for accommodating for `exp` timestamps to be represented as
    indicated above.

#### Conformance for Claim Clearinghouses

1.  Claim Clearinghouses MUST trust at least one Broker.

    1.  Claim Clearinghouses MAY trust more than one Broker
    
    2.  The responsibility of risk assessment of a Broker is on the Claim Clearinghouse to trust an access token. RECOMMENDED to trust the minimum set of Brokers required to obtain the access token payload.
    
2.  Claim Clearinghouses MUST either check the validity of the access token or treat the access
    token as opaque.

    1.  If treating the token as a JWT a Claim Clearinghouse:

        1. Even though JWTs are expected to be submitted against /userinfo, a Claim Clearinghouse SHOULD check the Token’s signature via JWKS or having stored the
            public key.

            1.  A metadata URL (.well-known URL) SHOULD be used here to use the
                jwks_uri parameter.
                
        2.  MUST check `iss` attribute to ensure a trusted Broker has generated
            the token.
            
            1.  If evaluating a Visa, trust MUST be established based
                on the signer of the Visa itself. In Claim
                Clearinghouses participating in open federation, the Claim
                Clearinghouse does not necessarily have to trust the Broker that
                includes Visas within another token in order to use
                the Visa (although the Claim Clearinghouse MAY require
                any other Broker involved in the propagation of the claims to
                also be trusted if the Claim Clearinghouse needs to restrict its
                trust model).

        3.  MUST check `exp` to ensure the token has not expired.

        4.  MAY additionally check `aud` to make sure Relying Party is trusted
            (client_id).

    2.  If treating the token as an opaque a Claim Clearinghouse MUST know in
        advance where to find a corresponding /userinfo. This may limit the
        functionality of accepting tokens from some Brokers.

3.  Claim Clearinghouse or downstream applications MAY use [/userinfo
    endpoint](https://openid.net/specs/openid-connect-core-1_0.html#UserInfo)
    (derived from the access_token JWT’s `iss`) to request claims and MAY make
    use of the [OIDC claims request
    parameter](https://openid.net/specs/openid-connect-core-1_0.html#ClaimsParameter)
    to subset which claims are requested if supported by the Broker for the
    claims in question.

4.  Claim Clearinghouses service can be a Broker itself and would follow the
    [Conformance For Brokers](#conformance-for-brokers).

5.  Claim Clearinghouses MUST provide protection against attacks as outlined in
    [RFC 6819](https://tools.ietf.org/html/rfc6819).

    1. Section 5.1.6 of RFC 6819 contains a SHOULD section that states `Ensure that client applications do not share tokens with 3rd parties.` This profile provides a mechanism for Clearinghouses to consume access tokens from multiple brokers in a manner that does not involve 3rd parties. Client applications SHOULD take care to not spread the tokens to any other services that would be considered 3rd parties.
        
6.  If making use of [Visas](#term-visa):

    1.  The Claim Clearinghouse MUST validate that all token checks pass (such as
        the token hasn’t expired) as described elsewhere in this specification and
        the underlying OIDC specifications.

    2.  If making use of [Visa Access Tokens](#term-visa-access-token):
    
        1. Token checks MUST be performed to ensure it complies with the access
           token specification.
    
        2. In addition to other validation checks, a Visa is considered
           invalid if it is more than 1 hour old (as per the `iat` claim) AND
           [Access Token Polling](#at-polling) does not confirm that the token is still
           valid (e.g. provide a success status code).
                      
    3.  If making use of [Visa Document Tokens](#term-visa-document-token):

        1.  Fetching the public keys using the `jku` is not required if a Claim
            Clearinghouse has received the keys for the given `iss` via a trusted,
            out-of-band process.

        2.  If a Claim Clearinghouse is to use the `jku` URL to fetch the public
            keys to verify the signature, then it MUST verify that the `jku` is
            trusted for the given `iss` as part of the Claim Clearinghouse's
            trusted issuer configuration. This check MUST be performed before
            calling the `jku` endpoint.

7.  <a name="at-polling"></a> **Access Token Polling**: Clients MAY use access tokens,
    including Visas, to occasionally check which claims are still valid
    at the associated /userinfo endpoint in order to establish whether the user
    still meets the access requirements.
    
    This MUST NOT be done more than once per hour (excluding any optional retries)
    per Claim Clearinghouse. Any request retries MUST include exponential backoff
    delays based on best practices (e.g. include appropriate jitter). At a
    minimum, the client MUST stop checking once any of the following occurs:

    1.  The system can reasonably determine that authorization related to these
        claims are no longer needed by the user. For example, all downstream cloud
        tasks have terminated and the related systems will no longer be using the
        access token nor any downstream tokens that were authorized by evaluating
        access requirements against claims in the token.

    2.  The JWT access token has expired as per the `exp` field.

    3.  The client has detected that the user owning the identity or a system
        administrator has revoked the access token or a refresh token related to
        minting the access token.

    4.  The /userinfo endpoint returns an HTTP status that is not retryable.
        For example, /userinfo returns HTTP status 400.

    5.  If the /userinfo endpoint returns an updated set of GA4GH Claims (this is
        an OPTIONAL feature of an Visa Issuer), then the Claim
        Clearinghouse MUST use the updated GA4GH Claims and ignore the original
        GA4GH Claim values in the Visa Access Token. If the Claim
        Clearinghouse is unable to adjust for the the updated GA4GH Claims, then
        it MUST act as though the token was revoked.

8. Claim Clearinghouses MAY choose to accept Self-Contained Passports.

   1. MUST NOT be accepted as part of an authorization header. (i.e. use `POST`
      method payload to receive the passport)
      
   2. Claim Clearinghouses that accept Content-Type `application/json` SHOULD
      accept a JSON object with the attribute name
      `ga4gh_passport:self_contained_v1` having the self-contained passport as a
      value.

### GA4GH JWT Format

A well-formed JWS-Encoded JSON Web Token (JWT) consists of three concatenated
Base64url-encoded strings, separated by dots (.) The three sections are: header,
payload and signature. These JWTs follow [RFC7515](https://tools.ietf.org/html/rfc7515) (JWS)
and utilize a number of [standard JWT claim names](https://www.iana.org/assignments/jwt/jwt.xhtml)
as per the registration process.
This profile is agnostic to the format of the id_token.

<a name="access_token-issued-by-broker"></a>
#### Passport-Scoped Access Token issued by Broker

Header - The `kid` parameter (see [RFC7515 section
4.1.4](https://tools.ietf.org/html/rfc7515#section-4.1.4)) must be included
and `alg` must be "RS256".
```
{
 "typ": "JWT",
 "alg": "RS256",
 "kid": "<key-identifier>"
}
```

Payload:
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
 "scope": "openid <ga4gh-passport-scopes>",
 <additional claims>
}
```
-   `iss`: REQUIRED. MUST be able to be appended with
    .well-known/openid-configuration to get spec of Broker.

-   `sub`: REQUIRED. Authenticated user unique identifier.

-   `idp`: OPTIONAL. SHOULD contain the IDP the user used to auth with.
    A non-normative example is "google". This does not have to be unique and
    can be used just to help inform if that is what a data owner or data holder
    needs.

-   `aud`: OPTIONAL. If provided, it MUST contain the Oauth Client ID of the
    relying party.

-   `iat`: REQUIRED. Time issued.

-   `exp`: REQUIRED. Time expired.

-   `jti`: RECOMMENDED. a unique identifier for the token as per
    [RFC7519 Section 4.1.7](https://tools.ietf.org/html/rfc7519#section-4.1.7)

-   `scope`: REQUIRED. Includes verified scopes. MUST include "openid". Will also
    include any `<ga4gh-passport-scopes>` from the GA4GH Passport specification
    (e.g. "ga4gh_passport_v1" is the [scope for GA4GH
    Passports](https://github.com/ga4gh-duri/ga4gh-duri.github.io/blob/master/researcher_ids/ga4gh_passport_v1.md#requirement-7)).
    The `scope` claim is defined by [RFC8693 section 4.2](https://datatracker.ietf.org/doc/html/rfc8693#section-4.2).

-   `additional claims`: OPTIONAL. Any other additional non-GA4GH claims are allowed. This specification does not dictate the format of other claims.

#### Claims sent to Data Holder by a Broker via /userinfo

Only the GA4GH claims truly must be as prescribed here. Refer to OIDC Spec for
more information. The /userinfo endpoint MAY use `application/json` or
`application/jwt`. If `application/jwt` is returned, it MUST be signed as per
[UserInfo](https://openid.net/specs/openid-connect-core-1_0.html#UserInfoResponse).

```
{
 "iss": "https://<issuer-website>/",
 "sub": "<subject-identifier>",
 "aud": [
  "<client-id1>",
  "<client-id2>" ...
 ],
 <ga4gh-visa-claims>
}
```

-   `iss` and `sub`: REQUIRED.

-   `aud`: OPTIONAL.

-   `<ga4gh-visa-claims>`: OPTIONAL. GA4GH Claims are generally included as
    specified by the GA4GH Passport specification based on the Passport-Scoped
    Access Token's scope provided. Even when requested by the appropriate scopes,
    these GA4GH Claims may not be included in the response for various reasons, such
    as if the user does not have any GA4GH Claims or because they are only provided
    as part of a Self-Contained Passport. See
    [Authorization/Claims](#authorizationclaims) for an example of a GA4GH
    Claim.

<a name="embedded-token-issued-by-embedded-token-issuer"></a>
#### Visa issued by Visa Issuer

There are two supported formats for Visas.

<a name="embedded-access-token-format"></a>
##### Visa Access Token Format

Header format:

```
{
 "typ": "JWT",
 "alg": "RS256",
 "kid": "<key-identifier>"
}
```

where:

1.  `alg` MUST be "RS256".

2.  The header MUST NOT contain a `jku`.

Payload format:

```
{
 "iss": "https://<issuer-website>/",
 "sub": "<subject-identifier>",
 "iat": <seconds-since-epoch>,
 "exp": <seconds-since-epoch>,
 "jti": <token-identifier>,
 "scope": "openid <ga4gh-spec-scopes>"
 <ga4gh-visa-claims>
}
```

where:

1.  The standard JWT payload claims `iss`, `sub`, `iat`, `exp` are
    all REQUIRED.

2.  `jti` is RECOMMENDED.

3.  `scope` is REQUIRED and MUST be a string containing a space-delimited set of
    scope names. "openid" MUST be included as a scope name. The `scope` claim
    name is defined by [RFC8693 section 4.2](https://datatracker.ietf.org/doc/html/rfc8693#section-4.2).

4.  The payload claims MAY contain at least one GA4GH Claim
    (`<ga4gh-visa-claims>`).

5.  The payload claims MUST NOT include `aud`.

<a name="embedded-document-token-format"></a>
##### Visa Document Token Format

Conforms with JWS format requirements and is signed by a Visa Issuer.

1. MUST be a JWS string.

2. MUST contain a `jku` in the header.

3. MUST NOT contain "openid" as a space-delimited substring of the `scope`
   JWT claim, if the `scope` claim is provided.
   
4. The following headers and JWT claims in the payload are REQUIRED
   (here shown in its decoded JSON form):

   ```
   {
     "typ": "JWT",
     "alg": "RS256",
     "jku": "https://<jwk-URL>",
     "kid": "<key-identifier>"
   }.
   {
     "iss": "https://<issuer-website>/",
     "sub": "<subject-identifier>",
     "iat": <seconds-since-epoch>,
     "exp": <seconds-since-epoch>,
     "jti": <token-identifier>,
     <ga4gh-visa-claims>
   }.
   <signature>
   ```

   -   `typ`: MUST be "JWT".

   -   `alg`: MUST be "RS256".
     
   -   `jti`: RECOMMENDED. A unique identifier for the token as per
       [RFC7519 Section 4.1.7](https://tools.ietf.org/html/rfc7519#section-4.1.7)
       is RECOMMENDED.
     
   -   `<ga4gh-visa-claims>`: OPTIONAL. One or more GA4GH Claims MAY be
       provided. See [Authorization/Claims](#authorizationclaims) for an
       example.

#### Authorization/Claims 

User attributes and claims are being developed in the [GA4GH Passport
specification](https://github.com/ga4gh-duri/ga4gh-duri.github.io/blob/master/researcher_ids/ga4gh_passport_v1.md)
by the DURI work stream.

A non-normative example of a GA4GH Passport, as referred to
in as `<ga4gh-passport-claims>` within the JWT formatting sections of this
specification, is:

```
"ga4gh_passport_v1": [
  <ga4gh passport value>
]
```

See the [GA4GH Passport
Claim Format](https://github.com/ga4gh-duri/ga4gh-duri.github.io/blob/master/researcher_ids/ga4gh_passport_v1.md#passport-claim-format)
for more details.

### Broker Passport Endpoint

This endpoint is only REQUIRED if the Broker has published the endpoint's location
via OIDC Discovery. See the [Conformance for Brokers](conformance-for-brokers]
section for details.

#### Passport Endpoint Request

```
POST <ga4gh-passport-endpoint>
Authorization: Bearer <passport-scoped-access-token>
Content-Type: application/json

{
  "ga4gh_passport:self_contained_v1": "<self-contained-passport-jws>",
  "targets": {
    "<aud>": ["<visa-ref>"],
    ...
  }
}
```

MUST be called with one of, but NOT both:

1.  `Authorization` header: for use with Passport-Scoped Access Tokens.

2.  `ga4gh_passport:self_contained_v1` JSON field: for use by previously allocated
    Self-Contained Passports.

`targets` only for use by clients providing Passport-Scoped Access Tokens,
i.e. the client MUST NOT change the audience of an existing Self-Contained Passport.
If `targets` is present it MUST contain at least one entry:

    -   One Self-Contained Passport will be generated for each entry in the
        `targets` map, or the Broker MUST return an error if there are too
        many entries.

    -   `<aud>`: the target audience string for the token to be included
        as one of the array entries in the `aud` JWT claim as part of the
        Self-Contained Passport response.
        
    -   `<visa-ref>`: the `value` string of a Visa. The access MUST NOT provide
        more access than the authorization allowed by the token as part of calling
        this endpoint.
        
        -   However, the `<visa-ref>` may offer a more specific subset
            of data of any visa that is available by Visas within scope of the
            caller's token.
            
        -   The format of `<visa-ref>` for subsetting access within a broader
            `<visa-ref>` is up to the Visa Issuer, and is beyond the scope of this
            specification.
            
    -   Example usage of requesting multiple tokens would be to federate calls
        across many nodes in a network, each expecting a different audience.
        (e.g. federating across 100 GA4GH Beacon nodes from different providers)

#### Broker Passport Endpoint Processing

1.  The Broker MUST validate the authorization token received according to
    requirements for tokens elsewhere in this specification.

2.  The scope of authorization MUST NOT exceed that of the caller's authorization,
    whether using an `Authorization` header or a Self-Contained Passport.
    
    1.  The Broker SHOULD indicate errors in the response for each `<visa-ref>`
        that attempts to upscope access, and still provide Self-Contained Passports
        for any remaining `<visa-ref>` unless there are no valid `<visa-ref>`
        entries.

3.  The Broker SHOULD limit the number of tokens it can produce to some reasonable
    number, and indicate such a number as part of OIDC Discovery.

#### Passport Endpoint Response

If the Broker's token limit was not exceeded and at least one valid token was minted,
the Broker's response takes the following form:

```
Content-Type: application/json

{
  "tokens": {
    "<aud>": "<self-contained-passport-jws>",
    ...
  },
  "status": {
    "aud": {
      "<aud>": <status-code>,
      ...
    }
    "visas": {
      "<visa-ref>": <status-code>,
      ...
    }
  }
}
```

Where:

-   `tokens`: REQUIRED as the map of tokens per `aud` in the request structure
    and each `<self-contained-passport-jws>` is a JWS Compact String of a Self-Contained
    Passport.
    
-   `status`: OPTIONAL returns a map of each status code per `<aud>` and/or
    `<visa-ref>`.
    
    -   `status-code`: an HTTP status code per [RFC2616](https://datatracker.ietf.org/doc/html/rfc2616)
        or extensions thereof that best represents the outcome, with the following
        extensions:
        
        1.  `207`: Includes only a subset of what was requested, interpreted from
            [RFC4918](https://datatracker.ietf.org/doc/html/rfc4918). See details
            under `<visa-ref>` status entries for details.


Token Revocation
----------------

#### Claim Source Revokes Claim

Given that claims can cause downstream access tokens to be minted by Claim
Clearinghouses and such downstream access tokens may have little knowledge or no
connectivity to sources of claims, it can be challenging to build robust
revocation capabilities across highly federated and loosely coupled systems.
During the lifetime of the downstream access token, some systems may require
that claims are no longer inspected nor updated.

In the event that a [Claim Source](#term-claim-source) revokes a claim within
a [Claim Repository](#term-claim-repository), downstream Visa
Issuers, Brokers, Claim Clearinghouses, and other Authorization or Resource
Servers MUST at a minimum provide a means to limit the lifespan of any given
access tokens generated as a result of claims. To achieve this goal, servers
involved with access may employ one or more of the following options:

1.  Have each GA4GH Claim or sub-object be paired with an expiry timestamp.
    Expiry timestamps would require users to log in occasionally via
    an Broker in order to refresh claims. On a refresh, expiry timestamps can
    be extended from what the previous claim may have indicated.
    
2.  Provide GA4GH Claims in the form of [Visa Access
    Tokens](#term-visa-access-token) to allow downstream Claim
    Clearinghouses to periodically check the validity of the token via calls
    to the /userinfo endpoint as per [Access Token Polling](#at-polling).

3.  Provide refresh tokens at every level in the system hierarchy and use
    short-lived access tokens. This may require all contributing systems to
    support [OIDC offline
    access](https://openid.net/specs/openid-connect-core-1_0.html#OfflineAccess)
    refresh tokens to deal with execution of processes where the user is no
    longer actively involved. In the event that refresh tokens experience
    errors, the systems involved must eventually revoke the ability for
    downstream access tokens to be replaced via refresh tokens (although some
    level of delay to reach out to a user to try to resolve the issue may be
    desirable).

4.  Provide some other means for downstream Claim Clearinghouses or other
    systems that create downstream access tokens to be informed of a material
    change in upstream claims such that action can be taken to revoke the token,
    revoke the refresh token, or revoke the access privileges associated with
    such tokens.

#### Revoking Access from Bad Actors

In the event that a system or user detects that a specific user is misbehaving or
has falsified claims despite previous assurances that access was appropriate,
there MUST be a mechanism to withdrawal access from existing tokens and update
claims to prevent further tokens from being minted.

1.  Systems MUST have a means to revoke existing refresh tokens or remove
    permissions from access tokens that are sufficiently long-lived enough to
    warrant taking action.
    
    -   If an access token is long-lived, then the access token MUST be
        revocable, and once revoked the /userinfo endpoint MUST NOT return
        claims. In this event, an appropriate error status MUST be returned as per
        [section 5.3.3 of the OIDC specification](https://openid.net/specs/openid-connect-core-1_0.html#UserInfoError).
        
    -   [Access Token Polling](#at-polling) can allow downstream systems to detect
        token revocation and remove access accordingly.

2.  A process MUST exist, manual or automated, to eventually remove or invalidate
    related claims from the [Claim Repository](#term-claim-repository).

#### Limited Damage of Leaked Tokens

In order to limit damage of leaked tokens, systems MUST provide all of the
following:

1.  Be able to leverage mechanisms in place for revoking claims and tokens 
    for other purposes to also limit exposure of leaked tokens.

2.  Follow best practices for the safekeeping of refresh tokens or longer lived
    tokens (should longer lived tokens be needed).

3.  Limit the life of refresh tokens or long lived keys before an auth challenge
    occurs or otherwise the refresh token simply fails to generate more access
    tokens.

4.  Any signed tokens that may be stored by participating services SHOULD be
    encrypted at rest and follow best practices to limit the ability of
    administrators from decrypting this content.
