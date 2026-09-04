# Enterprise Supplier SLA & Penalty Settlement Engine

[![SAP BTP](https://img.shields.io/badge/SAP%20BTP-ABAP%20Environment-0A85EA?logo=sap)](https://www.sap.com/products/technology-platform.html)
[![ABAP Cloud](https://img.shields.io/badge/ABAP-Cloud%20RAP-blue)](https://www.sap.com)
[![OData](https://img.shields.io/badge/OData-V4-orange)](https://www.odata.org/)
[![UI5 / Fiori](https://img.shields.io/badge/UI-SAP%20Fiori%20Elements-0070F2)](https://ui5.sap.com/)

An enterprise-grade, side-by-side Clean Core extension built on **SAP BTP ABAP Environment** using **ABAP Cloud** and the **ABAP RESTful Application Programming Model (RAP)**.

---

## 📌 Business Overview

In global procurement and supply chain management, late delivery of Purchase Orders can incur liquidated damages and service-level agreement (SLA) penalties. Traditional ERP implementations may rely on manual calculations, fragmented spreadsheets, or invasive modifications to standard S/4HANA core tables.

This application provides:

- **Real-Time Settlement:** Automatically evaluates delay intervals and calculates financial penalties.
- **Clean Core Extensibility:** Keeps custom dispute and settlement logic decoupled from standard procurement core processes.
- **Auditable State Transitions:** Provides a controlled governance flow for reviewing, approving, or waiving penalties.

---

## 🏗️ Technical Architecture

The application follows the RAP Managed Draft runtime model with OData V4 exposure.

```text
┌─────────────────────────────────────────────────────────────┐
│               SAP Fiori Elements (Horizon UI)               │
│            List Report & Object Page (OData V4)             │
└──────────────────────────────┬──────────────────────────────┘
                               │
                               │ OData V4 Metadata & Batch Requests
                               │
┌──────────────────────────────▼──────────────────────────────┐
│                    Service Exposure Layer                   │
│   • Service Definition:  ZUI_SUPPLIER_SLA                   │
│   • Service Binding:     ZSB_SUPPLIER_SLA (OData V4 - UI)   │
└──────────────────────────────┬──────────────────────────────┘
                               │
┌──────────────────────────────▼──────────────────────────────┐
│                  CDS Consumption / Projection               │
│   • Projection View:     ZC_SUPPLIER_SLA                    │
│   • Metadata Extension:  ZME_SUPPLIER_SLA                   │
│   • Projection BDEF:     ZC_SUPPLIER_SLA                    │
└──────────────────────────────┬──────────────────────────────┘
                               │
┌──────────────────────────────▼──────────────────────────────┐
│                   RAP Business Object Layer                 │
│   • Interface View:      ZI_SUPPLIER_SLA                    │
│   • Behavior Definition: ZI_SUPPLIER_SLA (Managed + Draft)  │
│   • Behavior Pool:       ZBP_I_SUPPLIER_SLA                 │
│       ├─ Determination: calculatePenalty                    │
│       ├─ Validation:    validateDates                       │
│       └─ Actions:       approvePenalty, waivePenalty        │
└──────────────────────────────┬──────────────────────────────┘
                               │
┌──────────────────────────────▼──────────────────────────────┐
│                     Persistence Layer                       │
│   • Active Table:        ZSLARECORD                         │
│   • Draft Table:         ZSLARECORD_D                       │
│   • UUID Keys & Administrative Draft Fields                 │
└─────────────────────────────────────────────────────────────┘
```

---

## ⚙️ Core Technical Features

### 1. RAP Managed Implementation with Draft Persistency

- Uses RAP managed behavior with draft support.
- Draft records are persisted in `ZSLARECORD_D`.
- Supports draft editing, validations before activation, and RAP-managed draft lifecycle handling.

### 2. Business Logic & Determinations

The `calculatePenalty` determination evaluates delivery delay and calculates the applicable penalty.

```text
Delay Days = max(0, Actual Delivery - Expected Delivery)

Penalty Amount = Delay Days × Penalty Rate
```

The determination can be triggered when relevant fields such as:

- `ExpectedDelivery`
- `ActualDelivery`
- `PenaltyRate`

are modified.

### 3. Business Integrity Validations

The `validateDates` validation runs during save processing to verify delivery-date consistency and reports validation messages back to the RAP UI using the appropriate RAP message and key bindings.

### 4. Custom RAP Actions

| Action | Purpose |
|---|---|
| `approvePenalty` | Sets the penalty record to an approved state after authorized review. |
| `waivePenalty` | Waives the penalty and resets the penalty amount according to the business rule. |

### 5. UI/UX Annotations & Metadata Extensions

UI metadata is separated from the core CDS data model through the metadata extension `ZME_SUPPLIER_SLA`.

The application supports:

- List Report
- Object Page
- Search capabilities
- Header and identification facets
- Custom RAP actions
- Fiori Elements OData V4 exposure

---

## 📂 Repository Artifacts

| Component | Object Name | Type | Description |
| :--- | :--- | :--- | :--- |
| **Data Definition** | `ZI_SUPPLIER_SLA` | CDS Interface | Transactional base CDS entity |
| **Data Definition** | `ZC_SUPPLIER_SLA` | CDS Projection | Consumption/projection CDS entity |
| **Metadata Extension** | `ZME_SUPPLIER_SLA` | DDLX | UI annotations, actions, and facet hierarchy |
| **Behavior Definition** | `ZI_SUPPLIER_SLA` | BDEF | Managed behavior definition with draft and business rules |
| **Behavior Definition** | `ZC_SUPPLIER_SLA` | BDEF | Projection behavior definition |
| **Behavior Pool** | `ZBP_I_SUPPLIER_SLA` | CLAS / CCIMP | ABAP implementation of determinations, validations, and actions |
| **Active Table** | `ZSLARECORD` | TABL | Active persistence table |
| **Draft Table** | `ZSLARECORD_D` | TABL | Draft persistence table |
| **Service Definition** | `ZUI_SUPPLIER_SLA` | SRVD | Service definition exposing projection entities |
| **Service Binding** | `ZSB_SUPPLIER_SLA` | SRVB | OData V4 UI service binding |

---

## 🚀 Deployment & Installation

### Prerequisites

- SAP BTP ABAP Environment or a compatible SAP S/4HANA ABAP environment supporting RAP.
- ABAP Development Tools (ADT) in Eclipse.
- abapGit for Eclipse.

### Import Steps

1. Open **Eclipse ADT**.
2. Open the **abapGit Repositories** view.
3. Click **Link abapGit Repository**.
4. Clone the repository:

   ```text
   https://github.com/sravansai-26/sap-btp-supplier-sla-engine.git
   ```

5. Assign the repository to package:

   ```text
   ZSUPPLIER_SLA
   ```

6. Pull/import all repository objects.
7. Activate the imported artifacts in ADT.
8. Open the service binding:

   ```text
   ZSB_SUPPLIER_SLA
   ```

9. Publish the OData V4 service binding.
10. Use the service binding preview to launch the generated Fiori Elements application.

---

## 🧩 Business Process Flow

```text
Create SLA Record
       │
       ▼
Enter Expected Delivery
       │
       ▼
Enter Actual Delivery
       │
       ▼
RAP Determination Calculates Delay
       │
       ▼
Penalty Amount Calculated
       │
       ▼
Pending Review
       │
       ├──────────────► Approve Penalty
       │                       │
       │                       ▼
       │                   Approved
       │
       └──────────────► Waive Penalty
                               │
                               ▼
                            Waived
```

---

## 🔐 Clean Core Principles

This solution is designed as a side-by-side extension approach and aims to follow Clean Core principles by:

- Avoiding modifications to SAP standard objects.
- Keeping custom business logic within the RAP business object.
- Exposing functionality through standard OData V4 services.
- Using released ABAP Cloud-compatible APIs and development patterns where required.
- Separating persistence, business behavior, service exposure, and UI metadata.

---

## 🛠️ Technology Stack

- **SAP BTP ABAP Environment**
- **ABAP Cloud**
- **ABAP RESTful Application Programming Model (RAP)**
- **Core Data Services (CDS)**
- **Managed RAP Behavior**
- **Draft Enablement**
- **OData V4**
- **SAP Fiori Elements**
- **SAP HANA Persistence**
- **abapGit**

---

## 📖 Project Structure

```text
sap-btp-supplier-sla-engine/
│
├── src/
│   ├── cds/
│   │   ├── ZI_SUPPLIER_SLA
│   │   ├── ZC_SUPPLIER_SLA
│   │   └── ZME_SUPPLIER_SLA
│   │
│   ├── behavior/
│   │   ├── ZI_SUPPLIER_SLA.bdef
│   │   └── ZC_SUPPLIER_SLA.bdef
│   │
│   ├── classes/
│   │   └── ZBP_I_SUPPLIER_SLA
│   │
│   ├── tables/
│   │   ├── ZSLARECORD
│   │   └── ZSLARECORD_D
│   │
│   └── service/
│       ├── ZUI_SUPPLIER_SLA
│       └── ZSB_SUPPLIER_SLA
│
└── README.md
```

---

## 🎯 Key Learning Areas Demonstrated

This project demonstrates practical knowledge of:

- RAP Managed Business Objects
- RAP Draft Enablement
- CDS Interface and Projection Views
- Metadata Extensions
- Determinations and Validations
- RAP Actions
- Behavior Definitions and Behavior Pools
- OData V4 Service Exposure
- SAP Fiori Elements Integration
- ABAP Cloud Development Principles
- Clean Core Extensibility

---

## 📄 License

This project is intended for learning, demonstration, and portfolio purposes.

---

## 👨‍💻 Author

**Sravan Sai Vuppula**

**Official Portfolio:** [buildwithsravan.dev](https://buildwithsravan.dev)

SAP BTP ABAP | ABAP Cloud | RAP | SAP Fiori Elements
