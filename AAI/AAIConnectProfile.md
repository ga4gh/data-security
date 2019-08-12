---
## GA4GH Authentication and Authorization Infrastructure (AAI) OpenID Connect Profile (DRAFT RFC)
---

| Version | Date   | Editor                                     | Notes                   |
|---------|--------|--------------------------------------------|-------------------------|
| 0.9.3   | 2019-08| Craig Voisin                               | Support for RI's embedded tokens |
| 0.9.2   | 2019-07| David Bernick                              | Made changes based on feedback from review |
| 0.9.1   | 2019-06| Craig Voisin                               | Added terminology links |
| 0.9.0   | 2017-  | Mikael Linden, Craig Voisin, David Bernick | Initial working version |

### Abstract

This specification profiles the OpenID Connect protocol to provide a federated
(multilateral) authentication and authorisation infrastructure for greater
interoperability between Genomics institutions in a manner specifically
applicable to (but not limited to) the sharing of restricted datasets.

In particular, this specification introduces a JSON Web Token
([JWT] (#relevant-specifications)) syntax for an access token to
enable an OIDC provider (called an OIDC broker) to embed some key claims to the
access token and to enable a downstream access token consumer (called a Claims
Clearinghouse) to locate the OIDC broker’s userinfo endpoint for requesting the
rest of the claims. This specification is suggested to be used together with
others that specify the syntax and semantics of the claims exchanged.

### Table of Contents

- [Abstract](#abstract)
- [Introduction](#introduction)
- [Requirements Notation and Conventions](#requirements-notation-and-conventions)
- [Terminology](#terminology)
- [Relevant Specifications](#relevant-specifications)
- [Flow of Claims](#flow-of-claims)
- [Profile Requirements](#profile-requirements)
       - [Client/Application Conformance (user-Agent/Relying Party)](#clientapplication-conformance-user-agentrelying-party)
       - [Conformance for Brokers](#conformance-for-brokers)\
       - [Conformance for Claim Clearinghouses (consuming Access Tokens to give access to data)](#conformance-for-claim-clearinghouses-consuming-access-tokens-to-give-access-to-data)
- [GA4GH JWT Format](#ga4gh-jwt-format)
       - [Access_token issued by broker](#access_token-issued-by-broker)\
       - [Claims sent to Data Holder by a Broker via /userinfo](#claims-sent-to-data-holder-by-a-broker-via-userinfo)\
       - [Authorization/Claims](#authorizationclaims)
- [**Token Revocation**](#token-revocation)
       - [Claim Authority Revokes Claim](#claim-authority-revokes-claim)\
       - [Revoking Access from Bad Actors](#revoking-access-from-bad-actors)\
       - [Limited Damage of Leaked Tokens](#limited-damage-of-leaked-tokens)
- [**Appendix**](#appendix)
       - [Examples of broker technologies](#examples-of-broker-technologies)\
       - [Why Brokers?](#why-brokers)\
       - [Services parties are responsible for providing](#services-parties-are-responsible-for-providing)\
       - [Future topics to explore](#future-topics-to-explore)


### Introduction

This document profiles using OpenID Connect (OIDC) Servers for use in
authenticating the identity of researchers desiring to access clinical and
genomic resources from [data holders](#wcqdpvy24ywr) adhering to GA4GH
standards, and to enable data holders to obtain security-related attributes of
those researchers. This is intended to be endorsed as a GA4GH standard,
implemented by GA4GH Driver Projects, and shared broadly.

To help assure the authenticity of identities used to access data from GA4GH
Driver Projects, and other projects that adopt GA4GH standards, the Data Use and
Researcher Identity (DURI) Work Stream is in the process of developing a
standard of "claims". This standard assumes that some claims provided by brokers
described in this document will conform to the DURI researcher-identity policy
and standard. This standard does NOT assume that GA4GH Claims will be the only
ones used.

In this standard, we aim at developing an approach that enables data holders’
systems to recognize and accept identities from multiple brokers -- allowing for
a federated approach. An organization can still use this spec and not support
multiple brokers, though they will find in that case that it’s just using a
proscriptive version of OIDC.

### Requirements Notation and Conventions 

This specification inherits terminology from the [OpenID
Connect](http://openid.net/specs/openid-connect-core-1_0.html) and the [OAuth
2.0 Framework (RFC 6749)](https://tools.ietf.org/html/rfc6749) specifications.

The key words "MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL NOT", "SHOULD",
"SHOULD NOT", "RECOMMENDED", "MAY", and "OPTIONAL" in this specification are to
be interpreted as described in [RFC2119](https://www.ietf.org/rfc/rfc2119.txt).

### Terminology

<a name="term-claim-source"></a> **Claim source** service -- a service that
manages claims and delivers them to OIDC identity brokers. For instance, a data
owner.

<a name="term-claim-authority"></a> **Claim Authority** - the source
organization of a claim assertion which at a minimum includes the organization
associated with asserting the claim, although can optionally identify a
sub-organization or a specific assignment within the organization that made the
claim.

-   This is NOT necessarily the organization that stores the claim, nor the
    [Identity Broker](#term-identity-broker)’s organization that signs the
    token; it is the organization that has the authority to assert the claim
    on behalf of the user and is responsible for making and maintaining the
    assertion.

<a name="term-identity-provider"></a> **Identity provider (IdP)** service - a
service that provides to users an identity, authenticates it; and provides
claims to a broker using standard protocols, such as OpenID Connect, SAML or
other federation protocols. Example: eduGAIN, Google Identity, Facebook, NIH
ERACommons. IdPs MAY be claims sources.

<a name="term-identity-broker"></a> **OIDC Identity Broker** service (aka
"identity broker", sometimes called an "IdP proxy") - An OIDC Provider service
that authenticates a user (potentially by an Identity Provider), collects their
claims from internal and/or upstream claim sources and issues conformant OIDC
claims to be consumed by [Claim Clearinghouses](#jyzwlgoay5dq). Brokers may
also be Claim Clearinghouses of other upstream Brokers (i.e. create a chain of
brokers like in the [Flow of Claims diagram](#flow-of-claims)).

<a name="term-root-claim-broker"></a>  **Root Claim Broker** - The original
[Identity Broker](#term-identity-broker) that encodes a claim directly from a
Claim Authority or directly from a data store that contains a Claim Authority’s
assertion is the Root Claim Broker for that claim or claim object.

-   For example, an Identity Broker that reads assertions from a SQL database
    and presents them as a claim in a token is the Root Claim Broker for such
    a claim whereas an Identity Broker that receives a claim from an upstream
    Identity Broker and propagates it within a newly minted token is not the
    Root Claim Broker.

<a name="term-claim-clearinghouse"></a> **OIDC Claim Clearinghouse service**
(aka "Claim Clearinghouse" aka "claim consumer") - A consumer of Identity
Broker claims (an OIDC Relying Party or a service downstream) that makes an
authorization decision at least in part based on inspecting GA4GH claims and
allows access to a specific set of underlying resources in the target
environment or platform. This abstraction allows for a variety of models for
how systems consume these claims in order to provide access to resources.
Access can be granted by either issuing new access tokens for downstream
services (i.e. the Claim Clearinghouse may act like an authorization server)
or by providing access to the underlying resources directly (i.e. the Claim
Clearinghouse may act like a resource server). Some Claim Clearinghouses may
issue access tokens that may contain a new set of GA4GH claims and/or a
subset of GA4GH claims that they received for downstream consumption.

<a name="term-data-holder"></a> **Data Holder** - An organization that
protects a specific set of data. They hold data (or its copy) and respects
and enforces the data owner's decisions on who can access it. A data owner
can also be a data holder. Data holders run an
[OIDC Claim Clearinghouse Server](#jyzwlgoay5dq) at a minimum.

<a name="term-data-owner"></a> **Data Owner** - An organization that manages
data and, in that role, has capacity to decide who can access it. For
instance, a Data Access Committee. A Data owner is likely to be a claim
source.

<a name="term-embedded-token"></a> **Embedded Token** - A claim value or
entry within a list or object of a claim that contains a JWT string that
itself also meeting the requirements indicated in this specification and is
signed by an upstream Identity Broker. This token MAY provide GA4GH claims
within the token or available at the /userinfo endpoint. In this way, an
Embedded Token can pass along GA4GH claims as needed while retaining the token
signing authority of a Root Claim Broker despite being repackaged in downstream
tokens.

### Relevant Specifications

[OIDC Spec](http://openid.net/specs/openid-connect-core-1_0.html) -
Authorization Code Flow and Implicit Flow will generate id_tokens and
access_tokens from the OIDC Broker.

[JWT](https://tools.ietf.org/html/rfc7519) - The access_token is in JSON Web
Token (JWT) format. Specific implementations MAY extend this structure with
their own service-specific response names as top-level members of this JSON
object. Recommended "extensions" are in the [Permissions](#authorizationclaims)
section. The JWT specified here follows JWS headers specification.
<https://tools.ietf.org/html/rfc7515>

[JWS](https://tools.ietf.org/html/rfc7515) - JSON Web Signature (JWS) is the
specific JWT to use for this spec.

[Transport Layer Security (TLS, RFC 5246](https://tools.ietf.org/html/rfc5246)).
Information passed among clients, Applications, Brokers, and Claim
Clearinghouses MUST be protected using TLS.

[OIDC Discovery](https://openid.net/specs/openid-connect-discovery-1_0.html)

[OAuth 2.0 Threat Model and Security Considerations (RFC 6819)](https://tools.ietf.org/html/rfc6819).

### Flow of Claims 

![FlowOfClaims](https://github.com/ga4gh/data-security/blob/master/AAI/aai%20flow%20of%20claims.png) 

Note: the above diagram shows how claims flow from a Claim Source (e.g. database) to a Claim Clearinghouse that uses them. This does not label all of the Relying Party relationships along this chain, where each recipient in the chain is typically -- but not always -- the relying party of the auth flow that fetches the claims from upstream.

### Profile Requirements 

#### Client/Application Conformance 

1.  Confidential clients (keep the client secret secure - typically server-side web-applications) MUST implement OIDC Authorization Code Flow (with
    Confidential Client) <http://openid.net/specs/openid-connect-basic-1_0.html>

2.  Public Clients (typically javascript browser clients or mobile apps) MAY implement OIDC Implicit Flow
    (<http://openid.net/specs/openid-connect-implicit-1_0.html>)

    1.  MUST use "id_token token" response_type for authentication.

3.  Conform to [revocation requirements](#token-revocation).

4.  Protection of Confidential Information

    1.  Sensitive information (e.g., including client secrets, authorization
        codes, id_tokens, access_tokens) will be passed over encrypted channels as per [OpenIDC Implementation Guide](https://openid.net/specs/openid-connect-basic-1_0.html).

    2.  All responses that contain tokens, secrets, or other sensitive
        information MUST include the following HTTP response header fields and
        values (as per [OpenIDC Implementation Guide](https://openid.net/specs/openid-connect-basic-1_0.html)). 

        1.  Cache-Control: no-store

        2.  Pragma: no-cache
        
5.  MUST provide protection againt Client attacks as outlined in [RFC 6819](https://tools.ietf.org/html/rfc6819).

#### Conformance for Brokers 

1.  Identity Brokers operate downstream from IdPs or provide their own IdP
    service. They issue id_tokens and access_tokens (and potentially refresh
    tokens) for consumption within the GA4GH compliant environment.

    1.  A broker MUST issue both id_tokens and access_tokens.

        1.  This document makes no specifications for id_tokens.

    2.  Access_tokens MUST be in JWS format  

        1.  Access tokens for GA4GH use MUST be in [this
            format](#ga4gh-jwt-format).

        2.  MAY have a limited set of claims with a larger list of claims
            accessed in /userinfo

        3.  Broker MUST include a "ga4gh_userinfo_claims" claim as an array of
            string claim names that can be retrieved via /userinfo in the
            [GA4GH-specified format](#ga4gh-jwt-format), or include the empty
            list if there are no further claims.
            
            1.  The Identity Broker MAY return a subset of claims indicated by
                "ga4gh_userinfo_claims". If a claim is an array or an object,
                the Identity Broker MAY return a subset of elements or fields.

            2.  For example, the user may not agree to release some claims or some
                items within a list, or the token may have expired, or the broker
                may wish to filter tokens if it is enforcing a particular trust
                model.

            3.  Therefore the response from /userinfo may not have a
                "ga4gh_passports" claim even if the Passport’s
                "ga4gh_userinfo_claims" strings hinted that such a claim may have
                content.

2.  Broker MUST support [OIDC Discovery
    spec](https://openid.net/specs/openid-connect-discovery-1_0.html)

    1.  MUST include and support proper
        [Metadata](https://openid.net/specs/openid-connect-discovery-1_0.html#ProviderMetadata)
        (ie must have a jwks_uri as required that’s reachable by a Claim
        Clearinghouse)

3.  Broker MUST support public-facing /userinfo endpoint

    1.  When presented with a valid access token, the /userinfo endpoint MUST return claims in the specified [User Info Format](#claims-sent-to-data-holder-by-a-broker-via-userinfo) using either an `application/json` or `application/jwt` encoding.

    2.  The Broker MUST include the claims_parameter_supported in the discovery service to indicate whether or not the Broker
        supports the [OIDC claims request
        parameter](https://openid.net/specs/openid-connect-core-1_0.html#ClaimsParameter)
        on /userinfo to subset which claim information will be returned. If the Broker does not support the OIDC claims request parameter, then all claims for the provided scopes eligible for release to the requestor MUST be returned.
        
4.  Broker MUST provide protection againt attacks as outlined in [RFC 6819](https://tools.ietf.org/html/rfc6819).

5.  The user represented by the identity of the access token MUST have agreed to
    release claims related to the requested scopes as part of generating tokens
    that can expose GA4GH claims that represent user data or permissions.
    Identity Brokers MUST adhere to
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

#### Conformance for Claim Clearinghouses (consuming Access Tokens to give access to data)

1.  Claim Clearinghouses MUST trust at least one OIDC Identity Broker.

    1.  Claim Clearinghouses MAY trust more than one Broker

2.  Claim Clearinghouses MUST either check the validity of the JWT or treat the
    token as opaque.

    1.  If treating the token as a JWT a Claim Clearinghouse MUST

        1.  Check the Token’s signature via JWKS or having stored the public key

            1.  A metadata URL (.well-known URL) SHOULD be used here to use the
                jwks_uri parameter.

        2.  Check iss attribute to ensure a trusted broker has generated the
            token

        3.  Check exp to ensure the token has not expired

        4.  MAY additionally check aud to make sure Relying Party is trusted
            (client_id).

    2.  If treating the token as an opaque a Claim Clearinghouse MUST know in
        advance where to find a corresponding /userinfo. This limits the
        functionality of accepting tokens from multiple OIDC brokers.

3.  Claim Clearinghouse or downstream applications MAY use /userinfo endpoint (derived
    from the access_token JWT’s *iss*) to request claims and MAY make use
    of the [OIDC claims request
    parameter](https://openid.net/specs/openid-connect-core-1_0.html#ClaimsParameter)
    to subset which claims are requested if supported by the Identity Broker for the
    claims in question.

    1.  Claim Clearinghouses or downstream applications MAY check for a
        "ga4gh_userinfo_claims" claim for a list of additional claims in the
        [GA4GH-specified format](#ga4gh-jwt-format) that may assist in making an
        access decision.

4.  Claim Clearinghouses service can be a broker itself and would follow the
    [Conformance For Brokers](#conformance-for-brokers).

5.  Claim Clearinghouses MUST provide protection againt attacks as outlined in
    [RFC 6819](https://tools.ietf.org/html/rfc6819).
    
6.  If making use of [Embedded Tokens](#term-embedded-token):

    1.  The Claim Clearinghouse MUST validate that all token checks pass (such as
        the token hasn’t expired) as described elsewhere in this specification and
        the underlying OIDC specifications.
    
    2.  When collecting claims from a nested set of /userinfo endpoints, the client
        MUST detect and avoid fetch loops and avoid fetching redundant entries that
        may appear at any level in the chain of Embedded Tokens. At a minimum,
        detection of redundant fetches MUST be based on the "iss" claim within a
        token (e.g. do not call /userinfo twice for the same "iss" to resolve the
        set of claims within a single token). Additional filtering MAY also be
        used.

    3.  When a client resolves a set of claims, it MUST limit the number of RPC
        calls to at most 20 /userinfo requests related to a single token, including
        both direct Embedded Tokens and more deeply nested Embedded Tokens.

7.  Clients MAY use access tokens, including Embedded Tokens, to occasionally
    check which claims are still valid at the associated /userinfo endpoint in
    order to establish whether the user still meets the access requirements.
    This MUST NOT be done more than once per hour (excluding any optional retries).
    Any request retries MUST include exponential backoff delays based on best
    practices (e.g. include appropriate jitter). At a minimum, the client MUST stop
    checking once any of the following occurs:

    1.  The user will no longer use these claims. For example, all downstream
        cloud tasks have terminated and the related systems will no longer be
        using the access token nor any downstream tokens that were generated by
        inspecting the token.

    2.  The JWT access token has expired as per the "exp" field.

    3.  The client has detected that the user owning the identity or a system
        administrator has revoked the access token or a refresh token related to
        minting the access token.

    4.  The /userinfo endpoint returns an HTTP status that is not retryable.
        For example, /userinfo returns HTTP status 400.

### GA4GH JWT Format

A well-formed JWS-Encoded JSON Web Token (JWT) consists of three concatenated
Base64url-encoded strings, separated by dots (.) The three sections are: header,
payload and signature. The access token and JWT with full claims use the same
format, though the JWT with the full claims will have extended claims. These
JWTs follow <https://tools.ietf.org/html/rfc7515> (JWS).

This profile is agnostic to the format of the id_token.

#### Access_token issued by broker

Header - The `kid` parameter must be included and `alg` must be `RS256`.
```
{
 "typ": "JWT",
 "alg": "RS256",
 ["kid": "xxxxx"](https://tools.ietf.org/html/rfc7515#section-4.1.4)
}
```

Payload:
```
{
 "iss": "https://\<issuer website\>/",
 "sub": "<someone@someone.com>",
 "idp": "google",
 "aud": [
  "client_id",
  "client_id2"
 ],
 "iat": 1553545136,
 "exp": 1553631536,
 "scope": "openid \<ga4gh-spec-scopes\>",
 "ga4gh_userinfo_claims": ["claim_name_1", "claim_name_2.substructure_name"],
 <ga4gh-spec-claims>
}
```
-   iss: MUST be able to be appended with .well-known/openid-configuration to
    get spec of broker.

-   sub: authenticated user unique identifier. A broker MAY abstract the suggested user email address with a unique identifier provided it maintains a way to map the user. See the ELIXIR for an implementation example. The sub in this case is a unique identifier issued by ELIXIR that abstracts the user's "real" email. Downstream Clearinghouses will need to know how to handle the `sub` attribute.

-   idp: (optional) SHOULD contain the IDP the user used to auth with. Such as
    "Google". This does not have to be unique and can be used just to help
    inform if that’s what a data owner or data holder needs.

-   aud: MUST contain the Oauth Client ID of the relying party except when
    allowing the token to be used as an open federation Embedded Token where
    `aud` MUST NOT be included. When included, it MAY contain other strings or
    identifiers as well.

-   iat: time issued

-   exp: time expired

-   scope: scopes verified. Must include "openid". Will also include any
    \<ga4gh-spec-scopes\> needed for the GA4GH compliant environment (e.g.
    "ga4gh" is the [scope for RI
    claims](https://github.com/ga4gh-duri/ga4gh-duri.github.io/blob/master/researcher_ids/RI_Claims_V1.md#requirement-7)).

-   ga4gh_userinfo_claims: Required but MAY be an empty array. A list of GA4GH claim names that are available from the OIDC /userinfo endpoint as per the [User Info JWT Format](#claims-sent-to-data-holder-by-a-broker-via-userinfo) section of the specification. For complex GA4GH claims with substructure,  a dot-notation MAY be used to more precisely indicate which sub-claims contain content within the /userinfo endpoint. Non-normative examples include:
["ga4gh"] : indicates that some RI claims are available beyond what is included in the access token but does not indicate which ones.
["ga4gh.ControlledAccessGrants", "ga4gh.AffiliationAndRoles"] : indicates that only those two specific RI claims that exist within the "ga4gh" claim object would have additional content not included within the access token.

-   \<ga4gh-spec-claims\>: (optional) See description in `/userinfo` response below.

#### Claims sent to Data Holder by a Broker via /userinfo

Only the GA4GH claims truly must be as proscribed here. Refer to OIDC Spec for more information. The /userinfo endpoint MAY use `application/json`, but `application/jwt` is preferred and `application/jwt` MUST be signed as per [UserInfo](https://openid.net/specs/openid-connect-core-1_0.html#UserInfoResponse) .
```
{
 "iss": "https://\<issuer website\>/",
 "sub": "<someone@someone.com>",
 "idp": "google",
 "aud": [
  "client_id",
  "client_id2"
 ],
 "iat": 1553545136,
 "exp": 1553631536,
 <ga4gh-spec-claims>
}
```
-   `<ga4gh-spec-claims>`: Claims included as part of a GA4GH standard specification based on the scopes provided. This content MAY be incomplete (i.e. a subset of data elements) and more may be fetched as indicated by ga4gh_userinfo_claims. A non-normative example of `<ga4gh-spec-claims>` is: "ga4gh": {[ga4gh claims](https://github.com/ga4gh-duri/ga4gh-duri.github.io/blob/master/researcher_ids/RI_Claims_V1.md)}


As a non-normative example, a valid \<ga4gh-spec-claims\> entry would be:

>   "ga4gh": {[ga4gh
>   claims](https://github.com/ga4gh-duri/ga4gh-duri.github.io/blob/master/researcher_ids/RI_Claims_V1.md#example-ri-claims)}

#### Authorization/Claims 

User attributes and claims are being developed in [GA4GH Researcher Identity
Claims](https://github.com/ga4gh-duri/ga4gh-duri.github.io/blob/master/researcher_ids/RI_Claims_V1.md)
document by the DURI work stream.

Token Revocation
----------------

#### Claim Authority Revokes Claim

Given that claims can cause downstream access tokens to be minted by Claim
Clearinghouses and such downstream access tokens may have little knowledge or no
connectivity to sources of claims, it can be challenging to build robust
revocation capabilities across highly federated and loosely coupled systems.
During the lifetime of the downstream access token, some systems may require
that claims are no longer inspected nor updated.

In the event that a claim’s authority revokes a claim within the claim’s source
system, downstream Brokers, Claim Clearinghouses, and other Authorization or
Resource Servers MUST at a minimum provide a means to limit the lifespan of any
given access tokens generated as a result of claims. To achieve this goal,
servers involved with access may employ one or more of the following options:

1.  Have each claim authorization be paired with an expiry date and a time of
    being issued. Expiry dates would require users to log in occasionally via an
    Identity Broker in order to refresh claims. On a refresh, expiry timestamps
    can be extended from what the previous claim may have indicated.

2.  Provide refresh tokens at every level in the system hierarchy and use
    short-lived access tokens. This may require all contributing system to
    support [OIDC offline
    access](https://openid.net/specs/openid-connect-core-1_0.html#OfflineAccess)
    refresh tokens to deal with execution of processes where the user is no
    longer actively involved. In the event that refresh tokens experience
    errors, the systems involved must eventually revoke the ability for
    downstream access tokens to be replaced via refresh tokens (although some
    level of delay to reach out to a user to try to resolve the issue may be
    desirable).

3.  Provide some other means for downstream Claim Clearinghouses or other
    systems that create downstream access tokens to be informed of a material
    change in upstream claims such that action can be taken to revoke the token,
    revoke the refresh token, or revoke the access privileges associated with
    such tokens.

#### Revoking Access from Bad Actors

In the event that a system detects that a user is misbehaving or has falsified
claims despite previous assurances that access was appropriate, there MUST be a
mechanism to withdrawal access from existing tokens and update claims to prevent
further tokens from being minted.

1.  Systems MUST have a means to revoke existing refresh tokens or remove
    permissions from access tokens that are sufficiently long-lived enough to
    warrant taking action.
    
    -   If an access token, in the form of an Embedded Token or otherwise, is
        long-lived, then the access token MUST be revocable, and once revoked
        the /userinfo endpoint MUST NOT return claims. In this event, an
        appropriate error status MUST be returned as per
        [section 5.3.3 of the OIDC specification](https://openid.net/specs/openid-connect-core-1_0.html#UserInfoError).

2.  A process MUST exist, manual or automated, to eventually remove related
    claims from the claim issuer’s repository.

#### Limited Damage of Leaked Tokens

In order to limit damage of leaked tokens, systems MUST provide all of the
following:

1.  Be able to leverage mechanisms in place for revoking claims to also limit
    exposure of leaked tokens.

2.  Follow best practices for the safekeeping of refresh tokens or longer lived
    tokens (should longer lived tokens be needed).

3.  Limit the life of refresh tokens or long lived keys before an auth challenge
    occurs or otherwise the refresh token simply fails to generate more access
    tokens.

4.  Any signed tokens that may be stored by participating services MUST be
    encrypted and follow best practices to limit the ability of administrators
    from decrypting this content.

Appendix
--------

#### Examples of broker technologies

Examples of suites that provide both functionalities in a single package are :
[Auth0.com](https://auth0.com/), [Keycloak](https://www.keycloak.org) (open
source), [Hydra](https://github.com/ory/hydra) (open source), OpenAM,
[Okta](https://www.okta.com/), Globus Auth, [Gen3
Fence](https://github.com/uc-cdis/fence),
[ELIXIR](https://elixir-europe.org/services/compute/aai), NIH/VDS, [AWS
Cognito](https://aws.amazon.com/cognito/).

#### Why Brokers?

We have found that there are widely used Identity Providers (IdP) such as Google
Authentication. These authentication mechanisms provide no authorization
information (custom claims or scopes) but are so pervasive at the institution
level that they cannot be ignored. The use of a "brokers" and "clearinghouses"
enables "inserting" information into the usual OIDC flow so that Google
identities can be used but claims and scopes can be customized.

For instance, if a stack is using just Google Auth, it can confirm some
semblance of identity, but the Google IdP gives no ability to insert claims into
the tokens it returns. This is true of many social logins and even institutional
SAML like ERACommons. Brokers like Auth0, Keycloak and others enable any number
of IdPs also give the stack owner the ability to insert into the token claims
that can be used by decision-making systems downstream.

Here is a diagram:
<https://www.lucidchart.com/invitations/accept/68f3089b-0c9b-4e64-acd2-abffae3c0c43>
of a full-broker. This is one possible way to use this spec.

![flow](https://github.com/ga4gh/data-security/blob/master/AAI/flow.png)

In this diagram, the Data Owner Claim Clearinghouse, the Data Holder Claim
Clearinghouse and the Identity Broker are all different entities. However, in
many cases, we expect the OIDC Broker and Data Owner to be the same entity and
even be operated in the same OIDC stack.

Examples of implementations that provide both Identity Brokering and Data Owner
Claim Clearinghouse services are:
[ELIXIR](https://docs.google.com/document/d/1hD0lsxotLvPaML_CSydVX6rJ-zogAH2nRVl4ax4gW1o/edit#heading=h.eilp6df62hbd),
[Auth0](http://auth0.com), [Keycloak](http://keycloak.org), [Globus
auth](https://www.globus.org/tags/globus-auth), [Okta](https://www.okta.com/),
[Hydra](https://github.com/ory/hydra), [AWS
Cognito](https://aws.amazon.com/cognito/). These can be Identity Brokers and/or
Claim Clearinghouses. They’re not usually only used for Claim consumption (akin
to a OAuth2 Resource Server in many ways). NGINX and Apache both offer reverse
proxies for "Claim Consumption Only" functionality --
<https://github.com/zmartzone/lua-resty-openidc> (with
<https://github.com/cdbattags/lua-resty-jwt>) and
<https://github.com/zmartzone/mod_auth_openidc> respectively.

Data holders and data owners should explore their options to decide what best
fits their needs.

#### Services parties are responsible for providing 

**Data Holders:**

Data holders are expected to protect their resources within a Claim
Clearinghouse Server. These Servers should be able to get claims from one or
more Brokers, with researcher authentication provided by one or more Identity
Providers. *Note: Most Claim Clearinghouses can provide access to resources
based on information in Claims -- if not the Claim Clearinghouses themselves
then in some downstream application that protects data.*

**Data Owners:**

Data owners are expected to run an OIDC Broker that has /userinfo endpoint. A
valid access token from a OIDC Identity Broker trusted by the data owner can be
used and claims sent back to the user wishing to access data.

Data owners are not required to implement or operate an Identity Provider
(though they may choose to do so) or an Identity Broker.

Data Owners may choose to operate an OIDC Claim Clearinghouse Server configured
to consume access_tokens from an upstream Identity Broker and then hand out JWT
claims to relying parties and other Claim Clearinghouses.

Some data owners will own the whole "chain" providing all of the different kinds
of brokers and will also operate Claim Clearinghouses. For instance, NIH is a
data owner and might provide Cloud Buckets and operate an IDP and Identity
Broker to utilize ERACommons and other identity resources.

A Data Owner should be able to, based on an Identity from an Identity Provider,
express some sort of [permissions](#ga4gh-jwt-format) via the Clearinghouse
Claims. It is the responsibility of the Data Owner to provide these permissions
to their OIDC Claim Clearinghouse to be expressed claims within a standard
/userinfo process for downstream use.

It is possible that the IdPs might have special claims. The OIDC Claim
Clearinghouse being operated by the Data Owner should be "looking" for those
claims and incorporating them, if desired, into the claims that it eventually
sends to the user.

A data owner is expected to maintain the [operational
security](https://github.com/ga4gh/data-security) of their OIDC Claim
Clearinghouse Server and hold it to the GA4GH spec for [operational
security](https://github.com/ga4gh/data-security). It is also acceptable to
align the security to a known and accepted framework such as NIST-800-53,
ISO-27001/ISO-27002.

#### Future topics to explore

<https://openid.net/specs/openid-connect-federation-1_0.html> - OIDC federation

Register the Claim - According to RFC 7519 (JSON Web Token) section 4.2
<https://tools.ietf.org/html/rfc7519#section-4.2> claim names should be
registered by IANA in its "JSON Web Token Claims" registry at
<https://www.iana.org/assignments/jwt/jwt.xml> . Register GA4GH.
