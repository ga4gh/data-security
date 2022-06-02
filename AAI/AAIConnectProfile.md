---
layout: page
title: AAI OIDC Profile
permalink: aai-openid-connect-profile
---

### 1.2 Draft Work In Progress 

| Date       | Editor    | Notes                                                                         |
|------------|-----------|-------------------------------------------------------------------------------|
| 2022-05-12 | TomConner | Edits per discussion in PR and call                                           |
| 2022-05-09 | TomConner | Changed wording in Abstract per Max's comments                                |
| 2022-05-06 | TomConner | Embedded Token and Token Container -> Visa and Passport                       |
| 2022-05-05 | TomConner | Data owner -> data controller                                                 |
| 2022-03-16 | Patto     | Abstract clarified to support all flows                                       |
| 2022-03-10 | TomConner | Token endpoints; spec references                                              |
| 2022-02-24 | TomConner | Merged edits from David Bernick's bernick_clearinghouse_clarifications branch |

### Abstract
{:.no_toc}

This specification profiles the OpenID Connect protocol (OIDC) to provide a federated
(multilateral) authorization infrastructure for greater
interoperability between genomics institutions in a manner specifically
applicable to (but not limited to) the sharing of restricted datasets.

In particular, this specification profiles tokens, endpoints and flows that
enable an OIDC provider (called a [Broker](#term-broker)) to
provide [Passports](#term-passport) and [Visas](#term-visa) to downstream consumers
called [Claim Clearinghouses](#term-claim-clearinghouse).

[GA4GH DURI Passports](https://github.com/ga4gh-duri/ga4gh-duri.github.io/blob/master/researcher_ids/ga4gh_passport_v1.md) can then be used for authorization purposes by downstream
systems.

This specification is suggested to be used together
with others that specify the syntax and semantics of the [GA4GH Claims](#term-ga4gh-claim) exchanged.

### Table of Contents
{:.no_toc}

* toc
{:toc}

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
this is the `ga4gh_passport_v1` or `ga4gh_visa_v1` claim for GA4GH Passports v1.x (see 
[GA4GH DURI Passport](https://github.com/ga4gh-duri/ga4gh-duri.github.io/blob/master/researcher_ids/ga4gh_passport_v1.md)).
Note that GA4GH is not the organization making the claim nor taking responsibility
for the claim as this is a reference to a GA4GH documented standard only.

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
issue tokens that may contain a new set of GA4GH Claims and/or a
subset of GA4GH claims for downstream consumption (such as a Passport).

<a name="term-data-holder"></a> **Data Holder** -- An organization that
protects a specific set of data. They hold data (or its copy) and respects
and enforces the data controller's decisions on who can access it. A data controller
can also be a data holder. Data holders run an
[Claim Clearinghouse Server](#term-claim-clearinghouse) at a minimum.

<a name="term-data-controller"></a> **Data Controller** -- An organization that manages
data and, in that role, has capacity to decide who can access it. For
instance, a Data Access Committee (DAC).

<a name="term-passport-scoped-access-token"></a> **Passport-Scoped OAuth Access
Token** -- A JWT bearer token, returned as an OAuth2 access token as
described herein, encoded via JWS Compact Serialization per
[RFC7515](https://datatracker.ietf.org/doc/html/rfc7515), containing
`ga4gh_passport_v1` as a space-separated entry within the `scope` claim but
does not contain [GA4GH Claims](#term-ga4gh-claim).

<a name="term-passport"></a> **Passport** -- A signed and verifiable JWT container for holding [Visas](#term-visa).

<a name="term-passport-issuer"></a> **Passport Issuer** --
a service that creates and signs a [Passport](#term-passport-token) - in this case a JWT - holding [Visas](#term-visa).
* a service where a Broker, Client or Claims Clearinghouse may re-sign the JWT holding GA4GH Claims (such as [GA4GH Visas](https://github.com/ga4gh-duri/ga4gh-duri.github.io/blob/master/researcher_ids/ga4gh_passport_v1.md#passport-visa)) with their own authority.

<a name="term-token-endpoint"></a> **Token Endpoint** -- 
as defined by [OIDC-Core](http://openid.net/specs/openid-connect-core-1_0.html); see [Token Endpoint](https://openid.net/specs/openid-connect-core-1_0.html#TokenEndpoint).

<a name="term-userinfo-endpoint"></a> **UserInfo Endpoint** -- 
as defined by [OIDC-Core](http://openid.net/specs/openid-connect-core-1_0.html); see [UserInfo Endpoint](https://openid.net/specs/openid-connect-core-1_0.html#UserInfo).

<a name="term-visa-issuer"></a>
**Visa Issuer** -- a service that signs
[Visas](#term-visa). This service:
* may be a [Broker](#term-broker) itself
* may be used by a [Broker](#term-broker) as part of collecting GA4GH Claims that the Broker includes in responses from its UserInfo or Token Endpoint.

<a name="term-visa"></a> 
**Visa** -- A [GA4GH Claim](#term-ga4gh-claim)
value or entry within a list or object of a GA4GH Claim that contains a JWT
encoded via JWS Compact Serialization per
[RFC7515](https://datatracker.ietf.org/doc/html/rfc7515).
It MUST be signed by a [Visa Issuer](#term-visa-issuer). A Visa MAY be passed
through various [Brokers](#term-broker) as needed while retaining the token
signature of the original Visa Issuer.

### Relevant Specifications

[OIDC-Core](http://openid.net/specs/openid-connect-core-1_0.html) -
        Authorization Code Flow and Implicit Flow will generate id_tokens and
        access_tokens from the Broker.

[RFC7519-JWT](https://tools.ietf.org/html/rfc7519) - Specific implementations MAY extend
        this structure with their own service-specific JWT claim names as top-level
        members of this JSON object. Recommended "extensions" are in the
        [Permissions](#authorizationclaims) section. The JWT specified here follows JWS
        headers specification from [RFC7515-JWS](https://tools.ietf.org/html/rfc7515).

[RFC7515-JWS](https://tools.ietf.org/html/rfc7515) - JSON Web Signature (JWS) is the
        specific JWT to use for this spec.

[RFC5246-TLS](https://tools.ietf.org/html/rfc5246) - Transport Layer Security.
        Information passed among clients, Applications, Brokers, and Claim
        Clearinghouses MUST be protected using TLS.

[OIDC-Discovery](https://openid.net/specs/openid-connect-discovery-1_0.html)

[GA4GH Passport](https://github.com/ga4gh-duri/ga4gh-duri.github.io/blob/master/researcher_ids/ga4gh_passport_v1.md) - DURI

[RFC8693](https://www.rfc-editor.org/info/rfc8693)  Jones, M., Nadalin, A., Campbell, B., Ed., Bradley, J.,
        and C. Mortimore, "OAuth 2.0 Token Exchange", RFC 8693,
        DOI 10.17487/RFC8693, January 2020.

[RFC6819](https://www.rfc-editor.org/info/rfc6819) 
        Lodderstedt, T, McGloin, M., and P. Hunt, 
        "OAuth 2.0 Threat Model and Security Considerations", 
        RFC 6819, January 2013.

[RFC8725](https://www.rfc-editor.org/info/rfc8725)  Sheffer, Y., Hardt, D., and M. Jones, "JSON Web Token Best
        Current Practices", BCP 225, RFC 8725,
        DOI 10.17487/RFC8725, February 2020.
            

### Flow of Claims

@startuml
skinparam componentStyle rectangle
left to right direction

package "Unspecified clients, additional services, protocols" {
component "<b>Claim Source</b> (1)\norganisation" as ClaimSource1
component "<b>Claim Source</b> (2)\norganisation" as ClaimSource2
component "<b>Claim Source</b> (...)\norganisation" as ClaimSourceN

database "<b>Claim Repository</b>\nabstract service" as ClaimRepository
component "<b>Visa Issuer</b>\nabstract service\n(optional)" as ETI
}

package "Specified GA4GH AAI clients, services, protocols" {
component "<b>Broker</b>\nservice" as Broker #FAFAD2
component "<b>Claim Clearinghouse</b>\nservice" as ClearingHouse #9E7BB5
}

ClaimSource1 --> ClaimRepository : (unspecified)
ClaimSource2 --> ClaimRepository : (unspecified)
ClaimSourceN --> ClaimRepository : (unspecified)
ClaimRepository --> ETI : (unspecified)


ClaimRepository --> Broker : (unspecified)
ETI --> Broker : (unspecified)
Broker --> ClearingHouse : GA4GH AAI spec

@enduml

The above diagram shows how claims flow from [Claim Source(s)](#term-claim-source)
to a [Claim Clearinghouse](#term-claim-clearinghouse) that uses them. Only the
right hand portion of the flow is normative in that it is fully documented in this
specification.

Implementations may introduce clients, additional services, and protocols
to provide the mechanisms to move the data between the
[Claim Source(s)](#term-claim-source) and the [Broker](#term-broker). This diagram
shows *one possible mechanism* involving a repository service that persists claims from a variety of
organisations, and optionally then involving a separate visa issuer who
signs some claims.

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

#### Conformance for Brokers

1.  Brokers operate downstream from IdPs or provide their own IdP service. They
    issue id_tokens and access_tokens (and potentially refresh tokens) for
    consumption within the GA4GH compliant environment.

    1.  A Broker MUST issue both [Passport-Scoped Access Tokens](#term-passport-scoped-access-token)
        (access_tokens) and id_tokens.

        1.  This document makes no specifications for id_tokens.

    2.  Access_tokens MUST be in JWS format

        1.  Access tokens for GA4GH use MUST be a [GA4GH JWT](#ga4gh-jwt-format) using
            [Passport-Scoped Access Token format](#passport-scoped-access-token-issued-by-broker).

        2.  Access tokens do not contain GA4GH Claims directly in the access token.

        3.  Access tokens MAY contain non-GA4GH Claims directly in the access token.

2.  Broker MUST support [OIDC Discovery
    spec](https://openid.net/specs/openid-connect-discovery-1_0.html)

    1.  MUST include and support proper
        [Metadata](https://openid.net/specs/openid-connect-discovery-1_0.html#ProviderMetadata)
        (i.e. must have a `jwks_uri` as required that’s reachable by a Claim
        Clearinghouse)

3.  Broker MUST support a Token Endpoint or UserInfo Endpoint.

    1.  The Token Endpoint SHOULD be used for passport visa claims in 
        preference to the UserInfo Endpoint. 

    2.  When presented with a valid access token, the endpoint MUST return
        claims in the specified
        [Format]
       (#claims-sent-to-data-holder-by-a-broker-via-token-or-userinfo) using
        either an `application/json` or `application/jwt` encoding.

    3.  The Broker MUST include the claims_parameter_supported in the discovery service
        to indicate whether or not the Broker supports the [OIDC claims request
        parameter](https://openid.net/specs/openid-connect-core-1_0.html#ClaimsParameter)
        on UserInfo to subset which claim information will be returned. If the Broker
        does not support the OIDC claims request parameter, then all claim information
        for the provided scopes eligible for release to the requester MUST be returned.

4.  Broker MAY support a Token Exchange endpoint. If implemented, it MUST behave as described 
    for passport issuance in [Conformance For Passport Issuers](#conformance-for-passport-issuers).

5.  Broker MUST provide protection against attacks as outlined in
    [RFC 6819](https://tools.ietf.org/html/rfc6819).

6.  The user represented by the identity of the access token MUST have agreed to
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

7.  By signing an access token, an Broker asserts that the GA4GH Claims that
    token makes available at the UserInfo or Token Endpoint -- 
    not including any Visas -- were legitimately derived from their [Claim
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

TODO embedded-access-token is this a passport access token or a visa access token or something else

<a name="conformance-for-visa-issuers"></a>
#### Conformance for Visa Issuers

1.  A [Visa Issuer](#term-visa-issuer) MUST provide one or more of the following
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

        3.  Visa Issuer MUST support [OIDC Discovery
            spec](https://openid.net/specs/openid-connect-discovery-1_0.html),
            and provide `jwks_uri` as
            [Metadata](https://openid.net/specs/openid-connect-discovery-1_0.html#ProviderMetadata)
            that may be reachable by a Claim Clearinghouse.

        4.  Visa Issuer MUST support public-facing UserInfo Endpoint. When presented with a valid 
            Visa Access Token, the UserInfo Endpoint MUST return a success status and MAY return 
            the current values for GA4GH Claims that were included within the Visa Access Token, 
            however returning GA4GH Claims from the UserInfo Endpoint for Visa Access Tokens is 
            OPTIONAL.

        1.  If the Visa Access Token's `exp` exceeds the `iat` by
            more than 1 hour, the Visa Issuer should expect
            Claim Clearinghouses to use [Access Token Polling](#at-polling) and
            MUST provide a means to revoke Visa Access Tokens. The
            Token or UserInfo Endpoint MUST return an HTTP status 401 as per
            [RFC6750 section 3.1](https://tools.ietf.org/html/rfc6750#section-3.1)
            when provided an Visa Access Token that has completed the
            revocation process.

        2.  The JWS header MUST NOT have `jku` specified.

        3.  Visa Issuer MUST provide protection against
            attacks as outlined in [RFC
            6819](https://tools.ietf.org/html/rfc6819).

    1. <a name="term-visa-document-token"></a> <a name="term-embedded-document-token"></a>
       **Visa Document Token** -- The Visa Issuer does not need to
       be a OIDC provider, and MAY provide tokens of this type without any
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

2.  A Visa Issuer MAY generate the `exp` timestamp to enforce
    its policies and allow Claim Clearinghouses to understand the intent of
    how long the claim may be used before needing to return to the Visa Issuer
    to refresh the claim. As a non-normative example, if a
    GA4GH claim expires in 25 years, the Visa Issuer could set the `exp` to
    1 day into the future plus issue a refresh token in order to force the
    refresh token to be used when a downstream Claim Clearinghouse is still
    interested in using such a claim after 1 day elapses.

3.  By signing a Visa, a Visa Issuer asserts that
    the GA4GH claims made available by the token were legitimately derived
    from their [Claim Sources](#term-claim-source), and the content is
    presented and/or transformed without misrepresenting the original intent,
    except for accommodating for `exp` timestamps to be represented as
    indicated above.

#### Conformance for Passport Issuers

1.  Passport Issuers are used to package Visas into signed Passports.

2.  Passport Issuers do not need to be a be a OIDC provider, and MAY provide a .well-known endpoint that doesn't conform to the OIDC Discovery specification for ease of finding signing keys.

    1. Passport Issuers MAY be AAI Clients, Clearinghouses, Brokers or any other entity and do not need to be part of the OIDC flow.

    2. Passports SHOULD be signed in the same way that Brokers sign access tokens.

3.  Passports themselves are JWTs that contain Visas. Passports use this format [Format](#claims-sent-to-data-holder-by-a-broker-via-token-or-userinfo) as a signed JWT.

    1. It is RECOMMENDED for Passports to conform to the <https://tools.ietf.org/html/rfc7515> (JWS) Specification.

4.  Passports MAY be issued from a Token Endpoint using the [token exchange OAuth extension](https://datatracker.ietf.org/doc/html/rfc8693), modulo the following clarifications:

    1. The Token Endpoint MAY support other OAuth2 grant types.

    2. Client authentication is REQUIRED (using [OAuth2 client authentication](https://datatracker.ietf.org/doc/html/rfc6749#section-2.3.1) is RECOMMENDED).

    3. The `requested_token_type` parameter MUST be present with the value `urn:ietf:params:oauth:token-type:jwt`.

    4. The `subject_token` parameter value MUST be a valid AAI access token issued to the requesting client.

    5. The `subject_token_type` parameter value MUST be `urn:ietf:params:oauth:token-type:access_token`.

    6. The Token Endpoint SHOULD require one or more scopes to be present in the given AAI access token (ex. `"scope": "ga4gh_passport_v1"`).

    7. The Token Endpoint MAY accept or require any other optional parameters defined in [RFC8693](https://datatracker.ietf.org/doc/html/rfc8693).


#### Conformance for Claim Clearinghouses (consuming Passports or Visas to give access to data)

1.  Claim Clearinghouses MUST trust at least one Broker.

    1.  Claim Clearinghouses MAY trust more than one Broker
    
    2.  The responsibility of risk assessment of a Broker is on the Claim Clearinghouse to trust a token. 
    
2.  Claim Clearinghouses MUST process access tokens to access a Broker's Token or UserInfo Endpoint to get access to GA4GH Claims OR MUST process Passports and their Visas. 
           
    1.  For access token flows, Claim Clearinghouses MUST either check the validity of the access token or treat the access
    token as opaque.

        1.  If treating the token as a JWT a Claim Clearinghouse:

            1. Even though JWTs are expected to be submitted against a Broker's Token or UserInfo Endpoint, a Claim Clearinghouse SHOULD check the Token’s signature via JWKS or having stored the
            public key.

                1.  A metadata URL (.well-known URL) SHOULD be used here to use the
                jwks_uri parameter.
                
            2.  MUST check `iss` attribute to ensure a trusted Broker has generated
            the token.
            
                1.  If evaluating Visa, trust MUST be established based
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
        advance where to find a corresponding Token Endpoint. This may limit the
        functionality of accepting tokens from some Brokers. 

    1.  For Passport flows, Claim Clearinghouses MUST check the validity of the JWT token. Follow the guidance in the JWT access tokens for validity.

3.  Claim Clearinghouses service can be a Broker itself and would follow the
    [Conformance For Brokers](#conformance-for-brokers).

4.  Claim Clearinghouses MUST provide protection against attacks as outlined in
    [RFC 6819](https://tools.ietf.org/html/rfc6819).

    1. Section 5.1.6 of RFC 6819 contains a SHOULD section that states `Ensure that client applications do not share tokens with 3rd parties.` This profile provides a mechanism for Clearinghouses to consume access tokens from multiple brokers in a manner that does not involve 3rd parties. Client applications SHOULD take care to not spread the tokens to any other services that would be considered 3rd parties.
        
5.  If making use of [Visas](#term-visa) directly from a Token Endpoint or from a Passport:

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

6.  <a name="at-polling"></a> **Access Token Polling**: Clients MAY use access tokens,
    including Visas, to occasionally check which claims are still valid
    at the associated Token or UserInfo Endpoint in order to establish 
    whether the user still meets the access requirements.

    This MUST NOT be done more than once per hour (excluding any optional retries)
    per Claim Clearinghouse. Any request retries MUST include exponential backoff
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

    5.  If the endpoint returns an updated set of GA4GH Claims (this is
        an OPTIONAL feature of an Visa Issuer), then the Claim
        Clearinghouse MUST use the updated GA4GH Claims and ignore the original
        GA4GH Claim values in the Visa Access Token. If the Claim
        Clearinghouse is unable to adjust for the updated GA4GH Claims, then
        it MUST act as though the token was revoked.

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
    can be used just to help inform if that is what a data controller or data holder
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

-   `addtional claims`: OPTIONAL. Any other additional non-GA4GH claims are allowed. This specification does not dictate the format of other claims.

#### Claims sent to Data Holder by a Broker via Token or UserInfo Endpoint

Only the GA4GH claims truly must be as prescribed here. Refer to OIDC Spec for
more information. The endpoint MAY use `application/json` or
`application/jwt`.  It is RECOMMENDED that if desiring to return a JWT, a Token Endpoint supporting AAI token exchange exists to do that and that the UserInfo Endpoint returns a general blob.

If `application/jwt` is returned, it MUST be signed like UserInfo responses as per
[UserInfo](https://openid.net/specs/openid-connect-core-1_0.html#UserInfoResponse).  

If this is a JWT, it MAY be used as a Passport.  

If this information is a JWT, especially from the recommended Token Endpoint, the JWT should include additional attributes.

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
 <ga4gh-spec-claims>
}
```

-   `iss` and `sub`: REQUIRED.

-   `aud`: OPTIONAL.

-   `iat`: REQUIRED only if JWT Otherwise OPTIONAL. Time issued.

-   `exp`: REQUIRED only if JWT Otherwise OPTIONAL. Time expired.

-   `<ga4gh-spec-claims>`: OPTIONAL. GA4GH Claims are generally included as
    part of one or more GA4GH standard specifications based on the scopes
    provided. Even when requested by the appropriate scopes, these GA4GH Claims
    may not be included in the response for various reasons, such as if the
    user does not have any GA4GH Claims. See
    [Authorization/Claims](#authorizationclaims) for an example of a GA4GH
    Claim.

<a name="visa-issued-by-visa-issuer"></a>
#### Visa issued by Visa Issuer

There are two supported formats for Visas.

<a name="embedded-access-token-format"></a>
##### Visa Access Token Format

Header format:

```
{
 "typ": "JWT",
 "alg": "<algorithm>",
 "kid": "<key-identifier>"
}
```

where:

1.  `alg` MUST be "RS256" or "ES256"

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
     "alg": "<algorithm>",
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

    -   `alg`: MUST be "RS256" or "ES256"

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

Token Revocation
----------------

#### Claim Source Revokes Claim

Given that claims can cause downstream access tokens to be minted by Claim
Clearinghouses and such downstream access tokens may have little knowledge or no
connectivity to sources of claims, it can be challenging to build robust
revocation capabilities across highly federated and loosely coupled systems.
During the lifetime of the downstream access token, some systems may require
that claims are no longer inspected nor updated.

In the event that a [Claim Source](#term-claim-source) revokes a claim,
downstream Visa Issuers, Brokers, Claim Clearinghouses, and other Authorization or Resource
Servers MUST at a minimum provide a means to limit the lifespan of any given
access tokens generated as a result of claims. To achieve this goal, servers
involved with access may employ one or more of the following options:

1. Have each GA4GH Claim or sub-object be paired with an expiry timestamp.
    Expiry timestamps would require users to log in occasionally via
    a Broker in order to refresh claims. On a refresh, expiry timestamps can
    be extended from what the previous claim may have indicated.

2.  Provide GA4GH Claims in the form of [Visa Access
    Tokens](#term-visa-access-token) to allow downstream Claim
    Clearinghouses to periodically check the validity of the token via calls
    to the Token Endpoint as per [Access Token Polling](#at-polling).

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

4. Provide some other means for downstream Claim Clearinghouses or other
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
        revocable, and once revoked the Token Endpoint MUST NOT return
        claims. In this event, an appropriate error status MUST be returned like UserInfo errors as per
        [section 5.3.3 of the OIDC specification](https://openid.net/specs/openid-connect-core-1_0.html#UserInfoError).

    -   [Access Token Polling](#at-polling) can allow downstream systems to detect
        token revocation and remove access accordingly.

2.  A process MUST exist, manual or automated, to eventually remove or invalidate
    related claims at source and intermediate systems.

#### Limited Damage of Leaked Tokens

In order to limit damage of leaked tokens, systems MUST provide all of the
following:

1.  Be able to leverage mechanisms in place for revoking claims and tokens
    for other purposes to also limit exposure of leaked tokens.

2.  Follow best practices for the safekeeping of refresh tokens or longer lived
    tokens (should longer lived tokens be needed).

3.  Limit the life of refresh tokens or long-lived keys before an auth challenge
    occurs or otherwise the refresh token simply fails to generate more access
    tokens.

4.  Any signed tokens that may be stored by participating services SHOULD be
    encrypted at rest and follow best practices to limit the ability of
    administrators from decrypting this content.

### Appendix - Sequence Diagrams

The following sequence diagrams are included to help explain the intended flows
documented in this specification. These diagrams should be considered non-normative - if there are
any discrepancies between the diagrams and the text of the specification, the text
of the specification will take precedence.

#### Callback (Userinfo) Flow

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

#### Exchange Flow

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


### Specification Revision History

| Version | Date    | Editor                                     | Notes                   |
|---------|---------|--------------------------------------------|-------------------------|
| 1.2.0   | 2021-07 | Craig Voisin ...                           | ...  |
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
