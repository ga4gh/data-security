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
leverages OpenID Connect (OIDC) Servers to authenticate researchers
desiring to access clinical and genomic resources from [data
holders]({% link AAI/AAIConnectProfile.md %}#term-data-holder)
adhering to GA4GH standards. Beyond standard OIDC authentication, AAI enables
data holders to obtain security-related attributes and authorizations of those
researchers.

The Data Use and Researcher Identity (DURI) Work Stream has developed standard
[claims](https://github.com/ga4gh-duri/ga4gh-duri.github.io/tree/master/researcher_ids)
for representing common researcher authorizations and attributes. This standard
assumes that GA4GH Claims provided by Brokers described in this document
MAY conform to the DURI researcher-identity policy and standard. This standard
does NOT assume that DURI's GA4GH Claims will be the only ones used.

#### Separation of Data Holders and Data Controllers

It is a fairly common situation that, for a single dataset, the
[data controller](aai-openid-connect-profile#term-data-controller)
(the authority managing who has access to dataset) is not the same party as the 
[data holder](aai-openid-connect-profile#term-data-holder) (the organization
enforcing access based on the policies of the data controller).

For these situations, AAI is a standard mechanism for data holders to obtain
and validate authorizations from data controllers.

The AAI standard enables data holders' and data controllers' systems to recognize
and accept identities from multiple Brokers --- allowing for an even more federated
approach.

An organization can still use this specification with a single Broker and Visa Issuer,
though they may find in that case that there are few benefits beyond standard OIDC.

### Background

#### Why Brokers?

We have found that there are widely used Identity Providers (IdP) such as Google
Authentication. These authentication mechanisms provide no authorization
information (custom claims or scopes) but are so pervasive at the institution
level that they cannot be ignored. The use of a "broker" and "clearinghouse"
enables attaching information to the usual OIDC flow so that Google and other
prominent identity providers can be used with customized claims and scopes.

We have also found that some brokers, such as ELIXIR for example, provide
useful "extra" claims on top of IdPs like Google, but institutions
receiving ELIXIR claims might have cause to add even more claims.

The Broker model is flexible enough to accommodate this kind of "chaining"
(where one broker relies on and enriches the identity of another), provided
that Visa assertions are always signed-by the original asserting authority.

Here is a diagram of a single broker. This is one possible way to use this spec.

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

In this diagram, the Broker relies on a separate service for fetching visas, which
stores assertions from multiple sources. The visa assertions are obtained by the
Clearinghouse after a successful login, and used to determine a researcher's
access in the Clearinghouse system.

The Broker, Clearinghouse, and Visa Issuer may be separate services (as shown
in this diagram), but in other configurations they may be run as parts of a single
service, or as separate services run by single organization.

Data holders and data controllers should explore their options to decide what best
fits their needs.

#### Visa Tokens Explanation

The recommended approach to using AAI involves signed-JWTs called Visas,
for securely transmitting authorizations or attributes of a researcher.
Visas are signed by the Visa Issuer, which may be a service other than
the Broker. Using JWTs signed by private key, allows Clearinghouses to
validate Visas from known issuers in situations where they may not have
network connections to the issuers.
