---
layout: page
title: AAI Introduction
permalink: aai-introduction
---

### Quick Links
{:.no_toc}

- Specification: [GA4GH Authentication and Authorization Infrastructure (AAI) OpenID Connect Profile]({% link AAI/AAIConnectProfile.md %})
- Other specifications that use the AAI profile: [GA4GH Passport](https://bit.ly/ga4gh-passport-v1)

### Table of Contents
{:.no_toc}

* toc
{:toc}

### Introduction

The [GA4GH AAI profile specification]({% link AAI/AAIConnectProfile.md %})
leverages OpenID Connect (OIDC) Servers for use in authenticating the identity of
researchers desiring to access clinical and genomic resources from [data
holders]({% link AAI/AAIConnectProfile.md %}#term-data-holder)
adhering to GA4GH standards, and to enable data holders to obtain security-related
attributes of those researchers. This is intended to be endorsed as a GA4GH standard,
implemented by GA4GH Driver Projects, and shared broadly.

To help assure the authenticity of identities used to access data from GA4GH
Driver Projects, and other projects that adopt GA4GH standards, the Data Use and
Researcher Identity (DURI) Work Stream has developed a standard around
[claims](https://github.com/ga4gh-duri/ga4gh-duri.github.io/tree/master/researcher_ids).
This standard assumes that some GA4GH Claims provided
by Brokers described in this document will conform to the DURI researcher-identity
policy and standard. This standard does NOT assume that DURI's GA4GH Claims will be
the only ones used.

This AAI standard aims at developing an approach that enables data holders’ and data owners 
systems to have systems that recognize and accept identities from multiple Brokers -- allowing for
a federated approach. An organization can still use this specification and not
support multiple Brokers, though they may find in that case that it’s just using
a prescriptive version of OIDC.

### Background

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

We have also found that some brokers, such as ELIXIR for example, provide
some useful "extra" claims on top of an IdP like Google, but an institution
receiving ELIXIR claims might want to add even more claims. Brokers then
had to have a mechanism for trusting claims from other Brokers while
providing provenance and proof of where they came from. This lead to
the Embedded Token structure.  

Here is a diagram:
<https://www.lucidchart.com/invitations/accept/68f3089b-0c9b-4e64-acd2-abffae3c0c43>
of a full-broker. This is one possible way to use this spec.

![flow diagram]({% link AAI/flow.png %})

In this diagram, the Data Owner Claim Clearinghouse, the Data Holder Claim
Clearinghouse and the Broker are all different entities. However, some cases,
the Broker and Data Owner might be the same entity and
even be operated with the same OIDC Provider Software.

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

#### Embedded Tokens example and explanation

![embedded claims flow diagram]({% link AAI/embedded_Claims_flow.png %})

Consider two parties: Google and ELIXIR.  

In this example, Google Passport Clearinghouse makes access decisions based
on ELIXIR Assertion Repository information via a chain of brokers that have
passed along the Passport Visas in standard GA4GH Passport format where the
Passports are signed by different Brokers but the Passport Visas retain
the signature from the Passport Visa Issuer. 

The way this chain of brokers and trust is maintained is through
"embedded tokens". There are two types of embedded
tokens: Embedded Access Tokens and Embedded Document Tokens. 

Embedded Access Tokens are claims in a Broker's token that can then be
sent to OTHER brokers' `/userinfo` endpoints for further user claims.
In GA4GH Passports, embedded access tokens will usually carry full claims
so as not to interrogate `/userinfo` each time.

Embedded Document Tokens cannot be revoked and no `/userinfo` endpoint
is provided for them, however they still offer a signature that can
be used to verify their provenance and always contain the necessary
claims in them already.

#### Services parties are responsible for providing 

**Data Holders:**

Data holders are expected to protect their resources within a Claim
Clearinghouse Server. These Servers should be able to get claims from one or
more Brokers, with researcher authentication provided by one or more Identity
Providers. *Note: Most Claim Clearinghouses can provide access to resources
based on information in Claims -- if not the Claim Clearinghouses themselves
then in some downstream application that protects data.*

**Data Owners:**

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

### Future topics to explore

<https://openid.net/specs/openid-connect-federation-1_0.html> - OIDC federation

Register the Claim - According to RFC 7519 (JSON Web Token) section 4.2
<https://tools.ietf.org/html/rfc7519#section-4.2> claim names should be
registered by IANA in its "JSON Web Token Claims" registry at
<https://www.iana.org/assignments/jwt/jwt.xml> . Register GA4GH.
