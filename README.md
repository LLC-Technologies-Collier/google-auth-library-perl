# Google Cloud Client Libraries for Perl

This repository is the official monorepo containing first-party Google Cloud client libraries, gRPC transport engines, Protocol Buffer serialization codecs, authentication mechanisms, and code generation tooling for Perl.

It provides complete coverage for Google Cloud's Data Analytics, Security, Networking, Private CA, and Infrastructure suite: **Secure Web Proxy (SWP), Network Security Policies, Private CA (Certificate Authority Service), Cloud SQL, Dataproc Metastore (DPMS), Secret Manager, Cloud Build, IAM, Dataproc, Data Fusion, Dataflow, Pub/Sub, Composer, BigQuery, BigQuery Storage, Spanner, Dataplex, Google Cloud Storage (GCS), and Google Compute Engine (GCE)**.

---

## Architecture & Distribution Overview

The monorepo contains 24 modular CPAN distributions that form the complete end-to-end Google Cloud client stack:

```
┌──────────────────────────────────────────────────────────────────────────┐
│ [Layer 6] Service Client Libraries                                       │
│ • Google-Cloud-NetworkServices-V1  - Secure Web Proxy (SWP) Gateways     │
│ • Google-Cloud-NetworkSecurity-V1  - Gateway Security Policies & Rules   │
│ • Google-Cloud-PrivateCA-V1        - Certificate Authority Service (CAS) │
│ • Google-Cloud-SQL-V1              - Cloud SQL Admin (Hive Metastore DB) │
│ • Google-Cloud-Metastore-V1        - Dataproc Metastore (DPMS)           │
│ • Google-Cloud-SecretManager-V1    - Secret Manager                      │
│ • Google-Cloud-Build-V1            - Cloud Build CI/CD Triggers          │
│ • Google-Cloud-IAM-V1              - Identity & Access Management (IAM) │
│ • Google-Cloud-Compute-V1          - Google Compute Engine (GCE)         │
│ • Google-Cloud-Storage-V2          - Google Cloud Storage (GCS)          │
│ • Google-Cloud-Dataproc-V1         - Cloud Dataproc (Spark / Hadoop)     │
│ • Google-Cloud-PubSub-V1           - Cloud Pub/Sub Messaging             │
│ • Google-Cloud-Composer-V1         - Cloud Composer (Managed Airflow)    │
│ • Google-Cloud-Dataflow-V1Beta3    - Cloud Dataflow (Apache Beam)        │
│ • Google-Cloud-Dataplex-V1         - Cloud Dataplex Data Governance      │
│ • Google-Cloud-DataFusion-V1       - Cloud Data Fusion (ETL Pipelines)   │
│ • Google-Cloud-BigQuery-Storage-V1- Cloud BigQuery Storage API (Arrow)   │
│ • Google-Cloud-Bigquery-V2         - Cloud BigQuery V2 Data Warehouse    │
│ • Google-Cloud-Spanner-V1          - Cloud Spanner Relational Database   │
├──────────────────────────────────────────────────────────────────────────┤
│ [Layer 5] Code Generator Tooling                                         │
│ • Module-Starter-Protobuf          - GAPIC protobuf-starter CLI generator│
├──────────────────────────────────────────────────────────────────────────┤
│ [Layer 4] gRPC Transport Layer                                          │
│ • Google-gRPC                      - Dual-Engine (nghttp2 C/XS + PP)     │
│                                    - ChannelPool DNS Load Balancer       │
├──────────────────────────────────────────────────────────────────────────┤
│ [Layer 3] Google API Common Metadata                                    │
│ • Google-Api-Common                - google.api.* & google.type.* types  │
├──────────────────────────────────────────────────────────────────────────┤
│ [Layer 2] Authentication & Security                                     │
│ • google-auth                      - Google::Auth (ADC, Service Account) │
├──────────────────────────────────────────────────────────────────────────┤
│ [Layer 1] Serialization & Wire Codec                                     │
│ • Protobuf                         - Native C/XS upb engine + WKTs       │
└──────────────────────────────────────────────────────────────────────────┘
```

---

## Monorepo Distributions

