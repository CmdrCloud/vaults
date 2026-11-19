# HANDOFF — Perfil de TFG (UTEPSA) + prototipo InfluxDB/Grafana (DeepBlue)

Written 2026-11-18 for another Claude chat to continue this work with full context. Read all of it before acting. Nothing in this handoff has been committed to git.

---

## 0. TL;DR

The user (Andres Garufalias Alday, student of Ingeniería de Sistemas at UTEPSA, Santa Cruz, Bolivia) is writing his graduation project ("Proyecto de Grado" / TFG) and works on it with two threads:

1. **The Perfil (project profile) of the TFG**: a Word document in Spanish, APA 7, for professor Ing. Walter J. Méndez. Current version is **v5** (uploaded to the user's Google Drive and saved locally). It is the first part of the final graduation document. The topic is a **fault-tolerant data synchronization engine ("motor de sincronización") for an edge-to-cloud pipeline in an IIoT energy-monitoring platform**.
2. **A small InfluxDB + Grafana prototype** (built earlier in the original, forked session) to visualize an example dataset for the confidential industrial project this TFG is based on (referred to in the user's private notes as "DeepBlue"; **its name must never appear in the Perfil because of an NDA**).

The user is **behind schedule**. The Perfil still lacks real test data. The user will get data from Ing. Andres Vega (contact at the collaborating organization) and expects to update the Perfil later.

---

## 1. Who the user is and how they work

- Name on documents: **Andres Garufalias Alday** (the user chose this full form; earlier drafts said "Andrés Garufalias").
- Writes to the assistant in English; the **Perfil itself is in Spanish**.
- Wants outputs to be "outstanding", "upload-worthy to my professor". Likes to be **interviewed** when something is unclear, and does not want guessing ("If you need more information, let me know instead of guessing").
- Is under an **NDA**: the collaborating organization, its client, the pilot site's name/location, staff and internal systems must not be identified in the Perfil. The user's internal project context calls it "DeepBlue" (~300 retail sites, RevPi Connect 5 edge devices, MQTT → InfluxDB v2 → Grafana, SQLite buffering + Reconciler). In the Perfil it is always "la organización colaboradora", "el cliente", "el sitio piloto".
- Is strongly aware of course rules: sources must be **opened and verified by the student**; AI must not be asked to invent references; AI use must be declared (Anexo D).
- The user pays attention to detail and writes substantive review comments (see section 6).
- Working directory of this session: `/Users/andreas/Vaults/Uni/FinalTerm/GradProject` (an Obsidian vault, git repo on branch `main`; user git name CmdrCloud). The earlier DeepBlue work lived in `/Users/andreas/Work/DeepBlue`.

---

## 2. Part A — The DeepBlue prototype (done earlier, before the fork to the TFG work)

### 2.1 Request
"Create a mini project with Grafana and InfluxDB as a veeery small prototype ... just to visualise example data", using `/DeepBlue/prototypes/DATASET`. Build "the website" to see the data; give step-by-step guides for any manual configuration; interview if unclear.

### 2.2 Dataset facts (verified)
`/Users/andreas/Work/DeepBlue/prototypes/DATASET/` has 3 CSVs: `KwhConsumptionBlower78_1.csv` (1,228 rows, 1–20 Jan 2022), `_2.csv` (630 rows, 21–31 Jan), `_3.csv` (1,748 rows, 1–28 Feb). Columns: unnamed index, `TxnDate` (e.g. "01 Jan 2022"), `TxnTime`, `Consumption` (kWh). Total 3,606 rows → **3,581 unique timestamps**. No missing calendar days over 59 days; median interval ~21 min; 3 gaps >2 h (longest ~24 h, around 26 Jan). 24 duplicate timestamps: 23 identical rows (lossless dedup), **1 genuine conflict** at `2022-02-17 00:53:11` (1.018 vs 0.0; loader keeps first = 1.018 and logs it). Values rise and fall, so `Consumption` was interpreted as **kWh since the previous reading**, not a cumulative meter. Total energy 9,957.1 kWh (≈10.0 MWh). Feb 28: 64 readings, 68.0 kWh.

### 2.3 Decisions the user made (via interview)
- "Website" = **custom page embedding Grafana panels** (nginx serving an HTML page with iframes).
- Hierarchy: **faithful, 1 Site / 1 Circuit** (`SITE-078` / `Blower-78`), no synthetic data.
- Time: **true 2022 timestamps**, absolute timeframes pinned to the data window (relative ranges would render empty).
- Ingest: **direct CSV → InfluxDB** loader (no MQTT/Telegraf).

### 2.4 What was built
Location: `/Users/andreas/Work/DeepBlue/prototypes/energy-dashboard/`
- `docker-compose.yml`: services `influxdb` (2.7, retention 0 = infinite), `loader` (python:3.12-slim, one-shot, idempotent), `grafana` (grafana-oss 11.3.0, anonymous Viewer + embedding enabled), `web` (nginx:alpine). Defaults inline (no `.env` needed; `.env.example` provided).
- `loader/load.py`: stdlib-only; dedups; writes line protocol `energy_consumption,site=SITE-078,circuit=Blower-78 kwh=…,kw=… <ns>`; **kw is derived** = kwh ÷ hours since previous reading, omitted when the gap > 2 h; verifies stored count by parsing the Flux CSV header (an earlier bug hardcoded column index 6; fixed).
- Grafana provisioning: datasource `deepblue-influx` (Flux), dashboard `deepblue-energy` (4 stat panels + kWh bars + kW line; the "Readings" unit bug "4 K" was fixed by using unit `none`).
- `web/index.html`: Data Interval (15m/30m/1h/6h/1d) and Timeframe (full/Jan/Feb/last 7 d/last 24 h of data) selectors; all UTC.
- `README.md`: setup, assumptions, troubleshooting.
- Run: `cd prototypes/energy-dashboard && docker compose up -d`. Page: http://localhost:8080; Grafana :3000 (admin/admin); InfluxDB :8086 (deepblue / deepblue-dev-password, token `deepblue-dev-token`). Throwaway credentials, local only.
- Verified end-to-end from a clean `down -v`: 3,581 points stored, figures cross-checked against raw CSV (dashboard 3581 readings / 10.0 MWh / Feb 28 = 64 readings, 68.0 kWh).
- Known quirk: each embedded panel loads its own Grafana frontend, so the page takes ~15 s to render. A blank-chart episode was caused by forcing a 1500 px viewport in the headless browser, not by the dashboard.
- Observation raised to the user: the Gherkin feature lists unit `mW`, which is ambiguous (milli vs mega); only kWh/kW were implemented. Because the model is single-site, the site selector, rollups and Supervisor/Manager scenarios are not demoed.
- Nothing from this part was committed.

---

## 3. Part B — The TFG Perfil: course context and rules

### 3.1 Institution and course
UTEPSA, Facultad de Ciencia y Tecnología, Ingeniería de Sistemas. "Taller de Trabajo Final de Grado", 5 modules × 4 weeks, 400 h (160 in class + 240 independent). Teacher/methodological tutor: **Ing. Walter J. Méndez**, Aula N-222. Modality: **Proyecto de Grado** (not Tesis): ends with a guiding question, not a hypothesis. Module order: M1 Perfil, M2 Marco teórico (Cap. I), M3 Diagnóstico (Cap. II), M4 Propuesta (Cap. III), M5 Cierre. Perfil approval is valid 1 year. The professor's slide deck explicitly lists the user's project as "T5 · sincronización edge-to-cloud".

### 3.2 Official Perfil structure (ES-DFG-106 v6)
1 Introducción; 2 Planteamiento del problema (2.1 Antecedentes, 2.2 Situación problemática, 2.3 Pregunta/hipótesis); 3 Objetivos; 4 Delimitación (contenido, espacial, temporal); 5 Justificación (práctica, teórica); 6 Metodología (tipo, método, fuentes y técnicas); 7 Índice tentativo; 8 Cronograma; 9 Bibliografía; 10 Anexos. Final TFG structure: Introducción (= the Perfil, not a chapter), Cap. I Marco teórico, Cap. II Diagnóstico, Cap. III Propuesta, Conclusiones (one per specific objective). **No "Capítulo IV/V" by default**; validation lives inside Cap. III.

### 3.3 Format rules (applied in v4/v5)
Letter size, 2.54 cm margins, Times New Roman 12, 1.5 line spacing, justified, impersonal style (no first person), header top-left with a horizontal rule, page numbers top-right: roman lowercase for preliminary pages, arabic for the body, APA 7 citations and references, tables/figures numbered with APA captions. TFG minimum 80 pages (not the Perfil).

### 3.4 Sources policy
Allowed: recognized textbooks, ISO/NIST/ITU standards, IEEE/ACM/SciELO/Redalyc articles, official technical documentation, university repositories. **Forbidden**: Wikipedia, Studocu, Scribd, SlideShare, academia.edu, pdfcoffee, monografias.com, personal blogs, third-party notes. Every cited source must be opened and verified by the student. AI may help find/understand sources, never invent or "complete" citations. AI use is declared per phase (Anexo D).

### 3.5 Professor feedback the user has recorded (from `todo/todo.md` and `notes/grad-project.md`)
- "The problem is not the internet, it's the loss of data" (document problem as data integrity).
- Second objective was "doubtful (facturación is not the right word)".
- Better flow: antecedentes → problem → causes → effects → objectives.
- Asked about expected % of data loss and how the test was done.
- Show an image/diagram in the context ("nobody knows what the hell you're talking about").
- Population "sin n": nodes of the environment; declare nodes and cycles of the test bench; document the instruments (in annexes); "toda la documentación en el libro de Arias".
- After sending: **respect APA 7; add university logo and proper first-page styling**.
- DeepBlue won't give its expected data-loss percentage, so the Perfil must derive its own expectation from published studies.
- From the deck: the professor flagged this project for "tres mecanismos: cada uno es un proyecto en sí mismo"; the Cap. II had no objective producing it (fixed by OE1).

---

## 4. The Perfil: topic, content decisions and the logic of v5

### 4.1 Title
"Motor de sincronización de datos tolerante a fallos para un pipeline edge-to-cloud en una plataforma IIoT de monitoreo energético". Type **T5** (automatización, IoT y sistemas embebidos) as predominant; the user thinks there is "a little T2" but accepted T5 only (T2 was removed). Line: **Innovación, Tecnología y Desarrollo** (my recommendation; the user did not explicitly confirm, and the Jefe de Carrera decides).

### 4.2 Core argument
- Problem: when internet is cut and restored, the edge device loses readings (sends without a local copy) or duplicates them (resumes without progress marks). Silent: central store consolidates whatever it receives and exposes no integrity metrics.
- Causes: C1 direct send, no pending local copy; C2 resume without progress marks / stable identity; C3 no controlled failure tests before deployment; C4 ISP connectivity (environment, **out of scope**).
- Effects (Figure 2): incomplete or inflated consumption reports; comparisons against a baseline and decisions made on unreliable data; inconsistencies detected late.
- Solution: the **motor** = one artifact composed of (a) persistent local buffer using the *transactional outbox* pattern and (b) reconciliation with stable ids (site + sequence number, i.e. `edge_seq`), idempotent consolidation and a gap-free watermark. Fault testing is the **evaluation step of DSR**, not a third mechanism. This was the answer to the professor's "three mechanisms" critique (the user said "I don't know about this yet. What do you think?" and accepted "Reframe as one artifact", the recommended option).
- **Exactly-once nuance (critical, from the user's comment C0)**: strict network-level exactly-once is impossible (Two Generals / Kleppmann). The motor guarantees the **effect** exactly-once on the consolidated data via at-least-once delivery + idempotency keys + idempotent consumer + outbox. The motor handles loss/duplication caused by an unreliable internet link, not the theoretical exactly-once problem. v5 states this in the Introducción, section 3.3 and section 4.1 ("Alcance de la garantía"). Disk-full case: loss may be unavoidable; the criterion is that it be **explicit, not silent**.
- Methodology: applied, projective (Hurtado de Barrera); mixed approach (quantitative loss/duplication/recovery-time + qualitative documentary analysis of architecture-decision log); **non-experimental, cross-sectional with a declared quasi-experimental component** (before/after on the same test bench); two phases (descriptive Cap. II, propositive Cap. III); analytic + synthetic methods; DSRM (Peffers et al., 2007); population = nodes and cycles of the test bench, treated as a **census** (no sampling formula, citing Arias 2012); two techniques: technical measurement (Anexo A planilla) and documentary analysis (Anexo B matrix); development methodology = **iterative prototyping** (Pressman & Maxim 2020) with iterations I1 outbox, I2 reconciliation, I3 integration + fault tests + dashboard. Kanban/Scrum were dropped from v3 because the course says declare only what you can evidence.
- Testbed: currently a **simulation on the user's Mac**; future: one **physical RevPi Connect 5** gateway + simulated nodes. Only **one** deployable pilot site will exist (the client's single pilot site).
- The v3 draft contained a baseline (40,000 readings, 10 cycles, 7.3% loss, 4.4% duplication). The user confirmed those numbers were **illustrative placeholders, not measured**. They must **never** be presented as data. They are not in v4/v5.

### 4.3 Evidence the Perfil uses (all verified by reading the sources; the user must still open them himself)
| Source | Verified facts used |
|---|---|
| Bischof, Bustamante & Feamster (2017), arXiv:1709.09349 (7,998 FCC MBA gateways, 2011–2015) | avg availability at most two nines (99%) with 17.8 h/yr downtime (p. 1; this equals Verizon fiber at the 10% threshold in Table 4, the paper's own wording is "at most two nines … average annual downtime of 17.8 hours"); wired providers 98.87–99.80% availability at the 10%-loss threshold (p. 5, Table 4; Frontier DSL 98.87 lowest, Verizon fiber 99.80 highest); most ISPs MTBF > 200 h, repairs in 1–2 h (p. 6); multihoming same ISP 99.94%, different ISPs 99.992% (p. 10). Note: availability "99.18%" etc. depend on loss threshold (1/5/10%). |
| Padmanabhan, Schulman, Levin & Spring (2019), SIGCOMM '19, pp. 145–158 | 8 years, 101 billion pings, 10.8 million residential addresses; storms/wind/heavy rain raise outage probability; recovery of wired links 1.5× longer in precipitation and 2× in gale-force wind (p. 10 of PDF; cited in the Perfil as pp. 146, 154 using the proceedings pagination, **a page-mapping the user should verify**; the PDF's own page numbering differs). |
| ATT Bolivia (2025), RAR ATT-DJ-RAR-TL LP 700/2025, 17 Oct 2025 (scanned PDF; read visually) | no availability indicator; PSC (dropped TCP sessions) target ≤ 2% (cited pp. 16–17); packet-loss targets ≤ 2%/1% year 1 for AIM and AIF/AAF, down to 1%/0.5% from year 3 (p. 12–13); art. 13 excludes force-majeure/fortuitous/scheduled-work outages from target calculations (p. 18). Cited pages are the PDF page numbers. |
| OASIS (2019), MQTT v5.0 | QoS 0 "message loss can occur"; QoS 1 "assured to arrive but duplicates can occur"; QoS 2 exactly once (only client↔broker hop). |
| Domingues, Faria & Portugal (2024), EURASIP JWCN, art. 2 | MQTT retransmission after disconnection; data sent during disconnection is lost unless retained; persistent sessions don't guarantee retransmission; 4,300 tests; optimal payload 13.04 MB ≈ 15 min of data; authors found no prior work optimizing retransmission after disconnection. |
| Matias & Macêdo (2026), WTF/SBRC 2026, pp. 242–246 | edge store-and-forward with FIFO memory buffer + file persistence; 35-message cycle; loss reduced from 16 to 2 messages; 94.3% delivery; 83.3% recovered; ~72% of reviewed studies validate only by simulation (p. 243); duplicates not treated. |
| **Mirani, Awasthi, O'Mahony & Walsh (2024), IoT 5(4), 608–633, doi 10.3390/iot5040027** (the paper the user sent last) | real factory-floor deployment (ThingsBoard Edge in Docker on a PC, PostgreSQL, meters publish by MQTT **every minute**, ≤ 5.58% CPU); handles "random power failures"/"power or network connectivity events" by fetching the last available value in 6–24 h windows; **does not recover missing readings nor detect duplicates**; cloud receives one meter's filtered data. Used in antecedentes (2.1), situation (2.2), Table 1, Table 2 (cadence f = 60/h) and justification 5.2. It gives **no loss rate**, so the ~1% remains an estimate. Original ResearchGate link was blocked (HTTP 403); full text read at MDPI. |
| Shi et al. (2016), IEEE IoT-J 3(5), 637–646 | edge computing definition/motivation. |
| ITU-T Y.2060 (2012), renumbered Y.4000 in 2016 | four-layer IoT reference model. |
| Basiri et al. (2016), IEEE Software 33(3), 35–41 | chaos engineering principles. |
| Kleppmann (2017), AWS (s. f.-a Greengrass Stream Manager; s. f.-b Transactional outbox), Akidau et al. (2021) VLDB, Hevner et al. (2004), Peffers et al. (2007), Hurtado de Barrera (2010), Hernández-Sampieri & Mendoza (2018), Arias (2012), Pressman & Maxim (2020) | methodology/theory references. |
| Revolution Pi (s. f.) product page; European Central Bank (2026) | budget: RevPi Connect 5 listed at **€581 excl. VAT** (€691.39 incl.), EUR→USD **1.0989** on 2026-11-17. |

Verified-in-text numbers: 7,998 gateways; 10.8 million addresses; 99%; 98.87–99.80%; MTBF >200 h; 1–2 h repairs; 99.94 / 99.992%.

### 4.4 The estimation model (Table 2, "estimación previa a la línea base")
Loss L ≈ U (fraction of time without channel), with the reference 99% availability → **≈1% of readings ≈ 87.6 h/yr** (8,760 × 0.01). Outages per year k ≈ 8,760 h ÷ MTBF → 44–88 for MTBF 200–100 h. Duplication D ≈ W ÷ (f × MTBF) with f = 60 readings/h (Mirani) and W = 1–10 readings resent per reconnection → ≈ **0.008%–0.17%**. This is **derived analytically from US broadband data, not measured at the pilot site**, and the document says so. The ~1% is also quoted in the problem formulation and in 5.1. When real data arrives: replace Table 2, section 2.2 (the paragraphs around it), the "≈1%" in 2.4 and 5.1, and the Tabla 1 row about frequency.

---

## 5. File and version history (very important)

### 5.1 Local files (`/Users/andreas/Vaults/Uni/FinalTerm/GradProject/`)
- `deliverables/Perfil_TFG_Garufalias_v3.docx` (18 Sep 2026): an earlier fuller draft by the user with v3 content (Kanban, redundancy argument, section "exactly-once", fake baseline 7.3%/4.4%). Not edited.
- `deliverables/Perfil_TFG_Garufalias_ajustado.docx` (17 Oct): the class-worksheet-style version (F-1.3…F-1.8) that was the starting point of this session. **Unchanged by me.**
- `deliverables/Perfil_TFG_Garufalias_v4.docx` + `.pdf` (20 Oct): my first full rewrite (25 pages). Unchanged since.
- `deliverables/Perfil_TFG_Garufalias_v5.docx` + `.pdf` (17 Nov): **current**, 29 pages, sha256 `0a78b50e2cfb6132c1e803fca17ebf2c8e4dc43c6def873de5b81ab44c9a871d`. Passed the docx schema validator; every one of 22 references is cited and listed (checked programmatically).
- `deliverables/Guia_Contraste_Perfil_TFG.docx` (20 Oct): the comparison guide. **Now stale w.r.t. v5** (see 8).
- `deliverables/Matriz_Literatura_M2_S1.docx`: the user's M2 literature matrix (16 sources; declares type T1; lists Ferrag et al. Edge-IIoTset, Richardson, etc.). Not updated.
- Notes: `notes/grad-project.md`, `notes/anclaje-metodologico.md`, `notes/marco-teorico-m2-week1.md`, `notes/marco-teorico-m2-week2.md`, `todo/todo.md`, `activities/*` (F-1.x fichas, starting.md, problem-tree.md), `materials/*` (course PDFs/decks; M1_S2_Deck, M1_S3_Deck, Month1_Week1, M2_Guia_del_Estudiante, ES-DFG-106 Guía Ejecutiva, `7488250.pdf` = Shi et al. paper).
- This handoff: `notes/HANDOFF-perfil-y-prototipo.md`.

### 5.2 Google Drive (user's account; the connector is `mcp__79480cab-…` Drive tools: search_files, read_file_content, download_file_content, create_file, update_file)
- Folder id `1MYPh0V7ftYodwvZYtPKGrQrCWiYDtbMG` holds:
  - `Perfil_TFG_Garufalias_v4.docx`, file id `1ybLrlFsrMZX73ALW1sD2SPa64B7ZMuAc` — **the user's commented copy** (10 comments + yellow highlights + a "5.3 Justificacion economica" heading the user added). Left untouched.
  - `Perfil_TFG_Garufalias_v5.docx`, file id `1zQdUcbdv1GIVgKyCqpgNLNin-Fta3t7d`, https://drive.google.com/file/d/1zQdUcbdv1GIVgKyCqpgNLNin-Fta3t7d/view?usp=drivesdk — created by me (uploaded as .docx, not converted to a Google Doc, because converting would break the page numbering, index field and image sizing).
- Other Drive files in the user's account belong to classmates (a shared course folder); do not touch them.

### 5.3 How v4/v5 were generated (the build is reproducible but lives in an ephemeral scratchpad)
Scratchpad: `/private/tmp/claude-501/-Users-andreas-Vaults-Uni-FinalTerm-GradProject/0e565b90-d937-4c6e-852c-a97c761721fb/scratchpad/` (may vanish). Contents that mattered:
- `build/perfil.js` (docx-js generator for v5; ~all text lives there), `build/post.py` (wraps the static index in a real Word TOC field; computes page numbers from the rendered PDF; renders contact sheets), `build/build.sh` (two-pass build), `build/img/` (logo + 3 figures; figures restored from the user's Drive docx because the originals were in the scratchpad), `build/figures.py` (matplotlib source of the 3 figures; **may be gone**; the PNGs also exist inside the .docx files).
- Process: write with docx-js → LibreOffice convert to PDF → read page numbers → rebuild with correct index → convert again → verify pages unchanged → validate with the docx skill's `validate.py` → render pages to PNG and visually inspect.
- If the scratchpad is gone, the easiest way to edit v5 is to unzip the .docx and edit `word/document.xml` (use the docx skill's guidance: unpack, merge_runs, edit, repack, validate), or regenerate with docx-js from the structure described in sections 4 and 6.
- Environment gotchas: no poppler (`pdftoppm`/`pdftotext` absent); used a venv with `pypdf`, `pypdfium2`, `pillow`, `defusedxml`, `lxml`, `matplotlib`; Node `docx@9`; LibreOffice (`soffice`) at /opt/homebrew/bin. The `docx` skill's `validate.py` needs `defusedxml`. Fonts: Times New Roman exists on the Mac, Calibri doesn't.
- The UTEPSA logo comes from `https://v3.utepsa.edu/images/2017/12/20/LogoColor.png` (181×51 px, upscaled 4× to 724×204). **It is low resolution.** The user should replace it with the official file from Defensa de Grado.

---

## 6. The user's 10 review comments on v4 and exactly how v5 resolved each

| # | Anchor in v4 | User's comment (paraphrase) | v5 resolution |
|---|---|---|---|
| C0 | Intro: "la composición… efecto exactamente una vez" | Be much more specific about exactly-once in the delimitations and earlier; the engine handles loss/duplication caused by an unreliable internet link, not the impossible network-level exactly-once; patterns: idempotent consumers, dedup/idempotency keys, transactional/outbox, platform support. | Intro paragraph rewritten; §3.3 rewritten around the three patterns with the user's "SET not INCREMENT" example; §4.1 new "Alcance de la garantía"; Table 4 reworded. |
| C1 | Intro: "El documento sigue la estructura…" | Drop the structure sentence; keep and expand the confidentiality note. | Structure sentence removed; confidentiality paragraph expanded (what is not named, what data is used, why verifiability is preserved). |
| C2 | Table 2 | Get real data for this. | Cannot yet. Relabelled "estimación previa a la línea base"; uses Mirani cadence; replaced when data arrives. |
| C3 | General objective | Make technical words simpler without dumbing down. | Rewritten in plain language (readings recorded once, no loss/duplicates, even if connection or process fails; kept until receipt confirmed; repeats discarded). |
| C4 | OE2/OE3 "Diseñar e implementar" | Same verbs; "design" too strong; prefer "implement"; specific objectives are modules/individual solutions to cause-effect, not the whole project. | OE1 Diagnosticar, OE2 Implementar un módulo…, OE3 Construir un módulo…, OE4 Validar… (+ verification dashboard). |
| C5 | §4.1 paragraph "El proyecto es de tipo T5 y comprende (a)…(d)" | Redundant with objectives. | Replaced with a short scope statement (sync layer only, minimal instrumentation, verification dashboard); alcance de la garantía added. |
| C6 | "no comprende: paneles o interfaces…" | How will I show it works to judges if no UI? Maybe a visual confirmation. | New **tablero de verificación** (generated/consolidated/lost/duplicated per scenario, with and without the motor); included in objective OE4, §4.1, §6.4, §6.5, Table 9 (I3), Table 11, cronograma; "no comprende" item reworded to "interfaces de usuario para la operación de la plataforma; se incluye únicamente el tablero de verificación". |
| C7 | §4.3 Delimitación temporal | Don't add module/course info; it's a given. | Reworded to dates only (sources 2017–2025; baseline in November 2026; build/validation Nov–Dec 2026). |
| C8 | §5.1 "≈1% … 87,6 horas" | Real data needed; will ask Ing. Andres Vega. | Kept as estimate, with explicit text that the baseline will replace it. |
| C9 | after §5.2 (heading "5.3 Justificacion economica") | Economic justification and a budget for the whole project are very important; always asked in presentations. | New §5.3 (backup-link comparison + investment); Table 5 budget (USD 830); Table 6 effort (400 h). |

The user's **highlighted** text in v4 was the whole "no comprende" bullet list (7 items); v5 keeps all seven (only the UI one was reworded).

---

## 7. Current v5 content map (for navigation)

Front matter: cover (logo, university, faculty, career, "PERFIL DE TRABAJO FINAL DE GRADO", title, type T5, line ITD, student, docente, Noviembre de 2026, confidentiality note), Índice general (a real Word TOC field), Índice de tablas, Índice de figuras (those two are static text).

Body (page numbers within the body): 1 Introducción (p.1) · 2 Planteamiento: 2.1 Antecedentes, 2.2 Situación problemática (Fig 1, Tables 1–2), 2.3 Causas (Fig 2), 2.4 Formulación y pregunta guía · 3 Objetivos: 3.1 general, 3.2 específicos OE1–OE4 (Table 3), 3.3 Precisión sobre la garantía (Table 4, Fig 3) · 4 Delimitación: 4.1 contenido (alcance de la garantía + "no comprende" list), 4.2 espacial, 4.3 temporal · 5 Justificación: 5.1 práctica, 5.2 teórica, 5.3 económica (Tables 5–6) · 6 Metodología: 6.1 tipo/enfoque/diseño, 6.2 método (Table 7 DSRM), 6.3 fuentes/técnicas (Table 8), 6.4 desarrollo (Table 9 iterations), 6.5 validación (Table 10 scenarios E1–E4) · 7 Índice tentativo (Table 11) · 8 Cronograma (Table 12) · 9 Referencias (22) · 10 Anexos A (planilla, Tables A1–A2), B (matriz de decisiones, B1), C (cinco porqués/Ishikawa, C1–C2), D (uso de IA, D1).

Figures: 1 current architecture + failure points; 2 problem tree (E1–E3 effects, C1–C4 causes, OE2/OE3/OE4, C4 out of scope); 3 proposed architecture (outbox buffer, retrying sender, idempotent consolidator on `(site_id, edge_seq)`, watermark, confirmations, fault-test frame).

Test scenarios (Table 10): E1 link cut; E2 sender-process kill; E3 device reboot with pending readings; E4 local storage exhausted. Acceptance: zero loss and zero consolidated duplicates (E4: loss must be explicit and flagged).

Budget (Table 5): gateway 581 € × 1.0989 = **USD 638**; shipping/import/24 V supply/cabling reserve 30% = **USD 192**; open-source software, cloud infra, dev computer = 0; **Total USD 830**. Effort (Table 6): Perfil+M2 160 h, diagnóstico 80 h, construcción 80 h (≈20 h pure development), validación+cierre 80 h (≈12 h of fault tests) = 400 h (an even-ish split I assumed; the user did not confirm it).

---

## 8. Known gaps, open decisions and things the user must do

1. **Real data.** The user will ask Ing. Andres Vega (collaborating organization) for real loss/duplication data. Until then everything quantitative about the pilot is an estimate (and must remain labelled so).
2. **Who pays for the gateway.** In Table 5 I wrote "Organización colaboradora" as financing for the gateway and the cloud infrastructure; **this was my assumption**, not confirmed. Also the 30% reserve is a placeholder to be replaced with local import quotes (Bolivia). The user should confirm both.
3. **Cronograma (Table 12) still uses the course dates**, including M3 closing 31/10/2026 which has already passed. The user is behind schedule; decide whether to show real dates or the official ones. §4.3 already says the baseline is measured in November.
4. **The user must personally open and verify the new sources** (Mirani 2024, Bischof 2017, Padmanabhan 2019, Domingues 2024, Matias & Macêdo 2026, ATT 2025, OASIS, Revolution Pi page, ECB rates) before submitting, per the program's AI policy. Page numbers: Padmanabhan cited as pp. 146 and 154 (proceedings-style) vs the PDF numbering p. 2/p. 10; Bischof pages refer to the arXiv PDF; ATT pages refer to the scanned PDF page numbers. These should be cross-checked.
5. **Anexo D (AI-use declaration)** is drafted by me; the user should edit it so it states exactly how each tool was used (Claude for structure/APA/figures/wording; OpenAlex for literature search; web fetch tools; no AI-generated citations accepted without reading), and log the search in ficha F-2.1.
6. **Logo**: low resolution; ask Defensa de Grado for the official file and possibly the official cover format.
7. **Line of investigation** "Innovación, Tecnología y Desarrollo": unconfirmed with the Jefe de Carrera.
8. **Literature matrix still declares T1**; should say T5. It also lists sources not used in the Perfil.
9. **`Guia_Contraste_Perfil_TFG.docx` is stale**: it checks "Perfil v4" and refers to table numbers of v4 (Tabla 6, 8, 9, 10, 3), says 19 references (now 22), has no Mirani paper as a fourth comparator, says "no interview" and mentions the 26-point checklist items now partly outdated (e.g., the tablero, the economic justification, budget). The user asked before for a comparison document; it should be regenerated against v5. In the guide's comparison, Mirani should be added: real deployment; MQTT 1/min; edge on a PC; gaps tolerated by 6–24 h look-back windows; no recovery, no dedup; PostgreSQL; ThingsBoard.
10. **No interview** in the methodology: I deliberately excluded it because the user has no access to a site operator now ("I will have access in the future … recommend something"). Alternative offered: documentary analysis of the architecture-decision log as the qualitative strand; add an interview with a recorded change if access appears in M3.
11. **Optional improvement ideas** (not done): add a short subsection on *scope risk* (the 20 h build budget), add Mirani to a refreshed comparison, bring in the user's M2 literature (Gilbert & Lynch 2002 CAP, Fischer-Lynch-Paterson 1985, Gray 1978, Richardson 2018/2019, Ferrag et al. 2022) for Chapter I, and create a defence slide deck update (the existing deck is `Presentacion_Perfil_TFG_Garufalias_Final.pptx` and does not reflect v5).
12. **Nothing is committed.** The repo has many untracked/modified files from the user's other work. If asked to commit, use the attribution trailer given by the harness, branch off `main` if required, and do not push.

---

## 9. Verified-vs-assumed ledger (so nothing gets repeated as fact by mistake)

**Verified from sources:** every number listed in 4.3; RevPi price (€581 excl. VAT, €691.39 incl., official shop page on 2026-11-17); EUR/USD 1.0989 from the Frankfurter (ECB-based) API on 2026-11-17; Y.2060 renumbered Y.4000 in 2016; ATT RAR 700/2025 dated 17 Oct 2025; UTEPSA logo URL.
**Derived by me (labelled as such in the document):** ≈1% loss, 87.6 h/yr, 44–88 outages/yr, 0.008–0.17% duplication (with assumed W=1–10), the 30% reserve, the effort-hours split.
**Not verified / not available:** any measurement from the pilot site; the client's real outage frequency; the ISP; whether the collaborating organization will fund hardware; approved UTEPSA T5 Perfiles to compare against (none are indexed online, ask the library or Defensa de Grado).
**Do not use:** the 7.3% / 4.4% / 40,000 readings figures from v3 (placeholders). The sentence "frecuencia diaria o semanal" for outages was removed because it rested only on "reported by the staff"; do not reintroduce it without an instrument.

---

## 10. Working agreements and cautions for the next assistant

- Keep **NDA**: never write "DeepBlue" or any real names in anything that will go into the Perfil or be shared with the professor; the private notes may use it.
- Language of deliverables: Spanish, impersonal style, APA 7, Times New Roman 12, 1.5 spacing, 2.54 cm margins.
- Do not overwrite the user's files without asking; create new versions (v6…). The user's commented Drive v4 must stay as is.
- When citing, **only cite what has been opened and checked**; AI-suggested citations are not allowed by the course. If a site blocks automated access (ResearchGate, ACM, IEEE, Springer, SSRN returned 403/login), use the built-in browser (it worked for MDPI, Springer article pages, arXiv, UTEPSA) or an author-hosted copy (UCSD for Padmanabhan), and say plainly what could not be read. Subagent (web-fetch) reports were incomplete several times; I re-read the sources myself.
- When the user supplies real data: update Table 2 and §2.2/2.4/5.1 first, then re-run the pagination pass (index page numbers are computed from the rendered PDF), regenerate the PDF preview and re-validate the docx.
- Interview the user before assuming decisions that affect the thesis scope; he prefers short questions with clear options.
- If a long background job times out in the sandbox, run it in the background and re-check; LibreOffice conversion occasionally needs a retry.
- Cross-references to table numbers are hard-coded in the generator text; whenever a table is added or removed, search for "Tabla N" occurrences (this already caused one stale reference in v5, fixed before upload).

---

## 11. Suggested next steps (in order)

1. Ask the user whether the hardware is paid by the organization, whether they want real dates in the cronograma, and whether they got data from Ing. Vega.
2. When data arrives: update Table 2 and the ~1% statements; add a short "datos del sitio piloto" subsection; keep the estimation as a secondary cross-check.
3. Regenerate `Guia_Contraste_Perfil_TFG.docx` against v5 (add Mirani; refresh the checklist and the likely tribunal questions, including "who pays?", "why a dashboard?", "why USD 830?").
4. Update the defence slides to v5 (they are still from the earlier version) — remember the professor asked for a context diagram and a streamlined 10-minute talk (the user took 17 minutes at the second presentation).
5. Prepare for the Chapter I (marco teórico) using the literature matrix, fixing T1 → T5.
