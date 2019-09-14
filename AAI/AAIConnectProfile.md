---
## GA4GH Authentication and Authorization Infrastructure (AAI) OpenID Connect Profile (DRAFT RFC)
---

| Version | Date    | Editor                                     | Notes                   |
|---------|---------|--------------------------------------------|-------------------------|
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
       - [Conformance for Embedded Token Signatories](#conformance-for-embedded-token-signatories)\
       - [Conformance for Claim Clearinghouses (consuming Access Tokens to give access to data)](#conformance-for-claim-clearinghouses-consuming-access-tokens-to-give-access-to-data)
- [**GA4GH JWT Format**](#ga4gh-jwt-format)\
       - [Access_token issued by broker](#access_token-issued-by-broker)\
       - [Claims sent to Data Holder by a Broker via /userinfo](#claims-sent-to-data-holder-by-a-broker-via-userinfo)\
       - [Embedded Token issued by Embedded Token Signatory](#embedded-token-issued-by-embedded-token-signatory)\
            - [Embedded Access Token Format](#embedded-access-token-format)\
            - [Embedded Document Token Format](#embedded-document-token-format)\
       - [Authorization/Claims](#authorizationclaims)
- [**Token Revocation**](#token-revocation)\
       - [Claim Source Revokes Claim](#claim-source-revokes-claim)\
       - [Revoking Access from Bad Actors](#revoking-access-from-bad-actors)\
       - [Limited Damage of Leaked Tokens](#limited-damage-of-leaked-tokens)

### Requirements Notation and Conventions

This specification inherits terminology from the [OpenID
Connect](http://openid.net/specs/openid-connect-core-1_0.html) and the [OAuth
2.0 Framework (RFC 6749)](https://tools.ietf.org/html/rfc6749) specifications.

The key words "MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL NOT", "SHOULD",
"SHOULD NOT", "RECOMMENDED", "MAY", and "OPTIONAL" in this specification are to
be interpreted as described in [RFC2119](https://www.ietf.org/rfc/rfc2119.txt).

### Terminology

<a name="term-ga4gh-claim></a> **GA4GH Claim** -- A JWT claim as defined by a GA4GH
documented technical standard that is making use of this AAI specification. Note
that GA4GH is not the organization making the claim nor taking responsibility for
the claim as this is a reference to a GA4GH documented standard only.

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
instance, a Data Access Committee. A Data owner is likely to be a Claim
Source.

<a name="term-embedded-token-signatory"></a> **Embedded Token Signatory** --
a service that signs [Embedded Tokens](#term-embedded-token). This service
may be a [Broker](#term-broker) itself, or it may have a Broker use this
service as part of collecting GA4GH Claims that the Broker includes in
responses from its /userinfo endpoint.

<a name="term-embedded-token"></a> **Embedded Token** -- A GA4GH Claim value
or entry within a list or object of a GA4GH Claim that contains a JWS string.
It MUST be signed by an [Embedded Token Signatory](#term-embedded-token-signatory).
An Embedded Token can pass GA4GH Claims through various Brokers as needed
while retaining the token signature of the original Embedded Token Signatory.

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

### Flow of Claims 

![FlowOfClaims](https://github.com/ga4gh/data-security/blob/master/AAI/aai%20flow%20of%20claims.png) 

Note: the above diagram shows how claims flow from a
[Claim Source](#term-claim-source) to a
[Claim Clearinghouse](#term-claim-clearinghouse) that uses them. This
does not label all of the Relying Party relationships along this chain,
where each recipient in the chain is typically -- but not always -- the
relying party of the auth flow that fetches the claims from upstream.

### Profile Requirements 

#### Client/Application Conformance 

1.  Confidential clients (keep the client secret secure - typically
    server-side web-applications) MUST implement OIDC Authorization Code
    Flow (with Confidential Client)
    <http://openid.net/specs/openid-connect-basic-1_0.html>

2.  Public Clients (typically javascript browser clients or mobile apps)
    SHOULD implement OIDC Implicit Flow
    (<http://openid.net/specs/openid-connect-implicit-1_0.html>)

    1.  MUST use "id_token token" response_type for authentication.

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

    1.  A Broker MUST issue both id_tokens and access_tokens.

        1.  This document makes no specifications for id_tokens.

    2.  Access_tokens MUST be in JWS format  

        1.  Access tokens for GA4GH use MUST be in [this format](#ga4gh-jwt-format).

        2.  Access tokens do not contain GA4GH Claims directly in the access token.

2.  Broker MUST support [OIDC Discovery
    spec](https://openid.net/specs/openid-connect-discovery-1_0.html)

    1.  MUST include and support proper
        [Metadata](https://openid.net/specs/openid-connect-discovery-1_0.html#ProviderMetadata)
        (i.e. must have a `jwks_uri` as required that’s reachable by a Claim
        Clearinghouse)

3.  Broker MUST support public-facing /userinfo endpoint

    1.  When presented with a valid access token, the /userinfo endpoint MUST return
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
    Embedded Tokens -- were legitimately derived from their [Claim
    Sources](#term-claim-source), and the content is presented and/or
    transformed without misrepresenting the original intent.
    
    When a Broker acts as a Embedded Token Signatory and signs Embedded
    Tokens, then those signatures adhere to the same assertion criteria as
    outlined in the [Conformance for Embedded Token
    Signatories](#conformance-for-embedded-token-signatories)
    section of this specification.

    When a Broker provides Embeded Tokens from other Embedded Token
    Signatories, it is providing them "as is" (i.e. it provides no additional
    assurance as to the quality, authenticity, or trustworthiness of the
    claims from such tokens and any such assurances are made by the issuer of
    the Embedded Token, i.e. the Embedded Claim Signatory).

#### Conformance for Embedded Token Signatories

1.  An [Embedded Claim Signatory](#term-embedded-claim-signatory) MUST
    provide one or more of the following types of [Embedded
    Tokens](#term-embedded-token):

    1.  <a href="term-embedded-access-token"></a> **Embedded Access Token**
        -- The Embedded Claim Signatory is providing an OIDC provider service
        and issues OIDC-compliant access tokens in a specific format that can
        be used as an Embedded Token.
    
        1.  The Embedded Token body MUST contain the "openid" scope. That is,
            it has a `scope` JWT claim that contains "openid" as a
            space-delimited substring.
            
        2.  Embedded Token is a JWS string and follows the [Embedded Access
            Token Format](#embedded-access-token-format). This includes
            having GA4GH Claims as JWT claims directly in the Embedded Token.
            
        3.  Embedded Token Signatory MUST support [OIDC Discovery
            spec](https://openid.net/specs/openid-connect-discovery-1_0.html),
            and provide `jwks_uri` as
            [Metadata](https://openid.net/specs/openid-connect-discovery-1_0.html#ProviderMetadata)
            that is reachable by a Claim Clearinghouse.
        
        4.  Embedded Token Signatory MUST support public-facing
            /userinfo endpoint. When presented with a valid Embedded Access
            Token, the /userinfo endpoint MUST return a success status
            and MAY return the current values for GA4GH Claims that were
            included within the Embedded Access Token, however returning
            GA4GH Claims from the /userinfo endpoint for Embedded Access
            Tokens is OPTIONAL.
            
        5.  If the Embedded Access Token's `exp` exceeds the `iat` by
            more than 1 hour, the Embedded Token Signatory should expect
            Claim Clearinghouses to use [Claim Polling](#claim-polling) and
            MUST provide a means to revoke Embedded Access Tokens. The
            /userinfo endpoint MUST return an HTTP status 401 as per
            [RFC6750 section 3.1](https://tools.ietf.org/html/rfc6750#section-3.1)
            when provided an Embedded Access Token that has completed the
            revocation process.

        6.  The JWS header MUST NOT have `jku` specified.

        7.  Embedded Token Signatory MUST provide protection against
            attacks as outlined in [RFC
            6819](https://tools.ietf.org/html/rfc6819).
        
    2.  <a href="term-embedded-document-token"></a> **Embedded Document
        Token** -- The Embedded Claim Signatory does not need to be a
        be a OIDC provider, and MAY provide tokens of this type without any
        revocation process.
        
        1.  The JWS header contains `jku` as specified by [RFC7515 Section
            4.1.2](https://tools.ietf.org/html/rfc7515#section-4.1.2), and
            provides the corresponding public-facing endpoint to fetch
            the public key used to sign the Embedded Document Token.
            
        2.  Follows the [Embedded Document Token
            Format](#embedded-document-token-format).

        3.  The token is not treated as an access token, but validity
            checks outlined elsewhere in this specification still apply.

        4.  MUST conform to [token limited-life or revocation
            requirements](#token-revocation), even if no Embedded Token
            revocation process is provided.

        5.  The `scope` JWT claim, if included, MUST NOT contain "openid" as
            a space-delimited substring.
    
2.  An Embedded Token Signatory MAY generate the `exp` timestamp to enforce
    its policies and allow Claim Clearinghouses to understand the intent of
    how long the claim may be used before needing to return to the Embedded
    Token Signatory to refesh the claim. As a non-normative example, if a
    GA4GH claim expires in 25 years (or even never expires explictly in the
    Claim Repository), the Embedded Token Signatory could set the `exp` to
    14 days into the future in order to force a user authentication flow to
    be redone if a downstream Claim Clearinghouse is still interested in using
    such a claim after this period elapses.

3.  By signing an Embedded Token, an Embedded Token Signatory asserts that
    the GA4GH claims made available by the token were legitimately derived
    from their [Claim Sources](#term-claim-source), and the content is
    presented and/or transformed without misrepresenting the original intent,
    except for accommodating for `exp` timestamps to be represented as
    indicated above.

#### Conformance for Claim Clearinghouses (consuming Access Tokens to give access to data)

1.  Claim Clearinghouses MUST trust at least one Broker.

    1.  Claim Clearinghouses MAY trust more than one Broker

2.  Claim Clearinghouses MUST either check the validity of the JWT or treat the
    token as opaque.

    1.  If treating the token as a JWT a Claim Clearinghouse:

        1.  MUST check the Token’s signature via JWKS or having stored the
            public key.

            1.  A metadata URL (.well-known URL) SHOULD be used here to use the
                jwks_uri parameter.
                
            2.  This includes checking the signature of Embedded Tokens that
                the Claim Clearinghouse may wish to use.

        2.  MUST check `iss` attribute to ensure a trusted Broker has generated
            the token.
            
            1.  If evaluating an Embedded Token, trust MUST be established based
                on the signer of the Embedded Token itself. In Claim
                Clearinghouses participating in open federation, the Claim
                Clearinghouse does not necessarily have to trust the Broker that
                includes Embedded Tokens within another token in order to use
                the Embedded Token (although the Claim Clearinghouse MAY require
                any other Broker involved in the propagation of the claims to
                also be trusted if the Claim Clearinghouse needs to restrict its
                trust model).

        3.  MUST check `exp` to ensure the token has not expired.

        4.  MAY additionally check `aud` to make sure Relying Party is trusted
            (client_id).

    2.  If treating the token as an opaque a Claim Clearinghouse MUST know in
        advance where to find a corresponding /userinfo. This may limit the
        functionality of accepting tokens from some Brokers.

3.  Claim Clearinghouse or downstream applications MAY use /userinfo endpoint
    (derived from the access_token JWT’s `iss`) to request claims and MAY make
    use of the [OIDC claims request
    parameter](https://openid.net/specs/openid-connect-core-1_0.html#ClaimsParameter)
    to subset which claims are requested if supported by the Broker for the
    claims in question.

4.  Claim Clearinghouses service can be a Broker itself and would follow the
    [Conformance For Brokers](#conformance-for-brokers).

5.  Claim Clearinghouses MUST provide protection against attacks as outlined in
    [RFC 6819](https://tools.ietf.org/html/rfc6819).
    
6.  If making use of [Embedded Tokens](#term-embedded-token):

    1.  The Claim Clearinghouse MUST validate that all token checks pass (such as
        the token hasn’t expired) as described elsewhere in this specification and
        the underlying OIDC specifications.

    2.  If making use of [Embedded Access Tokens](#term-embedded-access-token):
    
        1. Token checks MUST be performed to ensure it complies with the access
           token specification.
    
        2. In addition to other validation checks, an Embedded Token is considered
           invalid if it is more than 1 hour old (as per the `iat` claim) AND
           [Claim Polling](#claim-polling) does not confirm that the token is still
           valid (e.g. provide a success status code).
                      
    3.  If making use of [Embedded Document Tokens](#term-embedded-document-token):

        1.  Fetching the public keys using the `jku` is not required if a Claim
            Clearinghouse has received the keys for the given `iss` via a trusted,
            out-of-band process.

        2.  If a Claim Clearinghouse is to use the `jku` URL to fetch the public
            keys to verify the signature, then it MUST verify that the `jku` is
            trusted for the given `iss` as part of the Claim Clearinghouse's
            trusted issuer configuration. This check MUST be performed before
            calling the `jku` endpoint.

7.  <a name="claim-polling"></a> **Claim Polling**: Clients MAY use access tokens,
    including Embedded Tokens, to occasionally check which claims are still valid
    at the associated /userinfo endpoint in order to establish whether the user
    still meets the access requirements.
    
    This MUST NOT be done more than once per hour (excluding any optional retries)
    per Claim Clearinghouse. Any request retries MUST include exponential backoff
    delays based on best practices (e.g. include appropriate jitter). At a
    minimum, the client MUST stop checking once any of the following occurs:

    1.  The system can reasonably determine that authorization related to these
        claims is not longer needed by the user. For example, all downstream cloud
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
        an OPTIONAL feature of an Embedded Token Signatory), then the Claim
        Clearinghouse MUST use the updated GA4GH Claims and ignore the original
        GA4GH Claim values in the Embedded Access Token. If the Claim
        Clearinghouse is unable to adjust for the the updated GA4GH Claims, then
        it MUST act as though the the token was revoked.

### GA4GH JWT Format

A well-formed JWS-Encoded JSON Web Token (JWT) consists of three concatenated
Base64url-encoded strings, separated by dots (.) The three sections are: header,
payload and signature. The access token and JWT with full claims use the same
format, though the JWT with the full claims will have extended claims. These
JWTs follow <https://tools.ietf.org/html/rfc7515> (JWS).

This profile is agnostic to the format of the id_token.

#### Access_token issued by Broker

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
 "scope": "openid <ga4gh-spec-scopes>"
}
```
-   `iss`: REQUIRED. MUST be able to be appended with
    .well-known/openid-configuration to get spec of Broker.

-   `sub`: REQUIRED. Authenticated user unique identifier.

-   `idp`: OPTIONAL. SHOULD contain the IDP the user used to auth with.
    A non-normative example is "google". This does not have to be unique and
    can be used just to help inform if that is what a data owner or data holder
    needs.

-   `aud`: REQUIRED. MUST contain the Oauth Client ID of the relying party.

-   `iat`: REQUIRED. Time issued.

-   `exp`: REQUIRED. Time expired.

-   `jti`: RECOMMENDED. a unique identifier for the token as per
    [RFC7519 Section 4.1.7](https://tools.ietf.org/html/rfc7519#section-4.1.7)

-   `scope`: REQUIRED. Includes verified scopes. MUST include "openid". Will also
    include any `<ga4gh-spec-scopes>` needed for the GA4GH compliant environment
    (e.g. "ga4gh" is the [scope for RI
    claims](https://github.com/ga4gh-duri/ga4gh-duri.github.io/blob/master/researcher_ids/RI_Claims_V1.md#requirement-7)).

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
 <ga4gh-spec-claims>
}
```

-   `iss` and `sub`: REQUIRED.

-   `aud`: OPTIONAL.

-   `<ga4gh-spec-claims>`: OPTIONAL. GA4GH Claims are generally included as
    part of one or more GA4GH standard specifications based on the scopes
    provided. Even when requested by the appropriate scopes, these GA4GH Claims
    may not be included in the response for various reasons, such as if the
    user does not have any GA4GH Claims. See
    [Authorization/Claims](#authorizationclaims) for an example of a GA4GH
    Claim.

#### Embedded Token issued by Embedded Token Signatory

There are two supported formats for Embedded Tokens.

##### Embedded Access Token Format

Follows the [Broker access token](#access-token-issued-by-broker) format
with the following caveats:
     
1.  MUST NOT contain a `jku` in the header.

2.  The body MUST NOT include `aud`.

3.  The body MUST contain at least one GA4GH Claim.

##### Embedded Document Token Format

Conforms with JWS format requirements and is signed by an Embedded Claim
Signatory.

1. MUST be a JWS string.

2. MUST contain a `jku` in the header.

3. MUST NOT contain "openid" as a space-delimited substring of the `scope`
   JWT claim, if the `scope` claim is provided.
   
4. The following headers and JWT claims in the body are REQUIRED (here
   shown in its decoded form):

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
     <ga4gh-spec-claims>
   }.
   <signature>
   ```

   -   `typ`: MUST be "JWT".

   -   `alg`: MUST be "RS256".
     
   -   `jti`: RECOMMENDED. A unique identifier for the token as per
       [RFC7519 Section 4.1.7](https://tools.ietf.org/html/rfc7519#section-4.1.7)
       is RECOMMENDED.
     
   -   `<ga4gh-spec-claims>`: REQUIRED. One or more GA4GH Claims MUST be
       provided. See [Authorization/Claims](#authorizationclaims) for an
       example.

#### Authorization/Claims 

User attributes and claims are being developed in [GA4GH Researcher Identity
Claims](https://github.com/ga4gh-duri/ga4gh-duri.github.io/blob/master/researcher_ids/RI_Claims_V1.md)
document by the DURI work stream.

A non-normative example of a GA4GH Researcher Identity Claim, as referred to
in as `<ga4gh-spec-claims>` within the JWT formatting sections of this
specification, is:

```
"ga4gh": {
  <[ga4gh RI claims value](https://github.com/ga4gh-duri/ga4gh-duri.github.io/blob/master/researcher_ids/RI_Claims_V1.md)>
}
```

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
a [Claim Repository](#term-claim-repository), downstream Embedded Token
Signatories, Brokers, Claim Clearinghouses, and other Authorization or Resource
Servers MUST at a minimum provide a means to limit the lifespan of any given
access tokens generated as a result of claims. To achieve this goal, servers
involved with access may employ one or more of the following options:

1.  Have each GA4GH Claim or sub-object be paired with an expiry timestamp.
    Expiry timestamps would require users to log in occasionally via
    an Broker in order to refresh claims. On a refresh, expiry timestamps can
    be extended from what the previous claim may have indicated.
    
2.  Provide GA4GH Claims in the form of [Embedded Access
    Tokens](#term-embedded-access-token) to allow downstream Claim
    Clearinghouses to periodically check the validity of the token via calls
    to the /userinfo endpoint as per [Claim Polling](#claim-polling).

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
        
    -   [Claim Polling](#claim-polling) can allow downstream systems to detect
        token revocation and remove access accordingly.

2.  A process MUST exist, manual or automated, to eventually remove or invalidate
    related claims from the [Claim Respository](#term-claim-respository).

#### Limited Damage of Leaked Tokens

In order to limit damage of leaked tokens, systems MUST provide all of the
following:

1.  Be able to leverage mechanisms in place for revoking claims and tokens for
    for other purposes to also limit exposure of leaked tokens.

2.  Follow best practices for the safekeeping of refresh tokens or longer lived
    tokens (should longer lived tokens be needed).

3.  Limit the life of refresh tokens or long lived keys before an auth challenge
    occurs or otherwise the refresh token simply fails to generate more access
    tokens.

4.  Any signed tokens that may be stored by participating services MUST be
    encrypted at rest and follow best practices to limit the ability of
    administrators from decrypting this content.
