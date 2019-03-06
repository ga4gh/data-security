
Global Alliance for Genomics and Health Security Technology Infrastructure 

***Global Alliance for Genomics and Health***

SECURITY TECHNOLOGY INFRASTRUCTURE
==================================

Standards and implementation practices for protecting the privacy and security of shared genomic and clinical data 

**VERSION 3.0, August 9, 2016**

**Outline**

[1.0  Introduction](#introduction)

[2.0 – Security Foundation](#security-foundation) \
[2.1 – Risk Assessment](#risk-assessment) \
[2.2 – Privacy and Security Policy](#privacy-and-security-policy) \
[2.3 – Guiding Principles](#guiding-principles) \
[2.4 – Information Security Responsibilities](#information-security-responsibilities) 

[2.5 – GA4GH Assurance Dependencies](#ga4gh-assurance-dependencies) 

[3.0 – Security Technology Building Blocks](#security-technology-building-blocks) 

[3.1 – Identity Management](#identity-management) \
[3.2 – Authorization and Access Management](#authorization-and-access-management)

[3.3 – Privacy Protection](#privacy-protection) \
[3.4 – Audit Logs](#audit-logs) \
[3.5 – Data Integrity](#data-integrity) \
[3.6 – Non-repudiation](#non-repudiation) \
[3.7 – Cryptographic Controls](#cryptographic-controls) 

[3.8 – Communications Security](#communications-security) 

[4.0 – Operational Assurance](#operational-assurance) \
[4.1 – Physical and Environmental Security](#physical-and-environmental-security) 

[4.2 – Operations Security](#operations-security) \
[4.3 – Service Supplier Assurances](#service-supplier-assurances) \
[4.4 – Information Security Oversight and Accountability](#information-security-oversight-and-accountability) 

[4.5 – Compliance](#compliance)

[5.0 Definitions](#definitions)

[6.0 References](#references)

<a name="introduction"></a> **1. Introduction**

This document describes the security technology infrastructure recommended for stakeholders (see section 2.4 below) in the _Global Alliance for Genomics and Health_ (GA4GH) community. As a living document, the _Security Technology Infrastructure_ will be revised and updated over time, in response to changes in the _[GA4GH Privacy and Security Policy](https://www.ga4gh.org/wp-content/uploads/Privacy-and-Security-Policy.pdf)_ [1], and as technology and biomedical science continue to advance. 

The GA4GH is an unincorporated collaboration among entities and individuals pursuing the common mission of accelerating progress in medicine and human health by advancing a common infrastructure of harmonized approaches to enable effective and responsible sharing of clinical and genomic data. Toward that end, the GA4GH develops standards for enabling federated access to semantically interoperable genomic data through RESTful application programming interfaces (APIs), along with standards for defining, sharing, and executing portable application workflows.  

All of these standards depend upon a safe, robust, and trustworthy technology infrastructure that, along with a set of common values and expectations set forth in the _[Framework for Responsible Sharing of Genomic and Health-Related Data](https://www.ga4gh.org/ga4ghtoolkit/regulatoryandethics/framework-for-responsible-sharing-genomic-and-health-related-data/)_ [2], provide the foundation for the GA4GH ecosystem.  The viability and success of the envisioned GA4GH ecosystem are directly dependent upon _trust_– the ability of Alliance stakeholders to trust each other, the ability of users to trust the technology infrastructures within which the GA4GH standards are implemented, and the ability of individuals who contribute their clinical and genomic data to trust GA4GH stakeholders to use their data responsibly and respectfully. 

As an interdependent, emergent ecosystem, the GA4GH supports multiple physical and logical architectures. Therefore, the security technology infrastructure described herein is not intended to describe a physical or operational implementation, but rather suggests a set of security and architectural standards, guidelines, and best practices for implementing and operating a trustworthy, federated, environment within which data and services are shared. Given the important role that trust plays in pursuing the mission of the GA4GH, the security technology infrastructure is not limited to those mechanisms traditionally considered "security" technologies, such as authentication, authorization, access control, and audit, but also includes architectural guidance for building and operating trustworthy systems – that is, systems that can be relied upon to perform their expected functions and to withstand threats to data integrity, information confidentiality, and service availability.  

The _Framework for Responsible Sharing of Genomic and Health-Related Data_ describes the principles that form the trust foundation for GA4GH. The _GA4GH Privacy and Security Policy_, which builds upon the _Framework_ by articulating policies for securing the data and services provided under the auspices of the GA4GH, and the privacy of the individuals who enable their genomic and health-related data to be discovered, accessed, and used. The _Security Technology Infrastructure_ defines guidelines, best practices, and standards for building and operating a technology infrastructure that adheres to the GA4GH _Framework_ principles and enforces the GA4GH _Privacy and Security Policy_. 

The technology infrastructure defined herein seeks to reflect the prevailing state of practice, while enabling emerging approaches to sharing sensitive information on a massive scale. It is intended to support a broad range of existing use cases, while allowing innovation.  We realize that as the volume and value of clinical and genomic data continue to increase exponentially, threat agents will become ever more determined to find and exploit vulnerabilities in the technology infrastructures that transmit, store, and process these data.  

We strongly encourage organizations to adhere to a recognized security framework, such as ISO/IEC 27001 [3] or the U.S. National Institute of Standards and Technology Special Publication 800-30 [4] to accomplish the control and assurance objectives arising from identified risks to data sensitivity and integrity, and to the availability of services. 

<a name="security-foundation"></a>**2. Security Foundation**

<a name="risk-assessment"></a>**2.1 Risk Assessment**

The _GA4GH Security Technology Infrastructure_ is based on a balanced approach to risk management that relies on each individual stakeholder to help protect the security, integrity, and trustworthiness of the GA4GH ecosystem. Each stakeholder should assess its individual risk on an on-going basis and assure that its own implemented policies, procedures, and technology protections are appropriate and sufficient for managing the identified risks not only to the enterprise, but to the GA4GH ecosystem.  Each stakeholder should perform a comprehensive risk assessment at least annually and should assess potential risk impacts whenever significant changes are made to network and system software or hardware.   

To be successful, the GA4GH ecosystem needs to effectively manage the following risks. [5] 



*   Breach of confidentiality – unauthorized disclosure of information that an individual or organization wishes to keep confidential. 
*   Breach of individual privacy and autonomy – access to and use of an individual's genomic or health-related data without the appropriate knowledge or consent of the individual concerned, or for purposes the individual has not authorized. 
*   Malicious or accidental corruption or destruction of genomic and health-related data 
*   Disruption in availability of data and services necessary to maintain appropriate access to clinical and genomic data. 
*   Unethical, illegal, or inappropriate actions that attempt to breach security controls, surreptitiously obtain or derive information in an unauthorized manner, or otherwise undermine the trust fabric of the GA4GH. 

<a name="privacy-and-security-policy"></a>    **2.2 Privacy and Security Policy**


    The _Privacy and Security Policy_ specifically builds upon the _Framework's_ Core Element: "Privacy, Data Protection and Confidentiality." The _Security Technology Infrastructure_ recommends technical safeguards, standards, and practices to enforce the _Policy_ across the technology implementations that together comprise the GA4GH enterprise. 


    The _Security Technology Infrastructure_ recommends technical safeguards, standards, guidelines, and best practices for implementing and operating a technology infrastructure that will enable individual stakeholders to implement GA4GH standards safety, and to enforce the _Policy_ defined for the GA4GH ecosystem. 


    Thus, the _Security Technology Infrastructure_ is defined to meet the following five control objectives, responsive to the risks identified above. 

*   _Control Objective 1_: Implement technology safeguards to prevent unauthorized access, use, or disclosure of confidential and private data. 
*   _Control Objective 2_: Implement technology safeguards to prevent the discovery, access, and use of individuals' clinical and genomic data, and individual identities, other than as authorized by applicable jurisdictional law, institutional policy, and individual consents. 
*   _Control Objective 3_: Implement technology safeguards to prevent and detect accidental or malicious corruption or destruction of data. 
*   _Control Objective 4_: Implement technology safeguards to prevent disruption, degradation, and interruption of services enabling access to data. 
*   _Control Objective 5_: Implement technology safeguards to prevent and detect potential security attacks and misuse of authorized accesses and privileges. 

<a name="guiding-principles"></a>    **2.3 Guiding Principles**


    The _Security Technology Infrastructure_ is consistent with the _[Framework for Responsible Sharing of Genomic and Health-Related Data](https://www.ga4gh.org/ga4ghtoolkit/regulatoryandethics/framework-for-responsible-sharing-genomic-and-health-related-data/)_, and seeks to enforce the policy articulated in the _[GA4GH Privacy and Security Policy](https://www.ga4gh.org/docs/ga4ghtoolkit/data-security/Privacy-and-Security-Policy.pdf)._


<a name="information-security-responsibilities"></a>    **2.4 Information Security Responsibilities**


    As a virtual ecosystem, the GA4GH assigns roles and responsibilities for information security to stakeholders within this ecosystem. From a security and privacy perspective, the principal stakeholders are: 

1. Individuals – people who enable their genomic and health-related data to be used and shared within the GA4GH ecosystem 
2. Data stewards – entities responsible for assuring the quality and integrity of data made available to the GA4GH community, and for managing the metadata that preserves context and associated business rules, including privacy and security attributes, consistent with GA4GH standards, applicable law, institutional policy, and individual permissions. 
3. Data service providers – entities that provide data storage, protection, management, access, and transmission services to the GA4GH community, and optionally ensure that data transmitted or uploaded to other destinations are qualified according to the specifications for both data and metadata quality, access constraints, and semantics, as appropriate. 
4. Application service providers – entities that provide application services, such as web-based or mobile clients, for manipulating and analyzing data using GA4GH standards. 
1. Infrastructure service providers – entities that provide technology resources and technical support for persisting, protecting, managing, accessing, transmitting, and using electronic data; includes both enterprise and cloud service providers. 
2. Service consumers – individuals and software clients that use data and application services available to the GA4GH community. 
3. Global Alliance – a collaborative community of individuals and organizations that collectively provide foundational policy, technology standards, leadership, and sustainment to enable the ethical and productive sharing and use of genomic and health-related data. 

Consistent with jurisdictional laws and institutional policy, each data steward, service provider, and service consumer should publish the names, contact information, and roles of the individual(s) who have been delegated responsibility for overseeing conformance with the _Security Technology Infrastructure_ and for reporting breaches that involve GA4GH standards. 

Figure 1 below is a graphical representation of the delegation of responsibilities for implementing and operating in accordance with the GA4GH _Security Technology Infrastructure_. Color coding indicates the responsibilities of the respective stakeholders. 

Infrastructure service providers may provide a wide range of services to data and application service providers, including computing, storage, network, and security services. Most commonly, these services will be virtualized across data centers and geographic locations. The applicability of, and responsibility for providing, each of the security functions within the "service provider" block will depend upon the specific services provided, as well as the contractual agreements established between infrastructure service providers and their customers. 

The GA4GH leadership expects that in many cases, one organization may behave in more than one stakeholder role. For example, a data steward may also be a data service provider; an infrastructure service provider might also offer application and data services hosted on the infrastructure they support. In such cases, the organization as a whole is responsible for demonstrating control effectiveness for the applicable controls. The expectation is that stakeholders should document the roles and responsibilities as appropriate within that community. 



![Figure 1](https://github.com/ga4gh/data-security/blob/master/Security_Infra_Figure1.png)


**Figure 1. Allocation of responsibility for security protections.** Those functions listed in the vertical block are the responsibilities of the GA4GH community as a whole. Functions listed in other blocks are allocated to data stewards, service providers, service consumers, and GA4GH.  

<a name="ga4gh-assurance-dependencies"></a>**2.5  GA4GH Assurance Dependencies**

Figure 2 depicts the ISO/IEC Open Systems Interconnection Basic Reference Model [6] that for decades has provided a common basis for the coordination of standards developed to interconnect systems – the essential infrastructure for a federated GA4GH ecosystem.  The model is not intended to serve as an implementation specification, but rather provides a structure for the development of standard interconnection protocols, and represents functional dependencies from the highest level, software applications, to the lowest level, the physical network.  As shown in Figure 2, GA4GH standards generally address functions needed at the highest three levels – application (e.g., APIs, semantic data representation), presentation (e.g., syntax), and session (e.g., workflow orchestration).   

A general principle for building high-assurance infrastructure is to implement security protections as low in the technology stack (shown in Figure 2) as possible, while obtaining the granularity of control required.  For assured protection and greater resistance to tampering and interference, it is preferable to have services such as encryption, access control, auditing, and versioning implemented in the infrastructure rather than having each application be responsible for them. 

However, threat agents target interconnected systems at every layer in the model – from physical to application. Thus GA4GH standards are highly dependent upon the security protections and assurances provided by the layers below those at which the standards are applied.  Thus implementers of GA4GH standards must assure the trustworthiness of the infrastructure foundation upon which the application environment relies.  

The key is to implement a concept known as "defense in depth," in which layers of defense mechanisms are implemented such that if one mechanism fails, another will be in place to thwart an attack. [7]  To obtain defense in depth, security protections should be implemented at every layer in the infrastructure.  Integrating defense in depth offers more robust and consistent security protection and compliance, and provides for a more resilient system.



![Figure 2](https://github.com/ga4gh/data-security/blob/master/Security_Infra_Figure2.png)
  

**Figure 2.  Basic Reference Model showing assurance dependencies.** While the GA4GH standards are implemented at higher layers, assurance of the data and application services within which the standards are used is ultimately dependent on the trustworthiness of the underlying interconnected infrastructure.  

<a name="security-technology-building-blocks"></a>**3. Security Technology Building Blocks**

This section provides guidance on implementing security services within a stakeholder's organization and across the GA4GH interconnected community. 

<a name="identity-management"></a>**3.1 Identity Management**

The effectiveness of the _Security Technology Infrastructure_ ultimately is dependent upon the degree to which the actors (individuals and software services) are known and can be trusted to conform to applicable policy. 



*   Each API exposed by data and application services within the GA4GH community will have the capability to electronically authenticate its fully qualified domain name using a server certificate or, within the EU, a qualified electronic signature, as defined in Regulation (EU) No 910/2014 of the European Parliament and of the Council of 23 July 2014 on electronic identification and trust services for electronic transactions in the internal market and repealing Directive 1999/93/EC.[8] 
*   Each service provider will authenticate the identity of individuals and software accessing data and services under that provider's control. 
*   Data and application service providers are encouraged to externalize authentication and authorization services to trusted identity providers and brokers. 
*   The level of assurance to which individual identities will be established (i.e., identity proofing) and authenticated will be consistent with the level of risk associated with the actions to be performed by that individual. Each data and application service provider is encouraged to use the US National Institute of Standards and Technology (NIST) Special Publication 800-63-3 [9] as guidance in determining the appropriate level of assurance required for identity proofing, authentication, and federation. 
*   Service providers are encouraged to federate identity authentication and service authorization using OpenID Connect (OIDC) [10] for authentication and security attribute sharing, and OAuth 2.0 [11] for authorization.   Service providers are also encouraged to use GA4GH standards for representing researcher identity attributes in OIDC claims, and data use ontology (DUO) for representing security and privacy attributes of shared data.   

<a name="authorization-and-access-management"></a>**3.2 Authorization and Access Management**



*   Each service provider and service consumer will implement access control policies and mechanismss to assure that only authorized users (human user or software client) may access data and services authorized and provided through the GA4GH community, and that each authenticated user is given access to all of and only those data and services to which it has been authorized. 
*   Access authorizations may be based on organization, individual user, role, location and context (e.g., purpose, authorization time limits). 
*   Each service provider and service consumer is responsible for controlling access to genomic and health-related data in accordance with applicable law and the personal authorizations associated with the data. 
*   Each service provider and service consumer is responsible for assuring that any disclosures of identifiable data include the personal authorization rules the recipient must enforce with respect to access to, and use of, those data. 
*   Each service provider and service consumer with whom genomic or health-related data are shared will control access to and use of those data in accordance with the personal authorization rules (i.e., consents, permissions) associated with the data.
*   Each data steward is responsible for developing and implementing policies and procedures for determining whether a requesting service consumer (human user or software client) is granted access to data sets and applications, and for authorizing rights and privileges associated with that access, in accordance with relevant jurisdictional laws, GA4GH policies, institutional policies, and data steward authorizations. 
*   Requests for access to data through an API should be communicated in a JSON structure, as specified in the _GA4GH Authentication and Authorization Infrastructure_ (AAI) standard [TBD],  and should include, at a minimum: (1) the authenticated identity and attributes of the requester (packaged in OpenID Connect tokens, using GA4GH _Researcher Identity_ semantics [TBD]); (2) identification of requested resource; and (3) a description of intended use, represented in accordance with _GA4GH Data-Use_ semantics [TBD].  
*   As a prerequisite to obtaining data access, each data service consumer should have attested that   (1) data will be used only by the authorized requester; and (2) any data persisted on a user device will be disposed of in accordance with the _Privacy and Security Policy_. 
*   Each service provider is responsible for assigning to each service consumer the minimum access rights and privileges necessary for the requested use, consistent with the user's authenticated identity, attributes, and context. 
*   Each service provider is responsible for configuring service APIs and service platforms so that they allow access consistent with the _Privacy and Security Policy_ and the _GA4GH AAI Standard_, while blocking inappropriate uses and accesses. 
*   OpenID Connect tokens issued by trusted identity providers or brokers may be used as a basis for authorizing service consumers access rights and privileges. For example, a Research Passport issued through the UK National Institute of Health Research (NIHR) Research Passport System [12], might be used as the basis for authorizing researchers access rights and privileges to passport holders. 
*   Each service and infrastructure provider should assure that security-critical functions and responsibilities are delegated among multiple roles and multiple individuals to help avoid conflicts of interest and prevent inappropriate activities. 
*   Each service provider should provide publicly accessible documentation of its policies and procedures for adjudicating requests for access to data and services. 
*   Access authorization through application programming interfaces (APIs) should be implemented using the [OAuth 2.0 Authorization Framework (RFC 6749) [11].](https://tools.ietf.org/html/rfc6749)   
*   

<a name="privacy-protection"></a>**3.3 Privacy Protection**

*   Each data steward and service provider should use consent-management, access control, usage monitoring, auditing mechanisms, and other privacy-protecting mechanisms to help ensure that private and sensitive data are collected, used, shared, and reused only in accordance with the permissions granted by the individual (or authorized representative) to whom the data pertain, and in accordance with applicable law and institutional policies.   Private and sensitive data include both personal data, such as genomic and health-related data, and data considered private and confidential by the data holder or jurisdictional law, such as data governed under the European General Data Protection Regulation (GDPR) [25].  
*   Each data steward should ensure that any procedures used to eliminate or minimize direct and/or indirect identifiers from data (e.g., pseudonymisation, de-identification, anonymisation) are performed at the earliest practical point in the workflow to minimize potential exposure of individual identity. 
*   Each data steward should maintain a data inventory that includes defined sensitivity of data, restrictions on storage and data flows, and contracted data services responsible for enforcing these restrictions. 
*   Each data steward should monitor data usage to detect attempts to access or use data other than as authorized, including attempts to analytically derive identity. 
*   Each data steward and data service providers should implement mechanisms to prevent the identity of individuals from being leaked through covert means such as metadata, URLs, message headers, and inference attacks. 
*   Each data steward and data service providers should implement safeguards to reduce the likelihood that de-identified, pseudonymized, or anonymised data can be re-identified through the query results or data record linkage.  The use of privacy-preserving record linkage methods are encouraged [13]. 
*   Each data steward is responsible for obtaining the individual authorisations (e.g., consents) required by applicable law and institutional policy, and for conveying these authorisations, or a link to these authorisations, along with the associated data. 
*   The User Managed Access (UMA) profile [14] of the OAuth 2.0 [11] authorization protocol may be useful in mediating access based on user permissions. 
*   Each data steward is responsible for updating provenance and confidentiality metadata associated with the data under its control, preferably using HL7 FHIR provenance[15] and confidentiality[16] codes. 

<a name="audit-logs"></a>**3.4 Audit Logs**



*   Each service provider is responsible for recording and maintaining a log of security- relevant events involving access to or use of application and data services under that provider's control. 
*   For each security-relevant event, the service provider should record the following data elements:  user identity, type of event, date and time, success or failure indication, origination of event, name of affected data, system component, or resource.[17] 
*   Each service provider should retain the audit log history for at least one year, with a minimum of three months immediately available for analysis (for example, online, archived, or restorable from back-up). [17] This best practice should be interpreted within the constraints of applicable law. 
*   Each service provider is responsible for monitoring activity on systems and networks under its control to detect potential security breaches and data misuse. 
*   Service providers' audit log records should be integratable with existing enterprise security monitoring tools. 
*   Data stewards and their service providers are jointly responsible for implementing the capability to generate an accounting of accesses to and disclosures of data that may be associated with the individual's identity. 

<a name="data-integrity"></a>    **3.5 Data Integrity**

*   Each service provider is responsible for protecting the integrity of genomic and health- related data that it holds, uses, or transmits. 
*   Each service provider that transmits or receives transmissions containing genomic or health-related data will generate a IETF SHA-2 hash function [18] to verify the integrity of the transmission. 
*   Each service provider who distributes software will assure that it is free from malicious code prior to making it available for distribution. 
*   Each data steward is responsible for ensuring the accuracy and verifiability of data and associated metadata. 
*   Each data steward is responsible for assuring that data provenance information is associated with data made available to service consumers. 

<a name="non-repudiation"></a>    **3.6 Non-repudiation**


● Each service provider will have the capability to digitally sign content using a qualified electronic signature, as defined in Regulation (EU) No 910/2014 of the European Parliament and of the Council of 23 July 2014 on electronic identification and trust services for electronic transactions in the internal market and repealing Directive 1999/93/EC. [8]. 

● GA4GH participants who offer downloadable software will digitally sign the downloadable files using a qualified electronic signature, as defined in Regulation (EU) No 910/2014 of the European Parliament and of the Council of 23 July 2014 on electronic identification and trust services for electronic transactions in the internal market and repealing Directive 1999/93/EC.  [8]. 

<a name="cryptographic-controls"></a>**3.7 Cryptographic Controls**



*   Each stakeholder will assure that any cryptographic controls used are compliant with all applicable standards, agreements, laws, and regulations. 
*   Each stakeholder that stores genomic or health-related data will use strong encryption to encrypt the data for storage. 
*   Each stakeholder will assure that plaintext data encryption keys are stored outside the system in which data encrypted with those keys are persisted. When a key hierarchy is used, plaintext key encryption keys should be stored separately from the system storing data encryption keys. 
*   Each service provider will use end-to-end transport-level encryption (see section 4.9) to encrypt and integrity-protect data during transmission. 
*   Service providers are encouraged to use privacy-preserving encryption methods (e.g., homomorphic encryption, multi-party computation) when applicable and practical.  

<a name="communications-security"></a>    **3.8 Communications Security**

*   Each service provider will assure that communication channels are secured commensurate with the level of risk associated with the content being transmitted. 
*   Each service provider that transmits unencrypted genomic or health-related data will protect the transport using either the IPsec [19, 20] or Transport Layer Security (TLS) protocol [21]. 
*   Any electronic mail containing genomic, health-related, or other sensitive data will be secured using S/MIME Version 2 [22, 23]. 

<a name="operational-assurance"></a>    **4. Operational Assurance \
<a name="physical-and-environmental-security"></a>4.1 Physical and Environmental Security**

*   Each stakeholder who stores or processes genomic or health-related data is responsible for providing physical and environmental safeguards to protect those data in accordance with applicable laws and regulations, institutional policies, and individual consents. 
*   Each stakeholder who uses a third party to store or process genomic or health-related data is responsible for assuring that business agreements include an obligation to provide physical and environmental data protection. 

<a name="operations-security"></a>**4.2 Operations Security**



*   Each data service provider is responsible for assuring that data are transmitted, persisted, and protected in compliance with all applicable legal and ethical requirements. 
*   At the request of an individual whose data are being stored and shared within the GA4GH community, the responsible data steward should provide the individual information about how and by whom their data are being accessed and used and for what purposes. 
*   Each data steward will document the privacy and security practices and procedures it uses to make its data and services available within the GA4GH community, consistent with the _GA4GH Privacy and Security Policy_, and will assure that its service providers make this documentation conveniently available to service consumers and to individuals who contribute their data. 
*   Each data steward will document the behavioral standards associated with use of the data and services made available to service consumers, consistent with GA4GH _Privacy and Security Policy_, and will require service consumers to attest to their understanding of, and commitment to adhere to these standards. 
*   Each service provider will implement privacy and security technology to support adherence to the Fair Information Practices Principles, as articulated in Part Two of the Organisation for Economic Co-operation and Development (OECD) _Guidelines on the Protection of Privacy and Transborder Flows of Personal Data_[24]. 
*   Each service provider will document and enforce written operational procedures for protecting the confidentiality and integrity of data, the availability of services, and the privacy of individuals who contribute their personal data. 

<a name="service-supplier-assurances"></a>    **4.3 Service Supplier Assurances**


Entities that provide data and application services within the GA4GH ecosystem are encouraged to implement defense-in-depth architectural assurances that their services can be relied upon to perform their functions as advertised, while resisting malicious attack, adapting to changes, continuing to operate through unanticipated disruptions, and recovering from interruptions and outages. Architectural safeguards include design principles that contribute to the trustworthiness of end-user devices, servers, and networks, including but not limited to ability of a system or network to protect the confidentiality and integrity of genomic and health-related data, the availability of data and services, and the privacy of individuals whose data are shared. 

All data, application, and infrastructure service providers to the GA4GH community are responsible for implementing appropriate defense-in-depth architectural assurances that will enable them to provide a high level of service expectations, including: 



*   Availability – the ability of the service to perform its functions over a specified period of time, generally expressed as the proportion of time that a service is actually available within an agreed-upon time period. Availability is assured through architectural and design features, and operational procedures that enhance reliability, maintainability, serviceability, resiliency, and security safeguards. 
*   Scalability (or elasticity) – genomic and health-related data stores should be capable of expanding as the volume of data continues to grow, while protecting the confidentiality, integrity, and availability of data and application services. 
*   Infrastructure security – security features and processes provided as part of the data or application service offering GA4GH service providers and user organizations should assure that their networks, operating systems, applications, and database management systems isolate software processes and datasets to prevent interference and side-channel attacks. A "least privileges" approach should be used to harden execution environments. 
*   Data stewards should assure that their service suppliers offer the levels of availability, scalability, and infrastructure security necessary to protect the data entrusted to them. Similarly, service consumers should assure that data and application services and platforms, including their own personal devices, are trustworthy. 

<a name="information-security-oversight-and-accountability"></a>    **4.4 Information Security Oversight and Accountability**

*   Each GA4GH team that proposes a standards work product will complete an initial security risk-assessment at the start of product development.  Prerequisite to approval as a GA4GH standard, the product will undergo a security evaluation that will include a final security risk assessment review and assurance testing, as appropriate.     
*   Each stakeholder will have documented procedures for monitoring system activities, detecting potential threats, and responding to potential security incidents. 
*   Each service provider is strongly encouraged to engage an independent third party to conduct penetration testing of its service infrastructure at least annually.  Any necessary remediation activities should be conducted as quickly as possible, and subjected to both functional and assurance testing.    
*   Each stakeholder will investigate and resolve security incidents, breaches, and reported threats as quickly as possible so as to minimize potential damage to individuals, data loss, disruption of data and application services. 
*   Each stakeholder will report to applicable regulatory authorities any breaches resulting in the potential disclosure of unencrypted genomic or health-related data.   
*   Each stakeholder will report to GA4GH any breaches associated with the use of GA4GH standards and breaches that could damage the reputation and trustworthiness of the GA4GH community.  
*   Each stakeholder will report to GA4GH any potential vulnerability associated with the use of one or more GA4GH standards.   
*   Each service provider who experiences or suspects a data breach involving the disclosure of potentially identifiable data is responsible for expeditiously reporting the breach to the data steward responsible for the breached data. 
*   Each service consumer who experiences or suspects a data breach involving the disclosure of potentially identifiable data is responsible for expeditiously reporting the breach to the relevant institutional supervisory authority and to the data steward. 
*   Each data steward who experiences, suspects, or receives a report of a data breach involving the disclosure of potentially identifiable data is responsible for expeditiously reporting the breach to the individuals whose data were breached. 
*   Each data steward should work with its service providers to assess risks associated with the storage, use, and transmission of genomic and health-related data, and should contractually require appropriate technical mechanisms and procedures for preventing, detecting, and recovering from data breaches, consistent with the assessed risks. 

<a name="compliance"></a>**4.5 Compliance**



*   Each stakeholder is individually responsible for implementing protections consistent with this infrastructure, and for assuring that contracts with third parties address the business partners' obligations to implement such protections. 
*   Each stakeholder will implement appropriate security procedures to ensure compliance with applicable legislative, regulatory, and contractual requirements relating to the use of genomic or health-related data, and personal information. 
*   Each stakeholder will implement appropriate security procedures to ensure compliance with applicable legislative, regulatory, and contractual requirements relating to intellectual property rights. 
*   Each stakeholder is responsible for implementing, and attesting to having implemented, security and privacy processes, procedures, and technology to enforce compliance with relevant legislation, regulations, contractual clauses, and the _GA4GH Privacy and Security Policy._ 
*   GA4GH stakeholders may individually or collectively engage third parties to assess compliance with the GA4GH _Security Technology Infrastructure_, and to evaluate the effectiveness of implemented protections. 

<a name="definitions"></a>    **5. Definitions**




<table>
  <tr>
   <td><strong>Term </strong>
   </td>
   <td><strong>Definition </strong>
<p>


   </td>
  </tr>
  <tr>
   <td>Access control 
   </td>
   <td>Services that assure that users and entities are able to access all of and only the resources (e.g., computers, networks, applications, services, data sets, information) for which they are authorized, and only within the constraints of the authorization. 
   </td>
  </tr>
  <tr>
   <td>Audit controls 
   </td>
   <td>The collection and recording of information about security-relevant events within a system. 
   </td>
  </tr>
  <tr>
   <td>Authentication  (User or Service) 
   </td>
   <td>Presentation of credentials as proof of the identity asserted by a User attempting to access a Service, or by an Entity a User is attempting to access . (See "identity management") 
   </td>
  </tr>
  <tr>
   <td>Authorization
   </td>
   <td>Process of assigning permissions to human users and software clients
   </td>
  </tr>
  <tr>
   <td>Availability 
   </td>
   <td>State of a system or network in which it is functioning such that its services and data are available and usable. 
   </td>
  </tr>
  <tr>
   <td>Data integrity 
   </td>
   <td>Measures to prevent and detect the unauthorized modification and destruction of electronic data during storage and transmission. 
   </td>
  </tr>
  <tr>
   <td>Encryption 
   </td>
   <td>The process of obfuscating information by running the data representing that information through an algorithm (sometimes called a "cipher") to make it unreadable until the data are decrypted by someone possessing the proper decryption "key." Encryption is used for multiple purposes, including the protection of confidential data (at rest and in motion), assurance of data integrity, authentication of identity, and non-repudiation (digital signature). 
   </td>
  </tr>
  <tr>
   <td>Identity federation 
   </td>
   <td>A usability feature that enables single-sign-on functionality across multiple nodes governed under different identity management systems; identity federation is accomplished through agreement among multiple enterprises to accept authenticated identities passed among them as "security claims." 
   </td>
  </tr>
  <tr>
   <td>Identity management 
   </td>
   <td>The total set of administrative functions involved in positively identifying individuals prior to defining them as a known user of a system or service (i.e., "identity proofing"); issuing access credentials to that identity (e.g., user name and password or other personal identity verification); authorizing and assigning rights and privileges to that identity; and revoking access and privileges when they are no longer needed. 
   </td>
  </tr>
  <tr>
   <td>Interoperability 
   </td>
   <td>Ability of systems and services to work together in a consistent and predictable way. 
   </td>
  </tr>
  <tr>
   <td>Malicious-software protection 
   </td>
   <td>Methods to prevent, detect, and remove malicious software ("malware"), which includes any software designed to infiltrate a system without authorization, with the intent to damage or disrupt operations, or to use resources to which a threat is not authorized access. 
   </td>
  </tr>
  <tr>
   <td>Non-repudiation 
   </td>
   <td>Assurance that an actor is unable to deny having taken an action; typically, assurance that a person involved in an electronic communication cannot deny the authenticity of his or her digital signature on a transmitted message or document. 
   </td>
  </tr>
  <tr>
   <td>Privacy risk 
   </td>
   <td>Probability that genomic or health-related data will be collected, used, or disclosed in ways that are unknown to or unauthorized by the individual to whom the data pertain. 
   </td>
  </tr>
  <tr>
   <td>Process Isolation 
   </td>
   <td>The extent to which processes running on the same system at different trust levels, virtual machines (VMs) running on the same hardware, or applications running on the same computer or tablet are kept separate. 
   </td>
  </tr>
  <tr>
   <td>Reliability 
   </td>
   <td>Ability of a system, component, or network to perform its specified functions consistently, over a specified period of time 
   </td>
  </tr>
  <tr>
   <td>Safety 
   </td>
   <td>Property of systems and components that enables them to operate without harming humans or valued resources; else to fail in such a way that no humans or resources are harmed as a result. 
   </td>
  </tr>
  <tr>
   <td>Scalability 
   </td>
   <td>Ability of a system, network, or process to handle a growing amount of work in a capable manner, or its ability to be enlarged to accommodate that growth. 
   </td>
  </tr>
  <tr>
   <td>Security risk 
   </td>
   <td>Probability that a threat will exploit a vulnerability to expose confidential information, corrupt or destroy data, or interrupt or deny essential information services. 
   </td>
  </tr>
  <tr>
   <td>Simplicity 
   </td>
   <td>Property of a system or network in which complexity is minimized. 
   </td>
  </tr>
  <tr>
   <td>Single sign-on 
   </td>
   <td>A usability feature that enables a user to authenticate herself once and then access multiple applications, databases, or systems for which she is authorized, without having to re-authenticate herself. 
   </td>
  </tr>
  <tr>
   <td>Transmission security 
   </td>
   <td>Protection of electronic data against unauthorized disclosure and modification while the data are being transmitted over a vulnerable network, such as the Internet. 
   </td>
  </tr>
  <tr>
   <td>User
   </td>
   <td>Human user or software client that accesses data and application services that use GA4GH standards.  
   </td>
  </tr>
</table>


<a name="references"></a>**6. References**

[1] Global Alliance for Genomics and Health. _Privacy and Security Policy._ 26 May 2015. Available from https://www.ga4gh.org/wp-content/uploads/Privacy-and-Security-Policy.pdf (accessed 6 Oct 2018). 

 [2] Global Alliance for Genomics and Health. _Framework for Responsible Sharing of Genomic and Health-Related Data_. 10 September 2014. Available from https://www.ga4gh.org/genomic-data-toolkit/regulatory-ethics-toolkit/framework-for-responsible-sharing-of-genomic-and-health-related-data/ (accessed 6 Oct 2018). 

 [3] International Organisation for Standardisation/International Electrotechnical Commission.   ISO/IEC 27001:2013.  _Information technology – Security techniques – Information security management systems – Requirements._ 2013.  Available from [https://www.iso.org/standard/54534.html](https://www.iso.org/standard/54534.html) (accessed 6 Oct 2018).  

[4] U.S. National Institute of Standards and Technology.  NIST Special Publication 800-53 Rev 4.  Security and privacy controls for federal information systems.  June 2017.  Available from [https://csrc.nist.gov/publications/detail/sp/800-53/rev-4/final](https://csrc.nist.gov/publications/detail/sp/800-53/rev-4/final) (accessed 6 Oct 2018).  

[5] From March 2014 meeting of Global Alliance Security Working Group. 

[6] International Organisation for Standardisation.  ISO/IEC 7498-1: 1994.  Information technology – Open Systems Interconnection – Basic Reference Model:  The Basic Model.  Confirmed in 2000.  Available from [https://www.iso.org/standard/20269.html](https://www.iso.org/standard/20269.html) (accessed 05 Oct 2018).    

[7] McGuiness, T.  Defense in depth.  SANS Institute.  Nov 11, 2001.  Available from [https://www.sans.org/reading-room/whitepapers/basics/defense-in-depth-525](https://www.sans.org/reading-room/whitepapers/basics/defense-in-depth-525) (accessed 06 Oct 2018).

[8] European Commission.  Regulation (EU) No 910/2014 of the European Parliament and of the Council of 23 July 2014 on electronic identification and trust services for electronic transactions in the internal market and repealing Directive 1999/93/EC.  Available from [https://eur-lex.europa.eu/legal-content/EN/TXT/?uri=uriserv%3AOJ.L_.2014.257.01.0073.01.ENG](https://eur-lex.europa.eu/legal-content/EN/TXT/?uri=uriserv%3AOJ.L_.2014.257.01.0073.01.ENG) (accessed 6 Oct 2018).

 

[9] Grassi, P, ME Garcia, and JL Fenton.   NIST Special Publication 800-63, Revision 3:  Digital identity guidelines. US National Institute of Science and Technology.  June 2017.  DOI: 10.6028/NIST.SP.800-63-3.  Available from https://pages.nist.gov/800-63-3/sp800-63-3.html (accessed 6 Oct 2018). 

[10] OpenID Connect. Available from http://openid.net/connect/ (Accessed 06 Oct 2018). 

[11] Internet Engineering Task Force.  RFC 6749.  The OAuth 2.0. Authorization Framework Available from [https://tools.ietf.org/html/rfc6749](https://tools.ietf.org/html/rfc6749) (accessed 06 Oct 2018).  

[12] UK National Institute of Health Research. The research passport and streamlined human resources arrangements. Available from https://www.nihr.ac.uk/about-us/CCF/policy-and-standards/research-passports.htm (Accessed 06 Oct 2018).

[13]  Vatsalan, D, Christen, P, and Verykios, V S.  A taxonomy of privacy-preserving record linkage techniques.  _Information Systems_.  38:6:946-969.  Sept 2013.  Available from [https://doi.org/10.1016/j.is.2012.11.005](https://doi.org/10.1016/j.is.2012.11.005) (accessed 6 Oct 2018).  

[14] Hardjona, T, Ed. User Managed Access (UMA) profile of OAuth 2.0. Kantara Initiative. 28 Dec 2015. Available from http://docs.kantarainitiative.org/uma/draft-uma-core.html (Accessed 06 Oct 2018). 

[15] Health Level Seven. Resource provenance – Content. Available from http://www.hl7.org/implement/standards/fhir/provenance.html (Accessed 06 Oct 2018). 

[16] Health Level Seven. HL7 v3 Code System Confidentiality. Available from http://hl7.org/implement/standards/fhir/v3/Confidentiality/ (Accessed 06 Oct 2018). 

[17] Payment Card Industry Security Standards Council.   Framework for a robust payment card security process.  Available from [https://www.pcisecuritystandards.org/document_library?category=pcidss&document=pci_dss](https://www.pcisecuritystandards.org/document_library?category=pcidss&document=pci_dss) (accessed 06 Oct 2018).

[18] Internet Engineering Task Force. IETF Request for Comment (RFC) 6668. SHA-2 data integrity verification for the secure shell (SSH) transport layer protocol. Available from http://tools.ietf.org/html/rfc6668 (Accessed 06 Oct 2018). 

 [19] Internet Engineering Task Force. Security architecture for the internet protocol. RFC 4301. December 2005. Available from http://tools.ietf.org/html/rfc4301 (Accessed 06 Oct 2018). 

[20] Internet Engineering Task Force. Using advanced encryption standard (AES) CCM mode with IPsec encapsulating security payload (ESP). RFC 4309. December 2005. Available from http://tools.ietf.org/html/rfc4309 (Accessed 06 Oct 2018). 

[21] Internet Engineering Task Force. The transport layer security protocol, Version 1.2. RFC 5246. August 2008. Available from http://tools.ietf.org/html/rfc5246 (Accessed 06 Oct 2018). 

[22] Internet Engineering Task Force. S/MIME Version 2 message specification. RFC 2311. March 1998. Available from http://tools.ietf.org/html/rfc2311 (Accessed 06 Oct 2018). 

[23] Internet Engineering Task Force. S/MIME Version 2 certificate handling. RFC 2312. Available from http://www.ietf.org/rfc/rfc2312.txt (Accessed 06 Oct 2018). 

[24] Organisation for Economic Development and Cooperation. OECD Guidelines on the protection of privacy and transborder flows of personal data. 11 July 2013. pp. 14-15. Available from [http://www.oecd.org/sti/ieconomy/2013-oecd-privacy-guidelines.pdf (06](http://www.oecd.org/sti/ieconomy/2013-oecd-privacy-guidelines.pdf (06) Oct 2018). 

[25] European Union.  General Data Protection Regulation.  Available from [https://eur-lex.europa.eu/eli/reg/2016/679/oj](https://eur-lex.europa.eu/eli/reg/2016/679/oj) (Accessed 16 Jan 2019).

