# GitHub as a Service: Internal Service Offering

Nov 10, 2026 · @David

## Executive summary

We will offer GitHub to every department as a single, priced service with three hosting choices and one simple bill: a per-developer monthly seat, plus optional add-ons billed on what is used. Rates are set at fully loaded cost plus a 10–15% margin that funds a reserve, upgrades and growth, so the service recovers its costs every year.

What departments get:

- **One catalog, three platforms**: GitHub Enterprise Cloud (default), GitHub Enterprise Server in our Azure tenant, and GitHub Enterprise Server on-premises for regulated or air-gapped work.
- **Flexible buying**: monthly pay-as-you-go, or 1- and 3-year commitments at a discount; seats can be added any day and reduced at quarterly true-up.
- **No license math**: a GitHub Enterprise seat covers a person on Cloud and Server alike, so a developer who works on two platforms pays once.

What our department gets: predictable funding, a clear line between what we run and what customers own, and rates reviewed every year against actual cost.

## Service catalog

GitHub Enterprise Cloud is the default; departments choose a Server option only when data residency, network isolation or regulation requires it. Every option is the same GitHub, so moving between them later is a migration, not a re-platform.

| Platform | Choose it when | Where data lives | What we operate | Relative cost to us |
| --- | --- | --- | --- | --- |
| **GitHub Enterprise Cloud (GHEC)** — default | Standard development, open collaboration, newest features (Copilot, Codespaces, hosted runners) | GitHub-hosted SaaS (data-residency region if we buy it) | Enterprise account, SSO/SCIM, policies, org provisioning | Lowest: no servers, upgrades or backups |
| **GHES in our Azure tenant** | Code must stay in our tenant or reach private Azure networks; moderate compliance | Our Azure subscription | VMs, storage, backups, HA replica, upgrades, monitoring, runners | Medium: Azure compute + storage + ops time |
| **GHES on-premises** | Air-gapped, export-controlled or regulated data; latency to on-prem systems | Our data center | Hardware, hypervisor, backups, HA/DR, upgrades, runners, physical security | Highest: hardware refresh + facility + most ops time |

Notes for customers:

- One GitHub Enterprise seat covers a person on Cloud and Server. When license sync is on, a developer on two platforms is counted once.
- GHES lags Cloud on new features by several releases, and some features (such as Codespaces) are Cloud only.
- Self-hosted runners on any platform run on capacity we bill as an add-on (see Pricing).

## Service tiers

Every seat includes the Standard tier; departments that need faster response or hands-on help pay a per-seat uplift. Keeping it to three tiers makes ordering a two-question choice: which platform, which tier.

|  | Standard (included) | Plus (+15% of seat rate) | Premium (+35% of seat rate) |
| --- | --- | --- | --- |
| Support hours | Business hours, ticket | Business hours, ticket + chat | 24×7 for Sev 1, named contact |
| Sev 1 first response | 4 business hours | 2 hours | 30 minutes |
| Org setup | Self-service template | Assisted setup, 1 session | Custom setup, policies, rulesets |
| Migration help | Docs + GitHub Enterprise Importer | Up to 25 repos migrated for you | Migration plan + full migration (quoted) |
| Training | Self-paced library | 1 live session per year | Quarterly enablement + office hours |
| Reporting | Monthly usage statement | + Security and adoption dashboard | + Quarterly service review |

Optional add-ons, any tier:

- **GitHub Advanced Security**: Secret Protection and Code Security, per active committer.
- **GitHub Copilot**: Business or Enterprise, per assigned user.
- **CI capacity**: hosted Actions minutes and storage (Cloud), or dedicated self-hosted runner pools (any platform).
- **Professional services**: hourly, for migrations, custom integrations and audit evidence.

## Pricing and chargeback

Each platform has one all-in monthly seat rate built from five cost layers plus a 12% margin; illustrative rates are $29 (Cloud), $39 (Azure) and $45 (on-prem) per developer per month. Replace the placeholder figures below with our Enterprise Agreement price and last year's actual costs before publishing rates.

```latex
\text{Seat rate} = \left( L + \frac{I + O + S}{N} \right) \times (1 + m)
```

L = license cost per seat; I, O, S = monthly infrastructure, operations labor and service  overhead for that platform; N = forecast billable seats; m = margin (12%).

### Cost build-up per seat per month (illustrative, USD)

| Cost layer | GHEC | GHES in Azure | GHES on-prem | How to source it |
| --- | --- | --- | --- | --- |
| GitHub Enterprise license | 21.00 | 21.00 | 21.00 | EA price (approx. list $21) |
| Infrastructure | 0.00 | 6.00 | 8.00 | Azure invoice; hardware amortized over 5 yrs + DC space, power |
| Operations labor | 3.00 | 6.00 | 9.00 | Admin FTE cost × % time on platform ÷ seats |
| Service overhead | 2.00 | 2.00 | 2.00 | Service desk, tooling, billing admin, training content |
| **Fully loaded cost** | **26.00** | **35.00** | **40.00** |  |
| Margin (12%) | 3.12 | 4.20 | 4.80 | Funds reserve, upgrades, growth |
| **Published seat rate** | **$29** | **$39** | **$45** | Rounded to whole dollars |

