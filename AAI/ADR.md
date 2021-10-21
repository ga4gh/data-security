---
layout: page
title: ADR
permalink: aai-adr
---

The architectural decision register (ADR) records major architectural decisions
made during the development of the specifications, and their rationale.


### 2020-xx-yy Claims must retain original authority

*Decision*

It is not enough for a broker to present a set of claims in a JWT - as signed by a
broker. Due to the nature of genomics requiring different parties all playing a part
in constructing the set of claims, the specification requires the ability for these
claims themselves to be signed by the original authority of the claim.

*Rationale*

*Links*

*Known Limitations*




### 2020-xx-yy Initial OIDC access token cannot be used as a bearer token with GA4GH claims

*Decision*

The initial OIDC flow results in a JWT access token - but the specification
explicitly forbids this from containing GA4GH claims, or from being used as a bearer token
for the purposes of GA4GH passports.

This is because the standard OIDC flow will also often result in identifying details of
the researcher ("email" or "profile" scope) being contained within the JWT claims.

The initial OIDC JWT access token must be exchanged first for a passport - that will
contain *only* claims suitable for use in a passport.
