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

#### Technical Summary

At its core, the AAI specification defines cryptographically secure tokens for exchanging
researcher attributes called [Visas](aai-openid-connect-profile#term-visa), and how various
participants can interact to authenticate researchers, and obtain and validate visas.

The main components identified in the specification are:
* [Visa Issuers](aai-openid-connect-profile#term-visa-issuer), that cryptographically sign researcher attributes in the
form of visas.
* [Brokers](aai-openid-connect-profile#term-broker), that authenticate researchers and broker access to visas associated
with researchers.
* [Passport Clearinghouses](aai-openid-connect-profile#term-passport-clearinghouse), that accept tokens containing or
otherwise availing researcher visas for the purposes of enforcing access control.

#### Visa Tokens

The recommended approach to using AAI involves signed-JWTs called Visas,
for securely transmitting authorizations or attributes of a researcher.
Visas are signed by the Visa Issuer, which may be a service other than
the Broker. Using JWTs signed by private key, allows Clearinghouses to
validate Visas from known issuers in situations where they may not have
network connections to the issuers.

#### Separation of Data Holders and Data Controllers

It is a fairly common situation that, for a single dataset, the
[data controller](aai-openid-connect-profile#term-data-controller)
(the authority managing who has access to dataset) is not the same party as the 
[data holder](aai-openid-connect-profile#term-data-holder) (the organization
that hosts the data, while respecting the data controller's access policies).

For these situations, AAI is a standard mechanism for data holders to obtain
and validate authorizations from data controllers, by specifying the interactions
between Visa Issuers, Brokers, and Clearinghouses.

The AAI standard enables data holders' and data controllers' systems to recognize
and accept identities from multiple Brokers --- allowing for an even more federated
approach. An organization can still use this specification with a single Broker and Visa Issuer,
though they may find in that case that there are few benefits beyond standard OIDC.

### Background

#### Why Brokers?

We have found that there are widely used Identity Providers (IdP) such as Google
Authentication. These authentication mechanisms provide no authorization
information (custom claims or scopes) but are ubiquitous for authentication at the institution level.
level that they cannot be ignored. The use of a Broker and Clearinghouse
enables attaching information to the usual OIDC flow so that Google and other
prominent identity providers can be used with customized claims and scopes.

Here is a diagram of a single broker. This is one possible way to use this spec.

@startuml
skinparam componentStyle rectangle
left to right direction

component "<b>Visa Issuer 1</b>\nservice" as Issuer1
component "<b>Visa Issuer 2</b>\nservice" as Issuer2
component "<b>Visa Issuer N</b>\nservice" as IssuerN

component "<b>Broker</b>\nservice" as Broker #FAFAD2
component "<b>Passport Clearinghouse</b>\nservice" as ClearingHouse #9E7BB5

Issuer1 <-- Broker : Fetch Visas
Issuer2 <-- Broker : Fetch Visas
IssuerN <-- Broker : Fetch Visas
Broker <-- ClearingHouse : Request User Visas w/ Access Token
IssuerN <-- ClearingHouse : Request Public Key w/ JWKS

@enduml

In this diagram, the Broker relies on a separate service for fetching visas, which
stores assertions from multiple sources. The visa assertions are obtained by the
Clearinghouse after a successful login, and used to determine a researcher's
access in the Clearinghouse system.

The Broker, Clearinghouse, and Visa Issuer may be separate services (as shown
in this diagram), but in other configurations they may be run as parts of a single
service, or as separate services run by single organization. Data holders and data
controllers should explore their options to decide what best fits their needs.