### Add-on rates

| Add-on | Unit | Internal rate | Basis |
| --- | --- | --- | --- |
| Secret Protection | Active committer / month | Pass-through + 8% | Approx. list $19 |
| Code Security | Active committer / month | Pass-through + 8% | Approx. list $30 |
| Copilot Business / Enterprise | Assigned user / month | Pass-through + 8% | Approx. list $19 / $39 |
| Hosted Actions minutes, storage, LFS | Actual usage | Pass-through + 8%, billed monthly in arrears | GitHub metered invoice |
| Dedicated self-hosted runner pool | Runner / month | Azure VM cost + ops + 12% | Sized per request (e.g., 4 vCPU Linux) |
| Professional services | Hour | Blended labor rate + 12% | Quoted before work starts |

Rules that protect cost recovery:

- **Platform floor on Server**: GHES options carry fixed costs whatever the seat count, so each Server platform needs a minimum of seats (set N so I + O is covered) or a flat platform fee for small tenants.
- **Metered items are never bundled**: Actions, storage and Copilot usage swing month to month, so they bill at actual usage, not in the seat rate.
- **Pass-through items carry a small fee (8%)** to cover billing, license admin and true-up effort.
- **Billable seat** = any person holding a seat in the billing month, deduplicated across platforms; dormant users (90 days inactive) are reported to the department for removal.

## Flexible purchasing

Departments pick one of three ways to buy, and commitments earn a discount because they let us commit to GitHub at better EA terms. The discount never takes a rate below fully loaded cost.

| Purchase model | Discount off seat rate | Add seats | Reduce seats | Best for |
| --- | --- | --- | --- | --- |
| Pay as you go | 0% | Any day, prorated | Any month-end | Pilots, contractors, seasonal teams |
| 1-year commitment | 5% | Any day, at committed rate | Quarterly true-down up to 10% of committed seats | Most departments |
| 3-year commitment | 10% | Any day, at committed rate | Annual true-down up to 10% | Large, stable engineering groups |

How it works:

- **Trial**: 60 days, up to 25 Cloud seats at no charge, then converts to pay-as-you-go unless cancelled.
- **Quarterly true-up**: we compare assigned seats with the commitment; seats above it bill at the committed rate, so growth is never penalized.
- **Department license pool**: a department buys a pool and its own admins assign seats; unused seats can be lent to another department for a quarter, and the borrower pays.
- **Platform switch credit**: moving from Server to Cloud mid-term carries the remaining commitment over at the new rate, so nobody is locked into a costlier platform.
- **Prepay option**: departments with year-end budget can prepay 12 months; prepaid funds lock that year's rate.
- **Budget alerts**: the department's billing contact gets an alert at 80% and 100% of its monthly metered budget for Actions and Copilot.

## What's included and who owns what

We run the platform and the enterprise guardrails; departments own their organizations, repositories, code and who gets access. R = responsible, A = accountable, C = consulted, I = informed.

| Activity | GitHub Service team | Department | Security / IAM |
| --- | --- | --- | --- |
| Platform availability, upgrades, patching (GHES) | R/A | I | C |
| Backups and disaster recovery (GHES) | R/A | I | I |
| Enterprise policies, SSO, SCIM, audit log streaming | R/A | I | C |
| Organization creation and naming standards | R/A | C | I |
| Org admins, teams, repository permissions | C | R/A | I |
| Seat requests and removals, dormant-user cleanup | C | R/A | I |
| Repository content, branch rules, CODEOWNERS | I | R/A | I |
| Security alerts triage (secret scanning, code scanning) | C | R/A | C |
| Self-hosted runner pools (dedicated) | R/A | C | C |
| Workflows, Actions usage, metered spend | C | R/A | I |
| Access reviews and offboarding | C | R | A |

Not included: writing or reviewing application code, building department pipelines, and third-party Marketplace app licensing (billed at cost if bought through us).

## Service levels

We commit to availability only where we run the platform; for Cloud, we pass through GitHub's own SLA and own the support relationship. Missed targets earn a service credit, which keeps the commitment real without exposing us to open-ended penalties.

| Platform | Monthly availability target | Maintenance window | Recovery point / time (RPO / RTO) |
| --- | --- | --- | --- |
| GHEC | GitHub's published enterprise SLA (99.9%) | Set by GitHub | Set by GitHub |
| GHES in Azure | 99.9% (HA replica in a second zone) | Sundays 02:00–06:00 ET, 5 days' notice | 1 hour / 4 hours |
| GHES on-prem | 99.5% (99.9% with DR site) | Sundays 02:00–06:00 ET, 5 days' notice | 4 hours / 8 hours |

