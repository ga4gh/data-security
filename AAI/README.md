# Introduction to the GA4GH Authentication and Authorization Infrastructure (AAI)

## Quick Links

- Specification: [GA4GH Authentication and Authorization Infrastructure (AAI) OpenID Connect Profile](https://github.com/ga4gh/data-security/blob/master/AAI/AAIConnectProfile.md)
- Other specifications that use the AAI profile: [GA4GH RI Claims](https://bit.ly/ga4gh-ri-v1)

### Table of Contents

- [**Introduction**](#introduction)
- [**Background**](#background)\
       - [Examples of broker technologies](#examples-of-broker-technologies)\
       - [Why Brokers?](#why-brokers)\
       - [Services parties are responsible for providing](#services-parties-are-responsible-for-providing)
- [**Future topics to explore**](#future-topics-to-explore)

## Introduction

The [GA4GH AAI profile
specification](https://github.com/ga4gh/data-security/blob/master/AAI/AAIConnectProfile.md)
leverages OpenID Connect (OIDC) Servers for use in authenticating the identity of
researchers desiring to access clinical and genomic resources from [data
holders](https://github.com/ga4gh/data-security/blob/master/AAI/AAIConnectProfile.md#term-data-holder)
adhering to GA4GH standards, and to enable data holders to obtain security-related
attributes of those researchers. This is intended to be endorsed as a GA4GH standard,
implemented by GA4GH Driver Projects, and shared broadly.

To help assure the authenticity of identities used to access data from GA4GH
Driver Projects, and other projects that adopt GA4GH standards, the Data Use and
Researcher Identity (DURI) Work Stream is in the process of developing a
standard of GA4GH Claims. This standard assumes that some GA4GH Claims provided
by Brokers described in this document will conform to the DURI researcher-identity
policy and standard. This standard does NOT assume that DURI's GA4GH Claims will be
the only ones used.

This AAI standard aims at developing an approach that enables data holders’
systems to recognize and accept identities from multiple Brokers -- allowing for
a federated approach. An organization can still use this specification and not
support multiple Brokers, though they may find in that case that it’s just using
a prescriptive version of OIDC.

## Background

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
Clearinghouse and the Broker are all different entities. However, in
many cases, we expect the Broker and Data Owner to be the same entity and
even be operated in the same OIDC stack.

Examples of implementations that provide both Identity Brokering and Data Owner
Claim Clearinghouse services are:
[ELIXIR](https://docs.google.com/document/d/1hD0lsxotLvPaML_CSydVX6rJ-zogAH2nRVl4ax4gW1o/edit#heading=h.eilp6df62hbd),
[Auth0](http://auth0.com), [Keycloak](http://keycloak.org), [Globus
auth](https://www.globus.org/tags/globus-auth), [Okta](https://www.okta.com/),
[Hydra](https://github.com/ory/hydra), [AWS
Cognito](https://aws.amazon.com/cognito/). These can be Brokers and/or
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

Data owners are expected to run an Broker that has /userinfo endpoint. A
valid access token from a Broker trusted by the data owner can be
used and claims sent back to the user wishing to access data.

Data owners are not required to implement or operate an Identity Provider
(though they may choose to do so) or an Broker.

Data Owners may choose to operate a Claim Clearinghouse server configured
to consume access_tokens from an upstream Broker and then hand out JWT
claims to relying parties and other Claim Clearinghouses.

Some data owners will own the whole "chain" providing all of the different kinds
of brokers and will also operate Claim Clearinghouses. For instance, NIH is a
data owner and might provide Cloud Buckets and operate an IDP and Broker to
utilize ERACommons and other identity resources.

A Data Owner should be able to, based on an Identity from an Identity Provider,
express some sort of [permissions](#ga4gh-jwt-format) via the Claim Clearinghouse
GA4GH claims. It is the responsibility of the Data Owner to provide these
permissions to their Claim Clearinghouse to be expressed claims within a standard
/userinfo process for downstream use.

It is possible that the IdPs might have special claims. The Claim Clearinghouse
being operated by the Data Owner should be "looking" for those claims and
incorporating them, if desired, into the claims that it eventually sends to the
user.

A data owner is expected to maintain the [operational
security](https://github.com/ga4gh/data-security) of their Claim Clearinghouse
server and hold it to the GA4GH spec for [operational
security](https://github.com/ga4gh/data-security). It is also acceptable to
align the security to a known and accepted framework such as NIST-800-53,
ISO-27001/ISO-27002.

## Future topics to explore

<https://openid.net/specs/openid-connect-federation-1_0.html> - OIDC federation

Register the Claim - According to RFC 7519 (JSON Web Token) section 4.2
<https://tools.ietf.org/html/rfc7519#section-4.2> claim names should be
registered by IANA in its "JSON Web Token Claims" registry at
<https://www.iana.org/assignments/jwt/jwt.xml> . Register GA4GH.
