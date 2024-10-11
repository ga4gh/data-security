Global Alliance for Genomics and Health Data Security Infrastructure Policy

## Global Alliance for Genomics and Health

# DATA SECURITY INFRASTRUCTURE POLICY

Standards and implementation practices for protecting the privacy and security
of shared genomic and clinical data

## VERSION 4.0, September 25, 2019

## **Outline**

1.0 – [Introduction](#1-introduction)

2.0 – [Security Foundation](#2-security-foundation)   
2.1 – [Risk Assessment](#21-risk-assessment)   
2.2 – [Control Objectives](#22-control-objectives)   
2.3 – [Guiding Principles](#23-guiding-principles)   
2.4 – [Data Security Stakeholders](#24-data-security-stakeholders)

3.0 – [Security Technology Building Blocks](#3-security-technology-building-blocks)  
3.1 – [Identity Management](#31-identity-management)  
3.2 – [Authorization and Access Control](#32-authorization-and-access-control)  
3.3 – [Privacy Protection](#33-privacy-protection)  
3.4 – [Audit Logs](#34-audit-logs)  
3.5 – [Data Integrity](#35-data-integrity)  
3.6 – [Non-repudiation](#36-non-repudiation)  
3.7 – [Cryptographic Controls](#37-cryptographic-controls)  
3.8 – [Communications Security](#38-communications-security)

4.0 – [Operational Assurances](#4-operational-assurances)  
4.1 – [Physical and Environmental Security](#41-physical-and-environmental-security)  
4.2 – [Service Assurances](#42-service-assurances)  
4.3 – [Information Security Oversight and Accountability](#43-information-security-oversight-and-accountability)  
4.4 – [Regulatory and Policy Compliance](#44-regulatory-and-policy-compliance)

5.0 – [Conclusion](#5-conclusion)   
5.1 – [Next Version Inclusions](#51-next-version-inclusions)

6.0 – [References](#6-references)

## 1. Introduction

This document describes the data security infrastructure recommended for
stakeholders in the *Global Alliance for Genomics and
Health* (GA4GH) community. This is not meant to be a normative document, but it should be framed as a set of recommendations and best practices to enable a secure data sharing and processing ecosystem. However, it does not claim to be exhaustive, and additional  precautions other than the ones collected herein might have to be taken to be compliant with  national / regional legislations. As a living document, the *Data Security
Infrastructure Policy* will be revised and updated over time, in response to changes in
the [GA4GH Privacy and Security
Policy](https://www.ga4gh.org/product/data-privacy-and-security-policy/)
[1], and as technology and biomedical science continue to advance.

The GA4GH is an unincorporated collaboration among entities and individuals
pursuing the common mission of accelerating progress in medicine and human
health by advancing a common infrastructure of harmonized approaches to enable
effective and responsible processing of clinical and genomic data. Towards that
end, the GA4GH develops standards aiming to enable responsible genomic data
processing within a [human rights
framework](https://www.ga4gh.org/product/framework-for-responsible-sharing-of-genomic-and-health-related-data/).

All of these standards depend upon a safe, robust, and trustworthy technology
infrastructure that, along with a set of common values and expectations set
forth in the [Framework for Responsible Sharing of Genomic and Health-Related
Data](https://www.ga4gh.org/product/framework-for-responsible-sharing-of-genomic-and-health-related-data/)
[2], provide the foundation for the GA4GH ecosystem. The viability and success
of the envisioned GA4GH ecosystem are directly dependent upon *trust* – the
ability of Alliance stakeholders to trust each other, the ability of users to
trust the technology infrastructures within which the GA4GH standards are
implemented, and the ability of individuals who contribute their personal
clinical and genomic data to trust GA4GH stakeholders to use their data
responsibly and respectfully.

As an interdependent, emergent ecosystem, the GA4GH supports multiple physical
and logical architectures. Therefore, the security technology outlines herein
are not intended to describe a physical or operational implementation, but
rather suggests a set of security and architectural standards, guidelines, and
best practices for implementing and operating a trustworthy, federated
environment within which data and services are shared. Given the important role
that trust plays in pursuing the mission of the GA4GH, the security technology
infrastructure is not limited to those mechanisms traditionally considered
“security” technologies, such as authentication, authorization, access control,
and audit, but also includes architectural guidance for building and operating
trustworthy systems – that is, systems that can be relied upon to perform their
expected functions and to withstand threats to data integrity, information
confidentiality, and service availability.

The *Framework for Responsible Sharing of Genomic and Health-Related Data*
describes the principles that form the trust foundation for GA4GH. The *GA4GH
Privacy and Security Policy,* which builds upon this *Framework*, articulates
policies for securing the data and services provided under the auspices of the
GA4GH with the privacy of the individuals who enable their genomic and
health-related data to be discovered, accessed, and used. The *Data Security Infrastructure Policy* defines guidelines, best practices, and standards for
building and operating a technology infrastructure that adheres to the GA4GH
*Framework* principles and enforces the GA4GH *Privacy and Security Policy*.

![Fig 1](https://github.com/ga4gh/data-security/blob/master/DSIP/Figures/Fig.1-documents-structure-1.png)
**Figure 1. Framework, Data Privacy and Security Policy, and Data Security Infrastructure Policy relationships.**

The technology infrastructure defined herein aims to reflect the prevailing
state of practice, while enabling emerging approaches to processing sensitive
information on a massive scale. It is intended to support a broad range of
existing use cases, while allowing innovation. We realize that as the volume and
value of clinical and genomic data continue to increase exponentially, threat
agents will become ever more determined to find and exploit vulnerabilities in
the technology infrastructures that transmit, store, and process this data.

We strongly encourage organizations to adhere to a recognized security
framework, such as ISO/IEC 27001 [3] or the U.S. National Institute of Standards
and Technology Special Publication 800-53 [4] to accomplish the control and
assurance objectives arising from identified risks concerning data sensitivity
and integrity, and services availability.

## 2. Security Foundation

### 2.1 Risk Assessment

The GA4GH *Data Security Infrastructure Policy* is based on a balanced approach
to risk management that relies on each individual stakeholder to help protect
the security, integrity, and trustworthiness of the GA4GH ecosystem. Each
stakeholder should assess its individual risk on an on-going basis and ensure
that its own implemented policies, procedures, and technology protections are
appropriate and sufficient for managing the identified risks not only to the
enterprise, but to the GA4GH ecosystem.

To be successful, the GA4GH ecosystem needs to effectively manage the following
risks. [5]

-   Data Breach - *“a breach of security leading to the accidental or unlawful
    destruction, loss, alteration, unauthorised disclosure of, or access to,
    personal data transmitted, stored or otherwise processed”* [6].

    -   Breach of confidentiality – unauthorized disclosure of information that
        an individual or organization wishes to keep confidential.

    -   Breach of individual privacy and autonomy – access to and use of an
        individual’s genomic or health-related data without the appropriate
        knowledge or consent of the individual concerned, or for purposes the
        individual has not authorized.

-   Malicious or accidental corruption or destruction of genomic and
    health-related data.

-   Disruption coming from malicious/targeted acts in the availability of data
    and services necessary to maintain appropriate access to clinical and
    genomic data.

-   Unethical, illegal, or inappropriate actions that attempt to breach security
    controls, surreptitiously obtain or derive information in an unauthorized
    manner, or otherwise undermine the trust fabric of the GA4GH.

### 2.2 Control Objectives

The *Privacy and Security Policy* specifically builds upon the *Framework’s*
Core Element: “Privacy, Data Protection and Confidentiality”. The *Data Security Infrastructure Policy* recommends technical safeguards, standards,
guidelines, and best practices for implementing and operating a technology
infrastructure that will enable individual stakeholders to implement GA4GH
standards safely, and to enforce the *Policy* defined for the GA4GH ecosystem.

Thus, the *Data Security Infrastructure Policy* is defined to meet the following
six control objectives that respond to the risks identified in the above
sub-section.

-   *Control Objective 1*: Implement technology safeguards to minimize the risk of unauthorized access, use, or disclosure of confidential and private data.

-   *Control Objective 2*: Implement technology safeguards to minimize the risk of discovery, access, and use of individuals’ clinical and genomic data, and individual identities, other than as authorized by applicable jurisdictional law, institutional policy, and individual consents.

-   *Control Objective 3*: Implement technology safeguards to minimize the risk of  accidental or malicious corruption or destruction of data.

-   *Control Objective 4*: Implement technology safeguards to minimize the risk of disruption, degradation, and interruption of services enabling access to data.

-   *Control Objective 5*: Implement technology safeguards to minimize the risk of potential security attacks and misuse of authorized accesses and privileges.

-   *Control Objective 6*: Implement technology safeguards to promptly detect the failure to attain the above control objectives and to respond with proper countermeasures.

### 2.3 Guiding Principles

The *Data Security Infrastructure Policy* is consistent with the [Framework for
Responsible Sharing of Genomic and Health-Related
Data](https://www.ga4gh.org/product/framework-for-responsible-sharing-of-genomic-and-health-related-data/),
and seeks to enforce the policy articulated in the [GA4GH Privacy and Security
Policy](https://www.ga4gh.org/product/data-privacy-and-security-policy/)*.*

### 2.4 Data Security Stakeholders

As a virtual ecosystem, the GA4GH assigns roles and responsibilities for
information security to stakeholders within this ecosystem. From a security and
privacy perspective, the principal stakeholders are:

*Operational Stakeholders*:

1.  *Data Contributors*: the entities who make their data available for
    exploitation to the GA4GH ecosystem. These include:

    1.  Data subjects – people who allow their genomic and health-related data
        to be used and shared;

    2.  Data owners – the legal persons, agencies or bodies to which data
        subjects delegate the authority to decide on the access and usage of
        their data.

2.  *Data Controllers*: the entities to which Data Contributors delegate the
    responsibility of ensuring the integrity and quality of data made available
    to the GA4GH community, and of guaranteeing that data management is
    consistent with GA4GH standards, applicable law, institutional policy, and
    individual permissions.

3.  *Data Processors*: the entities who process the data provided by Data
    Contributors according to the business and security policies set by Data
    Controllers, and which put in place all the needed technical safeguards to
    enforce them. These include:

    1.  Infrastructure service providers - entities that provide technology
        resources and technical support for persisting, protecting, managing,
        accessing, transmitting, and using electronic data; they include both
        enterprise and cloud service providers;

    2.  Data service providers – entities that provide data storage, protection,
        management, access, and transmission services to the GA4GH community,
        and optionally ensure that data transmitted or uploaded to other
        destinations are qualified according to the specifications for both data
        and metadata quality, access constraints, and semantics, as appropriate;

    3.  Application service providers – entities that provide application
        services, such as web-based or mobile clients, for manipulating and
        analyzing data using GA4GH standards.

*Global Alliance for Genomics and Health* – a collaborative community of individuals and organizations
that collectively provide foundational policy, technology standards, leadership,
and sustainment to enable the ethical and productive processing and use of
genomic and health-related data.

![Fig 2](https://github.com/ga4gh/data-security/blob/master/DSIP/Figures/Fig.2-stakeholders.png)
**Figure 2. Data security roles and their relationships.**

The GA4GH expects that in many cases, one organization may behave in more than one operational stakeholder role. For example, a data controller may also be a data service provider; an infrastructure service provider might also offer application and data services hosted on the infrastructure they support. In such cases, the organization as a whole must demosntrate control effectiveness for the applicable controls. The expectation is that operational stakeholders should document the roles and responsibilities as appropriate within that community. Furthermore, such organization should assure that security-critical functions and responsibilities are delegated among multiple roles and multiple individuals to help avoid conflicts of interest, prevent inappropriate activities, provide broader coverage and reduce key person-risk.

Figure 3 below is a graphical representation of the delegation of
responsibilities for implementing and operating in accordance with the GA4GH
*Data Security Infrastructure Policy*.

![Fig 3](https://github.com/ga4gh/data-security/blob/master/DSIP/Figures/Fig.3-responsibilities.png)

**Figure 3. Allocation of responsibility for security protections.** The functions listed in the vertical leftmost block are shared by all operational stakeholders, albeit in a different way for each actor (e.g data processors should notify if any breach occurs, but they are not responsible to act upon it) . Functions listed in the other blocks are allocated to data controllers, data processors, and GA4GH.

Infrastructure service providers may provide a wide range of services to data and application service providers, including computing, storage, network, and security services. Most commonly, these services will be virtualized across data centers and geographic locations. The applicability of, and responsibility for providing, each of the security functions within the “data processor” block will depend upon the specific services provided, as well as the contractual agreements established between infrastructure service providers and their customers.

## 3. Security Technology Building Blocks

This section provides guidance on implementing security services within an operational stakeholder’s organization and across the GA4GH interconnected community.

Each stakeholder should perform a comprehensive risk assessment at least annually and should assess potential risk impacts whenever significant changes are made to network and system software or hardware.


### 3.1 Identity Management

The effectiveness of the *Data Security Infrastructure Policy* ultimately is
dependent upon the degree to which the actors (individuals and software
services) are known and can be trusted to conform to applicable policy.

-   Each API exposed by data and application services within the GA4GH community must have the capability to electronically authenticate its fully qualified domain name using a server certificate or, within the EU, a qualified electronic signature, as defined in Regulation (EU) No 910/2014 of the European Parliament and of the Council of 23 July 2014 on electronic identification and trust services for electronic transactions in the internal market and repealing Directive 1999/93/EC[7].

-   Each data processor must authenticate the identity of individuals and software accessing data and services under that processor’s control.

-   Data processors should externalize authentication and authorization services to trusted identity providers and brokers.

-   The level of assurance to which individual identities will be established
    (i.e., identity proofing) and authenticated must be consistent with the
    level of risk associated with the actions to be performed by that
    individual. Each data processor is encouraged to use the US National Institute of
    Standards and Technology (NIST) Special Publication 800-63-3 [8] as guidance
    in determining the appropriate level of assurance required for identity
    proofing, authentication, and federation.

-   Data processors should use the *GA4GH Authentication and
    Authorization Infrastructure* (AAI) standard [9] to federate identity
    authentication and service authorization. Data processors should also
    use GA4GH standards for representing researcher identity attributes in
    OpenID Connect (OIDC) claims [10], and data use ontology (DUO) [11] for
    representing security and privacy attributes of shared data.

### 3.2 Authorization and Access Control

-   Each data processor must implement access control policies and mechanisms to ensure that only authorized users (human user or software client) may access data and services authorized and provided through the GA4GH community, and that each authenticated user is given access to all and only data and services to which it has been authorized.

-   Access authorizations may be based on organization, individual user, role, location and context (e.g., purpose, authorization time limits).

-   Each data processor  must control the access to genomic and health-related data in accordance with applicable law and the personal authorizations associated with the data.

-   Each data processor must assure that any disclosure of identifiable data includes the personal authorization rules the recipient must enforce with respect to access to and use of that data.

-   Each data processor with whom genomic or health-related data is shared must control access to and use of that data in accordance with the personal authorization rules (i.e., consents, permissions) associated with the data.

-   Each data controller must put in place policies and procedures for determining whether a requesting data processor (human user or software client) is granted access to datasets and applications, and for authorizing rights and privileges associated with that access, in accordance with relevant jurisdictional laws, GA4GH policies, institutional policies, and data controller authorizations.

-   Requests for access to data through an API should be communicated in a JSON
    structure, as specified in the *GA4GH Authentication and Authorization
    Infrastructure* (AAI) standard [9], and should include, at a minimum: (1)
    the authenticated identity and attributes of the requester (packaged in
    OpenID Connect tokens, using GA4GH *Researcher Identity* semantics [12]);
    (2) identification of requested resource; and (3) a description of intended
    use, represented in accordance with *GA4GH Data-Use* semantics [11].

-   As a prerequisite to obtaining data access, each data processor should have
    attested that (1) data will be used only by the authorized requester; and
    (2) any data persisted on a user device will be disposed of in accordance
    with the *Privacy and Security Policy*.

-   Each data controller must assign to each data processor the minimum access rights and privileges necessary for the requested use, consistent with the user’s authenticated identity, attributes, and context.

-   Each data processor must configure service APIs and service
    platforms so that they allow access consistent with the *Privacy and
    Security Policy* and the *GA4GH AAI Standard*, while blocking inappropriate
    uses and accesses.

-   OpenID Connect tokens issued by trusted identity providers or brokers may be
    used as a basis for authorizing data processors access rights and privileges.
    For example, a Research Passport issued through the UK National Institute of
    Health Research (NIHR) Research Passport System [13], might be used as the
    basis for authorizing researchers access rights and privileges to passport
    holders.

-   Each data processor should provide publicly accessible documentation of its policies and procedures for adjudicating requests for access to data and services.

### 3.3 Privacy Protection

-   Each data controller and data processor should use consent-management, access
    control, usage monitoring, auditing mechanisms, and other privacy-protecting
    mechanisms to help ensure that private and sensitive data are collected,
    used, shared, and reused only in accordance with the permissions granted by
    the individual (or authorized representative) to whom the data pertains, and
    in accordance with applicable law and institutional policies. Private and
    sensitive data include both personal data, such as genomic and
    health-related data, and data considered private and confidential by the
    data holder or jurisdictional law, such as, for example, data governed under
    the European General Data Protection Regulation (GDPR) [14], under the
    Health Insurance Portability and Accountability Act (HIPAA) [15], under
    appendix J of the Security and Privacy Controls for Federal Information
    Systems and Organizations [16], under the Australian Information
    Commissioner Act (AICA) [17], or any other similar law.

-   Each data controller should ensure that any procedures used to eliminate or minimize direct and/or indirect identifiers from data (e.g., pseudonymisation, de-identification, anonymisation) are performed at the earliest practical point in the workflow to minimize potential exposure of individual identity.

-   Each data controller should maintain a data inventory that includes defined sensitivity of data, restrictions on storage and data flows, and contracted data services responsible for enforcing these restrictions.

-   Each data controller should monitor data usage to detect attempts to access or use data other than as authorized, including attempts to analytically derive identity.

-   Each data controller and data processor should implement mechanisms to prevent the identity of individuals from being leaked through covert means such as metadata, URLs, message headers, and inference attacks.

-   Each data controller and data processor should implement safeguards to reduce the
    likelihood that de-identified, pseudonymized, or anonymised data can be
    re-identified through the query results or data record linkage (to prevent
    attacks such as Bustamante [18] and Homer [19]). To this end, they should use privacy-preserving record linkage methods  [20] and/or any other methods to reduce the risk of re-identification under formal frameworks such as differential privacy [21].

-   Each data controller must obtain the individual authorisations (e.g., consents) required by applicable law and institutional policy, and for conveying these authorisations, or a link to these authorisations, along with the associated data.

-   Each data controller must update provenance and confidentiality
    metadata associated with the data under its control, preferably using HL7
    FHIR provenance [22] and confidentiality [23] codes.

### 3.4 Audit Logs

-   Each data processor must record and maintain a log of security-relevant events involving access to or use of application and data services under that provider’s control.

-   For each security-relevant event, the data processor should record the following data elements: user identity, type of event, date and time, success or failure indication, origination of event, name of affected data, system component, or resource [24].

-   Each data processor should retain the audit log history for at least one year, with a minimum of three months immediately available for analysis (for example, online, archived, or restorable from backup). This best practice must be interpreted within the constraints of applicable law.

-   Each data processor must monitor activity on systems and networks under its control to detect potential security breaches and data misuse.

-   Each data processor should have a layered approach to instrumentation including,
    but not exclusive to;

    -   Log analysis

    -   Exception handling analysis

    -   Web Application Firewalls/Intrusion Detection Systems

-   Data processors’ audit log records should be integratable with existing
    enterprise security monitoring tools.

-   Data controllers and their processors must jointly implement the
    capability to generate an accounting of accesses to and disclosures of data
    that may be associated with the individual’s identity.

### 3.5 Data Integrity

-   Each data processor must protect the integrity of genomic and health-related data that it holds, uses, or transmits.

-   Each data processor that transmits or receives transmissions containing genomic
    or health-related data should use a collision-resistant hash
    function that complies with the Secure Hash Standard [25] by NIST (e.g.,
    IETF SHA-2 [26]) to verify the integrity of the transmission.

-   Each data controller must ensure the accuracy and verifiability of data and associated metadata.

-   Each data controller must ensure that data provenance information is associated with data made available to consumers.

### 3.6 Non-repudiation

-   Each data processor must have the capability to digitally sign content using a qualified electronic signature, as defined in Regulation (EU) No 910/2014 of the European Parliament and of the Council of 23 July 2014 on electronic identification and trust services for electronic transactions in the internal market and repealing Directive 1999/93/EC [7].

-   Data processors who offer downloadable software must digitally sign the downloadable files using a qualified electronic signature, as defined in Regulation (EU) No 910/2014 of the European Parliament and of the Council of 23 July 2014 on electronic identification and trust services for electronic transactions in the internal market and repealing Directive 1999/93/EC[7].

### 3.7 Cryptographic Controls

-   Each data processor must ensure that any cryptographic controls used are compliant with all applicable standards, agreements, laws, and regulations.

-   Each data processor that stores genomic or health-related data must use strong encryption (cryptography based on industry-tested and accepted algorithms, along with strong key lengths and proper key-management practices) to encrypt the data for storage [27].

-   Each data processor must ensure that plaintext data encryption keys are stored outside the system in which data encrypted with those keys are persisted. When a key hierarchy is used, plaintext key encryption keys should be stored separately on the system storing data encryption keys.

-   Data processors should use privacy-preserving encryption methods
    (e.g., homomorphic encryption [28], secure multi-party computation [29])
    when applicable and practical.

### 3.8 Communications Security

-   Each data processor must ensure that communication channels are secured commensurate with the level of risk associated with the content being transmitted.

-   Each data processor that transmits unencrypted genomic or health-related data
    must protect its transmission (e.g., using IPsec [30, 31] or Transport Layer
    Security (TLS) protocol [32]).

-   Any electronic mail containing genomic, health-related, or other sensitive
    data must be secured (e.g., using S/MIME Version 2 [33, 34]).

## 4. Operational Assurances

### 4.1 Physical and Environmental Security

-   A data processor that stores or processes genomic or health-related data must provide physical and environmental safeguards to protect those data in accordance with applicable laws and regulations, institutional policies, and individual consents.

-   Each data processor who uses a third party to store or process genomic or health-related data must ensure that business agreements include an obligation to provide physical and environmental data protection.

### 4.2 Service Assurances

All data processors must implement appropriate defense-in-depth architectural assurances that enable them to provide a high level of service expectations, including:

-   *Availability* – the service should be able to perform its functions over a
    specified period of time, generally expressed as the proportion of time that
    a service is actually available within an agreed-upon time period.
    Availability is ensured through architectural and design features, and
    operational procedures that enhance reliability, maintainability,
    serviceability, resiliency, and security safeguards.

-   *Scalability (or elasticity)* – genomic and health-related data stores
    should be capable of expanding as the volume of data continues to grow,
    while protecting the confidentiality, integrity, and availability of its
    services.

-   *Infrastructure security* – security features and processes provided as part
    of a service should ensure that their networks, operating systems,
    applications, and database management systems isolate software processes and
    datasets to prevent interference and side-channel attacks. A “least
    privileges” approach should be used to harden execution environments.

-   *Code security* - software providers should make a best effort to ensure
    that their software is free of malicious code and that secrets are never in
    the code. Code should be checked for downstream library vulnerability
    (“supply chain attack”). Code should have an approval process before
    promotion (“protected branches”) and should be signed.

-   *Data durability* – all genomic and health-related data, critical data or
    data deemed vulnerable should be copied to a secure accessible secondary
    location and preserved in case the original data are corrupted, deleted,
    lost, or altered in any way. Backups can be ensured through regular copying
    of full databases and incremental data backup jobs of modified or newly
    created data.

-   *Disaster recovery* – the ability to restore the availability and
    accessibility of genomic and health-related data or data deemed critical in
    a timely manner should, for example, a natural disaster or security breach
    occur.

-   *Data retention* – the period of time that data should be retained is
    contingent on applicable jurisdictional law and institutional policy.
    Archived data should be retained for no longer than is necessary before
    being deleted to minimize the risk of a breach of data.

-   *Data destruction* – ensure that all information that has reached its
    end-of-life (as applicable under jurisdictional law) is destroyed safely and
    permanently to minimize storage and an organization’s risk to a breach of
    data.

### 4.3 Information Security Oversight and Accountability

-   Each data controller must document the privacy and security practices and
    procedures it uses to make its data and services available within the GA4GH
    community, consistent with the GA4GH *Privacy and Security Policy*, and must
    ensure that its processors make this documentation conveniently available to
    data subjects.

-   At the request of a data subject whose data are being stored and shared within the GA4GH community, the responsible data controller should provide the data subject information about how and by whom their data are being accessed and used and for what purposes.

-   Each data controller must document the behavioral standards associated with the
    use of data and services made available to data processors, consistent with
    GA4GH *Privacy and Security Policy*, and must require data processors to attest
    to their understanding of, and commitment to adhere to these standards.

-   Data controllers should provide traceability and proof of conduct for all data destroyed, particularly when outsourcing this effort to third parties.

-   Each data processor must document and enforce written operational procedures for protecting the confidentiality and integrity of data, the availability of services, and the privacy of individuals who contribute their personal data.

-   Each data processor should engage an independent third party to conduct penetration testing of its service infrastructure at least annually. Any necessary remediation activity should be conducted as quickly as possible, and subjected to both functional and assurance testing.

-   Each data processor must have documented procedures for monitoring system activities, detecting potential threats and vulnerabilities (vulnerability reporting), and notifying potential security incidents (breach notification).

-   Each data processor, in collaboration with the corresponding data controller, must investigate and resolve security incidents, breaches, and reported threats as quickly as possible so as to minimize potential damage to data subjects, data loss, disruption of data and application services.

-   Each operational stakeholder must report any breaches in a way consistent
    with the *GA4GH Breach Response Strategy* [35]. Data controllers, in
    collaboration with the other operational stakeholders, will also respond to
    these breaches. In particular:

    -   Each operational stakeholder must report to applicable regulatory
        authorities or identified responsible actors any breaches resulting in
        the potential disclosure of genomic or health-related data

    -   Each operational stakeholder must report to GA4GH any breaches
        associated with the use of GA4GH standards and breaches that could
        damage the reputation and trustworthiness of the GA4GH community.

    -   Each data processor who experiences or suspects a data breach involving the
        disclosure of potentially identifiable data must
        expeditiously report the breach to the data controller responsible for
        the breached data.

    -   Each data controller who experiences, suspects, or receives a report of a
        data breach involving the disclosure of potentially identifiable data must expeditiously report the breach to the data subjects whose data were breached.

    -   Each data controller should work with its data processors to assess risks
        associated with the storage, use, and transmission of genomic and
        health-related data, and should contractually require appropriate
        technical mechanisms and procedures for preventing, detecting, and
        recovering from data breaches, consistent with the assessed risks.

-   Each GA4GH team that proposes a standard work product must complete an
    initial security risk-assessment at the start of product development.
    Prerequisite to approval as a GA4GH standard, the product must undergo a
    security evaluation that must include a final security risk assessment
    review and assurance testing, as appropriate.

### 4.4 Regulatory and Policy Compliance

-   Each data processor must ensure that data are transmitted, persisted, and protected in compliance with all applicable legal and ethical requirements.

-   Each operational stakeholder must implement protections consistent with this infrastructure, and ensure that contracts with third parties address the business partners’ obligations to implement such protections.

-   Each operational stakeholder must implement appropriate security procedures to ensure compliance with applicable legislative, regulatory, and contractual requirements relating to the use of genomic or health-related data, and personal information.

-   Each operational stakeholder must implement appropriate security procedures to ensure compliance with applicable legislative, regulatory, and contractual requirements relating to intellectual property rights.

-   Each operational stakeholder must implement, and attest
    to having implemented, security and privacy processes, procedures, and
    technology to enforce compliance with relevant legislation, regulations,
    contractual clauses, and the *GA4GH Privacy and Security Policy.*

-   Operational stakeholders may individually or collectively engage third
    parties to assess compliance with the GA4GH *Data Security Infrastructure*, and to evaluate the effectiveness of implemented
    protections.

## 5. Conclusion

This document provides a series of guidelines in an attempt to ensure that all
products/standards coming out of GA4GH uphold the basic security best practices
by operating a safe, robust, and trustworthy technology infrastructure.
Revisions of this document will take place every two years except if imperative
changes have to be made in the meantime (e.g. new technologies that have to be
contemplated). For those wishing to provide some feedback please contact us by
email at: <security-leads@ga4gh.org>.

### 5.1. Next version inclusions

The next revision of the *Data Security Infrastructure Policy* will include
sections on developer code security such as secrets’ management, dependency
analysis and static code analysis. It will also include a support document with
guidance and language on runtime protections for running application code.

## 6. References

[1] Global Alliance for Genomics and Health. *Privacy and Security Policy.* 26
May 2015. Available from
<https://www.ga4gh.org/wp-content/uploads/Privacy-and-Security-Policy.pdf>
(accessed 23 April 2019).

[2] Global Alliance for Genomics and Health. *Framework for Responsible Sharing
of Genomic and Health-Related Data*. 10 September 2014. Available from
<https://www.ga4gh.org/genomic-data-toolkit/regulatory-ethics-toolkit/framework-for-responsible-sharing-of-genomic-and-health-related-data/>
(accessed 23 April 2019).

[3] International Organisation for Standardisation/International
Electrotechnical Commission. ISO/IEC 27001:2013. *Information technology –
Security techniques – Information security management systems – Requirements.*
2013. Available from <https://www.iso.org/standard/54534.html> (accessed 23
April 2019).

[4] U.S. National Institute of Standards and Technology. NIST Special
Publication 800-53 Rev 4. Security and privacy controls for federal information
systems. June 2017. Available from
<https://csrc.nist.gov/publications/detail/sp/800-53/rev-4/final> (accessed 23
April 2019).

[5] From March 2014 meeting of Global Alliance Security Working Group.

[6] ARTICLE 29 DATA PROTECTION WORKING PARTY, Guidelines on Personal data breach
notification under Regulation 2016/679. Available from
<https://ec.europa.eu/newsroom/document.cfm?doc_id=47741> (accessed 9 August
2019)

[7] European Commission. Regulation (EU) No 910/2014 of the European Parliament
and of the Council of 23 July 2014 on electronic identification and trust
services for electronic transactions in the internal market and repealing
Directive 1999/93/EC. Available from
<https://eur-lex.europa.eu/legal-content/EN/TXT/?uri=uriserv%3AOJ.L_.2014.257.01.0073.01.ENG>
(accessed 23 April 2019).

[8] Grassi, P, ME Garcia, and JL Fenton. NIST Special Publication 800-63,
Revision 3: Digital identity guidelines. US National Institute of Science and
Technology. June 2017. DOI: 10.6028/NIST.SP.800-63-3. Available from
<https://pages.nist.gov/800-63-3/sp800-63-3.html> (accessed 23 April 2019).

[9] Authentication and Authorization Infrastructure standard (AAI). Currently
under submission to the GA4GH Product Review Committee. The standard is expected to be approved before 2020 and it should
be assumed that it will be.


[10] OpenID Connect. Available from <http://openid.net/connect/> (accessed 26
April 2019).

[11] Data Use Ontology standard (DUO). Developed by the GA4GH Data Use and
Researcher Identities (DURI) Work Stream. Available from
<https://github.com/EBISPOT/DUO> (accessed 13 June 2019)

[12] Researcher Identity Standard (RI). Developed by the GA4GH Data Use and
Researcher Identities (DURI) Work Stream with the collaboration of the Data
Security (DSWS) and Regulatory and Ethics Work Streams (REWS). Available from
<https://ga4gh-duri.github.io/> (accessed 13 June 2019)

[13] UK National Institute of Health Research. The research passport and
streamlined human resources arrangements. Available from
<https://www.nihr.ac.uk/about-us/CCF/policy-and-standards/research-passports.htm>
(accessed 23 April 2019).

[14] European Union. General Data Protection Regulation. Available from
<https://eur-lex.europa.eu/eli/reg/2016/679/oj> (accessed 23 April 2019).

[15] United States of America. Health Insurance Portability and Accountability
Act. <https://www.hhs.gov/hipaa/index.html> (accessed 23 April 2019).

[16] Security and Privacy Controls for Federal Information Systems and
Organizations, appendix J, page 437.
<https://nvlpubs.nist.gov/nistpubs/SpecialPublications/NIST.SP.800-53r4.pdf>
(accessed 3 June 2019).

[17] Australia. The Australian Information Commissioner Act 2010 (AICA).
Available from <https://www.legislation.gov.au/Series/C2010A00052> (accessed 13
June 2019)

[18] Shringarpure, Suyash S; Bustamante, Carlos D: [Privacy Risks from Genomic
Data-Sharing Beacons.](https://www.ncbi.nlm.nih.gov/pubmed/26522470) The
American Journal of Human Genetics, pp. 1–16, 2015, ISSN: 00029297.

[19] Nils Homer; Szabolcs Szelinger; Margot Redman; David Duggan; Waibhav Tembe;
Jill Muehling; John V. Pearson; Dietrich A. Stephan; Stanley F. Nelson; David W.
Craig: [Resolving Individuals Contributing Trace Amounts of DNA to Highly
Complex Mixtures Using High-Density SNP Genotyping
Microarrays.](https://www.ncbi.nlm.nih.gov/pubmed/18769715) PLoS Genet, 4 (8),
pp. e1000167, 2008.

[20] Vatsalan, D, Christen, P, and Verykios, V S. [A taxonomy of
privacy-preserving record linkage
techniques.](https://doi.org/10.1016/j.is.2012.11.005) Information Systems.
38:6:946-969. Sept 2013

[21] Cynthia Dwork, [Differential
Privacy](https://www.utdallas.edu/~muratk/courses/privacy08f_files/differential-privacy.pdf),
in Automata, Languages and Programming, pp. 1--12, Springer, Berlin, Heidelberg,
2006

[22] Health Level Seven. Resource provenance – Content. Available from
<http://www.hl7.org/implement/standards/fhir/provenance.html> (accessed 23 April
2019).

[23] Health Level Seven. HL7 v3 Code System Confidentiality. Available from
<http://hl7.org/implement/standards/fhir/v3/Confidentiality/> (accessed 23 April
2019).

[24] Payment Card Industry Security Standards Council. Framework for a robust
payment card security process. Available from
<https://www.pcisecuritystandards.org/document_library?category=pcidss&document=pci_dss>
(accessed 23 April 2019).

[25] Secure Hash Standard by NIST. Availabe from
<https://www.nist.gov/publications/secure-hash-standard> (accessed 23 April
2019).

[26] Internet Engineering Task Force. IETF Request for Comment (RFC) 6668. SHA-2
data integrity verification for the secure shell (SSH) transport layer protocol.
Available from <http://tools.ietf.org/html/rfc6668> (accessed 23 April 2019).

[27] Barker Elainer, Roginsky Allen. [Transitioning the Use of Cryptographic
Algorithms and Key
Lengths.](https://nvlpubs.nist.gov/nistpubs/SpecialPublications/NIST.SP.800-131Ar2.pdf)
NIST Special Publication 800-131A Revision 2, March 2019

[28] Martin Albrecht and Melissa Chase and Hao Chen and Jintai Ding and Shafi
Goldwasser and Sergey Gorbunov and Shai Halevi and Jeffrey Hoffstein and Kim
Laine and Kristin Lauter and Satya Lokam and Daniele Micciancio and Dustin Moody
and Travis Morrison and Amit Sahai and Vinod Vaikuntanathan, [Homomorphic
Encryption Security
Standard](http://homomorphicencryption.org/wp-content/uploads/2018/11/HomomorphicEncryptionStandardv1.1.pdf).
From [homomorphicencryption.org](http://homomorphicencryption.org/), Toronto,
Canada, November 2018

[29] Fattaneh Bayatbabolghani, and Marina Blanton, [Secure Multi-Party
Computation](http://delivery.acm.org/10.1145/3270000/3264419/p2157-bayatbabolghani.pdf?ip=128.179.151.184&id=3264419&acc=ACTIVE%20SERVICE&key=FC66C24E42F07228%2E7E17DDD1CCA0F75B%2E4D4702B0C3E38B35%2E4D4702B0C3E38B35&__acm__=1560330720_78f5ea35d83ebbbc882da4646172a7d7),
Proceedings of the 2018 ACM SIGSAC Conference on Computer and Communications
Security (CCS '18), Toronto, Canada, 2018

[30] Internet Engineering Task Force. Security architecture for the internet
protocol. RFC 4301. December 2005. Available from
<http://tools.ietf.org/html/rfc4301> (accessed 23 April 2019).

[31] Internet Engineering Task Force. Using advanced encryption standard (AES)
CCM mode with IPsec encapsulating security payload (ESP). RFC 4309. December
2005. Available from <http://tools.ietf.org/html/rfc4309> (accessed 23 April
2019).

[32] Internet Engineering Task Force. The transport layer security protocol,
Version 1.2. RFC 5246. August 2008. Available from
<http://tools.ietf.org/html/rfc5246> (accessed 23 April 2019).

[33] Internet Engineering Task Force. S/MIME Version 2 message specification.
RFC 2311. March 1998. Available from <http://tools.ietf.org/html/rfc2311>
(accessed 23 April 2019).

[34] Internet Engineering Task Force. S/MIME Version 2 certificate handling. RFC
2312. Available from <http://www.ietf.org/rfc/rfc2312.txt> (accessed 23 April
2019).

[35] Breach Response Protocol. Currently under submission to the GA4GH Product
Review Committee.