| Directory | CPAN Package | Version | Product Pod | Description |
| :--- | :--- | :---: | :--- | :--- |
| **`Protobuf/`** | `Protobuf` | `0.05` | Core Codec | Native C/XS `upb` binary serialization engine and standard Protocol Buffer Well-Known Types (`google.protobuf.*`). |
| **`google-auth/`** | `Google::Auth` | `0.02` | Security | Authentication library supporting Application Default Credentials (ADC), Service Account JSON keyfiles, GCE metadata server, and OAuth2 token caching. |
| **`Google-Api-Common/`** | `Google::Api::Common` | `0.01` | Common Metadata | Common Google API annotations and type descriptors (`google.api.http`, `google.rpc.Status`, `google.type.Date`, etc.). |
| **`Google-gRPC/`** | `Google::gRPC` | `0.02` | Transport | High-performance `nghttp2` C/XS bindings, 100% Pure-Perl fallback (`Protocol::HTTP2`), DNS `getaddrinfo` load balancing, deadlines, exponential backoff retries, and keepalive heartbeats. |
| **`Module-Starter-Protobuf/`** | `Module::Starter::Protobuf` | `0.01` | Tooling | Code generator tooling providing `protobuf-starter` CLI and integration with `protoc-gen-perl-pb`. |
| **`Google-Cloud-NetworkServices-V1/`** | `Google::Cloud::NetworkServices::V1` | `0.01` | Networking | Client library for Secure Web Proxy (SWP) Gateways. |
| **`Google-Cloud-NetworkSecurity-V1/`** | `Google::Cloud::NetworkSecurity::V1` | `0.01` | Security | Client library for Gateway Security Policies and Rules. |
| **`Google-Cloud-PrivateCA-V1/`** | `Google::Cloud::PrivateCA::V1` | `0.01` | Security / PKI | Client library for Certificate Authority Service (Private CA) for Secure Boot & NVIDIA driver signing. |
| **`Google-Cloud-SQL-V1/`** | `Google::Cloud::SQL::V1` | `0.01` | Data Analytics | Client library for Cloud SQL Admin V1 API. |
| **`Google-Cloud-Metastore-V1/`** | `Google::Cloud::Metastore::V1` | `0.01` | Dataproc Pod | Client library for Dataproc Metastore (DPMS) V1 API. |
| **`Google-Cloud-SecretManager-V1/`** | `Google::Cloud::SecretManager::V1` | `0.01` | Security | Client library for Secret Manager V1 API. |
| **`Google-Cloud-Build-V1/`** | `Google::Cloud::Build::V1` | `0.01` | CI/CD | Client library for Cloud Build V1 API. |
| **`Google-Cloud-IAM-V1/`** | `Google::Cloud::IAM::V1` | `0.01` | Security / IAM | Client library for Identity and Access Management (IAM) V1 API. |
| **`Google-Cloud-Compute-V1/`** | `Google::Cloud::Compute::V1` | `0.01` | Compute | Client library for Google Compute Engine (GCE) V1 API. |
| **`Google-Cloud-Storage-V2/`** | `Google::Cloud::Storage::V2` | `0.01` | Storage | Client library for Google Cloud Storage (GCS) V2 API. |
| **`Google-Cloud-Dataproc-V1/`** | `Google::Cloud::Dataproc::V1` | `0.01` | Dataproc Pod | Client library for Cloud Dataproc (GCE & Serverless Spark). |
| **`Google-Cloud-DataFusion-V1/`** | `Google::Cloud::DataFusion::V1` | `0.01` | Dataproc Pod | Client library for Cloud Data Fusion ETL pipelines. |
| **`Google-Cloud-Dataflow-V1Beta3/`** | `Google::Cloud::Dataflow::V1Beta3` | `0.01` | Dataflow Pod | Client library for Cloud Dataflow (Apache Beam). |
| **`Google-Cloud-PubSub-V1/`** | `Google::Cloud::PubSub::V1` | `0.01` | Dataflow Pod | Client library for Cloud Pub/Sub Messaging. |
| **`Google-Cloud-Composer-V1/`** | `Google::Cloud::Composer::V1` | `0.01` | Composer Pod | Client library for Cloud Composer (Managed Apache Airflow). |
| **`Google-Cloud-BigQuery-Storage-V1/`** | `Google::Cloud::BigQuery::Storage::V1` | `0.01` | Data Analytics | Client library for Cloud BigQuery Storage API (high-throughput Arrow read/write). |
| **`Google-Cloud-Bigquery-V2/`** | `Google::Cloud::Bigquery::V2` | `0.01` | Data Analytics | Client library for Cloud BigQuery V2 API. |
| **`Google-Cloud-Spanner-V1/`** | `Google::Cloud::Spanner::V1` | `0.01` | Data Analytics | Client library for Cloud Spanner V1 relational database. |
| **`Google-Cloud-Dataplex-V1/`** | `Google::Cloud::Dataplex::V1` | `0.01` | Data Analytics | Client library for Cloud Dataplex Data Governance. |

---

## Installation & Quickstart

Build and install the distributions in dependency order using `cpanm`:

```bash
# 1. Install Core Infrastructure & Transport Stack
cpanm ./Protobuf
cpanm ./google-auth
cpanm ./Google-Api-Common
cpanm ./Google-gRPC
cpanm ./Module-Starter-Protobuf

# 2. Install Service Clients
cpanm ./Google-Cloud-NetworkServices-V1
cpanm ./Google-Cloud-NetworkSecurity-V1
cpanm ./Google-Cloud-PrivateCA-V1
cpanm ./Google-Cloud-SQL-V1
cpanm ./Google-Cloud-Metastore-V1
cpanm ./Google-Cloud-SecretManager-V1
cpanm ./Google-Cloud-Build-V1
cpanm ./Google-Cloud-IAM-V1
cpanm ./Google-Cloud-Compute-V1
cpanm ./Google-Cloud-Storage-V2
cpanm ./Google-Cloud-Dataproc-V1
cpanm ./Google-Cloud-DataFusion-V1
cpanm ./Google-Cloud-Dataflow-V1Beta3
cpanm ./Google-Cloud-PubSub-V1
cpanm ./Google-Cloud-Composer-V1
cpanm ./Google-Cloud-BigQuery-Storage-V1
cpanm ./Google-Cloud-Bigquery-V2
cpanm ./Google-Cloud-Spanner-V1
cpanm ./Google-Cloud-Dataplex-V1
```

---

## License

Apache License, Version 2.0. See [LICENSE](LICENSE) for details.