| Severity | Definition | Standard | Plus | Premium |
| --- | --- | --- | --- | --- |
| Sev 1 | Platform down or data at risk | 4 business hrs | 2 hrs | 30 min, 24×7 |
| Sev 2 | Major feature broken, no workaround | 1 business day | 4 business hrs | 2 hrs |
| Sev 3 | Issue with a workaround | 3 business days | 2 business days | 1 business day |
| Sev 4 | Question or request | 5 business days | 3 business days | 2 business days |

- **Service credits**: 5% of that month's seat charge per 0.1% below target, capped at 25%. Credits come from the reserve, not the margin forecast.
- **Upgrades**: GHES stays within two feature releases of the latest, so it stays supported by GitHub.
- **Escalation**: we open and manage GitHub Enterprise Support tickets on the department's behalf.

## Ordering and onboarding

A department goes from request to working organization in 5 business days on Cloud and 10 on Server. Everything starts from one service-catalog form.

1. **Request**: the department submits the catalog form: platform, tier, purchase model, seat count, cost center, billing contact and org admins.
2. **Fit check** (1 day): we confirm the platform choice against data classification; anything above "internal" is reviewed with Security.
3. **Approve**: the department's budget owner approves the quote in the form; this is the chargeback agreement.
4. **Provision** (2–5 days): we create the organization, connect SSO/SCIM groups, apply enterprise policies and rulesets, and enable add-ons.
5. **Hand-off**: a 30-minute kickoff with org admins covers the RACI, the support process and the usage dashboard.
6. **Migrate**: the department moves repositories with GitHub Enterprise Importer, or we do it under Plus, Premium or a services quote.
7. **Bill**: the first charge posts at the next month-end, prorated from the provision date.

Changes after onboarding (seats, tier, add-ons) go through the same form and take effect within 1 business day. Leaving the service requires 30 days' notice; we archive repositories for 90 days before deletion.

## Financial governance

Rates are reviewed once a year, before department budget season, and the margin feeds a capped reserve so surpluses and shortfalls even out without mid-year rate changes.

- **Annual rate review**: recompute each platform's fully loaded cost from actuals and next year's forecast; publish new rates at least 90 days before the fiscal year.
- **Reserve fund**: margin goes to a reserve capped at 3 months of operating cost. Above the cap, the surplus returns to departments as a rate cut or credit, which keeps the margin defensible to Finance.
- **Spend uses of the reserve**: GHES hardware refresh, major upgrades, SLA credits and unplanned GitHub price increases.
- **Under-recovery trigger**: if any platform recovers less than 95% of cost for two quarters, review its seat floor or propose consolidating it to Cloud.
- **Monthly statement**: each department gets seats by platform, add-on usage, metered spend versus budget, and dormant users.

| KPI | Target | Why it matters |
| --- | --- | --- |
| Cost recovery ratio (revenue ÷ fully loaded cost) | 105–115% per platform | Covers costs and funds the reserve |
| Seat utilization (active ÷ billed seats) | ≥ 90% | Dormant seats waste department money |
| Share of seats on GHEC | Rising year over year | Lowest unit cost for everyone |
| Availability (Server platforms) | Meets SLA every month | Customer trust |
| Provisioning time | Cloud ≤ 5 days, Server ≤ 10 | Ease of buying |
| Customer satisfaction | ≥ 4.2 / 5 | Renewal and adoption |

## Open decisions and next steps

- [ ] Replace placeholder license, infrastructure and labor figures with EA pricing and last fiscal year's actuals
- [ ] Confirm with Finance that a 12% margin and a capped reserve are allowed under our chargeback policy
- [ ] Set the minimum seat floor (or flat platform fee) for each GHES platform
- [ ] Decide whether GHEC needs a data-residency (GHE.com) option for any department
- [ ] Confirm with GitHub that license sync is on, so seats are deduplicated across Cloud and Server
- [ ] Build the service-catalog form and monthly statement report
- [ ] Pilot with 2 departments for one quarter, then publish rates

Watch item: GitHub cut hosted-runner prices from January 1, 2026, and postponed a planned $0.002/minute fee for self-hosted runners on Cloud; GHES is not affected. If that fee returns, add it to the self-hosted runner add-on rate ([GitHub](https://github.com/resources/insights/2026-pricing-changes-for-github-actions)).

## Sources

- [Pricing changes for GitHub Actions](https://github.com/resources/insights/2026-pricing-changes-for-github-actions), GitHub
- [GitHub pricing](https://github.com/pricing): license and add-on list prices quoted here are approximate; confirm current figures and our EA rates
