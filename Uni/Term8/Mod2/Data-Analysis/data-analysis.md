# Data Analysis

- Prof: Andres Julio Vega
- 18 years of experience

1. Introduction to Big Data
2. Data architecture
3. Data engineering
4. Tools for business intelligence

## Important Terms

- Pragmatic is to focus more on the practical side of things rather than
the theoretical parts

- Instrumentation

- CDC

- Apache Flink

  - Data Generation

  - Persistence in data

  - Ratio in generation, volatile data/information

  - Data consistency

  - Communication
    - change in data sources
    - stay in sync with everything and everyone (OLTP)

- Storage

- Databricks

- Apache Spark

- Hadoop

- Snowflake

- DevOps
  - Development
  - Ops
  - Security
  - QA

- Observability

- DevSecOps

- IaC (Infrastructure as Code)

- CI/CD

- MLOps

> [!IMPORTANT]
> Summary -> Very high level
> Content -> Book idea
> Minto Pyramid -> Good / Deep
> Content + Minto -> Deeper
> Content + Minto + Images -> Deepest
> Keep your tech stack simple

- T Engineer:
  - Very deep knowledge of a thing (like a specialisation)
  - Be able to talk about this with different fields/majors
  - The best engineer is one who can talk about their specialty with any field

- Influencing people is a very powerful weapon.

- ACID (Test)
  - Atomicity
  - Consistency
  - Isolation
  - Durability

- MinIO

- Metadata

- Data bricks

> [!IMPORTANT]
> What is a system?
> A system is a set of related components for a common purpose.

## Introduction to Big Data

- Big data is dedicated to analyse, process, and store big datasets
with the objective to gain business insights
that traditional technologies can't prove.

- Data vs datasets:
  - Data: individual value
  - Datasets: collective related value

- Classifying types of data

- The five central characteristics of Big Data:
  - Volume
  - Velocity
  - Variety
  - Veracity
  - Value

- Strategic utility:
  - Refinement
  - Competitive advantage
  - Transformative effect

> [!IMPORTANT]
> If we are analysing something, we need to first find the value
> in what we are analysing, which is to say,
> we need to find our objective for analysing this thing.

### Data Analytics

- KPIs (key performance indicators)
  - important metrics to measure performance for a business
  - how many sales have been done today?
  - is the KPI in green? I'll give a bonus. Is it red? I'll give a pay cut
- Data analysis (the process of examining data to find facts, relationships, etc.)
  - Its primary objective is to support better decision-making abilities

- Data analytics is a more general term that includes data analysis
- Data analytics is a discipline that includes the complete life cycle of data
- This includes recollecting, cleaning, organising, storing, and analysing data.
- The term includes the development of analysis methods, scientific techniques

1. To recollect information is to gather data from its source
2. To clean data is to fix it or to prepare it
3. To organise data is to restructure it in a better way
4. To analyse data is to make an educated opinion based on studying it
5. To govern data is to decide what controls the data and how it's controlled

- Metadata
  - data that describes data

#### Data Analytics Hierarchy

- Data analysis is diagnosing data

- Descriptive analysis:
  - what happened in hindsight?

- Diagnostic analysis:
  - determine why something is happening

- Predictive analysis:
  - use models to determine the future (AI, foresight)

- Prescriptive analysis:
  - prescribe the best course of action and explain why (advisory)

- Examples:

1. Monthly sales reports
2. Real-time sales dashboard
3. ML model that predicts sales
4. System that recommends prices

Which of these is descriptive, diagnostic, predictive, prescriptive?

### DIKW Pyramid

Pyramid structure (top to bottom):

1. wisdom         (knowledge given understanding, becomes)
2. knowledge      (information given meaning, becomes)
3. information    (data given context, becomes)
4. data           (events)

- DIKW pyramid shows how data can be enriched with context
to create information that has significance
with which significance creates information
and the information creates knowledge which may form
wisdom

- The pyramid also shows the alignment with operative levels,
tactics, and the strategies of organisations.
- Additionally, it also shows how to generate a virtuous circle through
feedback

(strategic)     1. wisdom         (constraints)
(tactical KPIs) 2. knowledge      (action)
(operational)   3. information    (experience)
                4. data

#### Example

Sales data:

- Jan: 100
- Feb: 120
- Mar: 180

| Level           | Example        |
|---------------  | --------------- |
| Data            | Data given   |
| Information     | Sales are increasing, january doesn't have that many |
| Knowledge       | If this is increasing exponentially, there should be something we can do about january's sales  |
| Wisdom   | ...  |

### Data maturity - Tool

Data maturity is a progressive trip in the digital transformation of businesses
Evolves from reactive, silo (unrelated islands) data management,
towards a transformative ecosystem, based on the cloud.
Allows organisations to have predictive insights in real time and intelligence for
business self-service.

- Reactive
  - businesses in this level support themselves through "spreadmarts"
  - Informal repositories, decentralised spreadsheets, etc.

- Informative
  - organisations start to centralise their data to make its analysis more simple
  - these solutions are generally not scalable
  - there are some heavy operations that are limited to nighttime (batch processing)

- Predictive
  - in this stage, there is a transition towards native cloud technologies
  - that allows businesses to manage bigger data sets

- Transformative (self-service)
  - this is the greatest level where any architecture may get to from any source
  - allows non-technical users to generate their own reports

### Self-Service business intelligence

The final and greatest objective of a data architecture is to enable SSBI.
This empowers end users of any skill level to consult data and create reports
in an independent and efficient manner, eliminating bottlenecks in IT and
positively accelerating the value of the business.

- Transition from traditional BI bottlenecks
- Ease of use and accessibility
- Initial strategic investment to achieve value over a long period of time

### MECE

> [!IMPORTANT]
> MECE: mutually exclusive, collectively exhaustive

MECE is the best way to order your thoughts, it is widely known in SE, and it is
a written book from the 70s.

![[Pasted image 20260309080129.png]]

### MECE group work

Define domains for the student.

- Reactive
  - creates notes in random directories
  - informal datasets everywhere: duplicated files, local files

- Informative
  - student has a consolidated dataset for their notes or group work
  - simple manual analysis

- Predictive
  - move datasets from local to cloud which enables scalability
  - automated analysis about words and performance

- Transformative
  - student has a dashboard that allows them and others to see their performance
  through automated reports.
  - reproducible pipelines

## Motivation for studying big data analytics

### Big expectations for data

Organisational aspirations have evolved from a simple feedback report
to a supremely pervasive movement by AI, creating a new demand without
any friction for data management which current systems fail to satisfy.

- Evolution from BI to ML
  - data has matured from traditional business intelligence
  - static reports now have embedded ML

- Democracy of actionable data
  - to democratise data means to give everyone access to something
  - organisations want powerful intelligence

- Requiring multimodal accessibility
  - this requires a new architecture that supports diverse data formats
  - also eliminates complexities that come with copying entire stacks

- Jump to probabilistic applications
  - discriminating the use of ML requires to move from deterministic
  software based on rules to non-deterministic applications directed by data.
  - this requires a no-frills access to the most recent data in order to train
  models.

### Data division

The fundamental separation of operational and analytical data creates a
big division characterised by fragile integrations, organisational silos,
and technical complexities that it prevents businesses from being
truly driven by data.

- operational data supports businesses and maintain the state of applications
- analytical data proves information histories and data added for insights
and ML.

- each plane (operational/analytical) is supported by different stacks
- these planes are maintained by different organisational verticals

- connections between these two planes are made by ETL processes (Extract,
  Transform, and Load) that are infested with errors each time these operational
  systems undergo any sort of change.
- this model takes to transformations and repeated copies which creates a very
  expensive environment to maintain.

> [!IMPORTANT]
> Professor wants value from the information that we bring him, not feedback.

### Operational vs. Analytical

1. Daily bank transactions
2. Monthly sales dashboard
3. Delivery system database
4. Database for ML sales
5. CRM System (Customer-Relationship Management)
6. Data warehouse

### Scaling

The definition of scaling goes beyond the traditional 5 Vs
(volume, velocity, variety, veracity, and value).

This has a new type of scale defined by ubiquity (present everywhere)
of data origins that requires to pass through a centralised collection
to a data connection all throughout the business.

- Valuable insights emerge connecting data sources beyond the control of
an organisation.

- For example:
  - Combining bank transactions with external market tendencies
  or purchase habits.

> [!IMPORTANT]
> Domain Driven Design (DDD)
> MECE
> S3 (AWS) -> MINIO
> Conway Law
> Palantir
> Monetisation

### What data sources would you use

- A company wants to understand client behaviour.

Let's say our business would be an e-commerce.

So we have internal data:
connection, products + purchases, searches, shopping cart (abandon),
clicks on the website, purchase methods.

External data would be:
purchases, amazon prime, customer demographic, geolocation

### Demand in data abilities and AI analytics

- +15% more demand in basic IT abilities for a variety of roles
- 4.1x more demand for advanced abilities in ML
- 3.7x more demand for advanced data analysis abilities

Big organisations have a 30% increased probability to hire
AI data scientists and 29% **more** to hire a data engineer than smaller
companies.

## Recap

- five Vs of big data (volume, velocity, variety, veracity, value)
- strategic utility
- data analysis vs. data analytics
- data analytics hierarchy
- DIKW pyramid
- data maturity
- motivation for studying big data
  - expectations
  - analytics
  - demand

## Tools

- WSL
- MinIO
- Pandas
- Docker

### WSL (Windows Subsystem for Linux)

WSL is a component of Microsoft Windows that allows the use
of a Linux environment within Windows, which eliminates the need for
a virtual machine and is also an alternative to dual booting.

### MinIO

MinIO is a high-performance and open-source storage system for objects
which is widely used as an alternative to Amazon S3.
It is designed for cloud-native apps, AI/ML workloads, and big data.
It supports unstructured data like photos, videos, and log files.

### Pandas

Pandas is a fast and powerful python library and an easy to use open source
data analysis and manipulation tool.

### Docker

Docker is a service that allows the containerisation of software applications.
Docker eliminates the "it runs on my computer but not on yours" problem by
creating a virtual environment within which all dependencies
for the project are installed along with the project itself, which ensures
easy stability control since each docker container is the same thing as any other
docker container.

## Conway Law

- SME (Subject Matter EXT)
- DDD (Domain Driven Design)

## Data architecture

- Investing time upfront to design a data architecture is a vital
strategic requirement.

- Since there is no one-size-fits-all design that fits every context,
a well-planned design is essential for an organisation to use their
data assets to support their business goals.

- why is it critical to define the design upfront?
  - prevents failures in projects
  - avoids financial mistakes or wastes

- high level blueprint

> [!IMPORTANT]
> Each system is very particular, so when you start planning a project,
> your understanding of the project is basically nothing, while your
> doubts about the project are really high. This means that while you
> are just starting a project, you shouldn't really build that project
> right then and there. Wait until your understanding has improved along
> with your doubts falling.

### Evolution of data architecture

- Everything started with relational databases (RDBMS)
  - relational databases are structured repositories of data that are
  organised into a schema of tables with rows and columns.
  - these are very rigid, which is not always a bad thing
  - uses block storage

- Data Lake
  - centralised and scalable repository that stores vast amounts of
  raw, unstructured, semi-structured, and structured data in its
  native format.
  - uses object storage
  - didn't replace RDMS because RDMSs have ACID tests and it runs a great risk
  of turning into a swamp (unordered, unstructured data)

- Modern Data Warehouse (MDW)
  - a cloud-based solution that gathers and stores data to make intelligent
  decisions.
  - combination of data lake and a data warehouse
  - quite complicated

- Data Fabric
  - a cloud-based, scalable repository that consolidates
  structured, semi-structured, and unstructured data
  from diverse sources for real-time analytics, machine learning, and business intelligence.
  - semantic layer that joins data (semantic means what the meaning is of something)

- Lakehouse
  - a modern data architecture that combines the low-cost, flexible storage of
  a data lake with the data management, governance, and ACID transactions
  of a data warehouse.
  - lakehouse tried to reduce the complexity in MDW

- Data Mesh
  - a descentralised architectural and organisational framework that
  treats data as a product.
  - data mesh brought a paradigm shift

### Critical Changes

We've gone from relational architectures to hybrid architectures.

#### Schema on write

Relational db model:

1. define the schema
2. validate data on write
3. store in db

- consistency and integrity
- optimised analytical performance
- acid transactional support

- changing schemas is really rigid and stupidly complicated
- not apt for non-structured data

#### Scheme on read

Data lake:

1. take in RAW data (JSON / Images)
2. save without validating (CSV / Excel)
3. schema to EEER (Log files)

- high flexibility for various types of data
- supports unstructured data
- low cost object storage
- fundamental for ML / data science

- lower initial quality control

##### Risks for schemas on read

You run the risk of making your database becoming a swamp, full of
unstructured data.

You mitigate this by imposing rules on the data, like storing unstructured
data in one bucket and structured data in another bucket, then organising them,
etc.

### Data Mesh and its effect on a paradigm shift

Before:

- IT used to be the bottleneck for a DB system
- sales, marketing, operations, finances, all pointed to central IT
- no diffuse data properties
- inconsistent quality
- doesn't scale as an organisation

After data meshes:

- centralises sales, manufacturing, etc.
  - centralises every department in a company into their own thing
  - that enables the following:

- each domain = owner of their data
- scales horizontally with new domains
- each domain chooses their own technology

Unfortunately, a massive work-cultural change is required.

### Relational Data Warehouse (RDW)

An RDW is a centralised system for data analysis at a huge scale
which is optimised for critical analytical queries. This ensures
data reliability using the on write scheme and it separates the
analytical load from a transactional system.

- Specific construction
  - scale big analytical queries and performance

- Historical Pillar
  - since 1970

- Coupling
  - compute engine coupled with relational storage

- Centralisation
  - dispersed data in one single place ensuring
  consistency and reliability

- Organisation
  - data in tables, rows, and columns

- On-write
  - relational + validation

- Load separation

### Data Lake

A data lake is highly scalable, has a low cost object-storage repository
that allows organisations to ingest huge amounts of raw data with an on-read
schema which offers critical functionality in advanced analysis.

- object-storage
  - low cost and diverse repository in original format

- massive ingesting
  - unlimited capacity for huge amounts of data

- advanced exploration
  - advanced ML analysis and staging for a structured architecture

- historical failure
  - couldn't replace rdw due to lack of acid validation and necessary abilities

- layers and zones
  - bronze, silver, and gold zones to organise data quality levels

- schema on-read
  - requires the schema in the query allowing flexibility when ingesting data

- bottom-up strategy
  - find value in raw data before investing into a model

#### Data swamp

An unstructured, disorganised, and ungoverned repository of huge amounts of
raw data. Often a neglected data lake.

### Data Fabric

Data fabric delivers integrated data to all data consumers.
A data fabric is a set of technologies.

- Master data management
- How could you implement a data fabric?

### Data Lake house

A data lake house is a unified architecture that looks to eliminate the need to
use a relational database when storing transactional data within a data lake.
This allows you to manage structured, semi-structured, and unstructured data in
a single repository.

- Unique repository

- Data structure

- Schema and access

- Term origin

- Transactional Layer
  - Delta Lake, Apache Iceberg or Apache Hudi

- Complexity

#### Lake house

1. Metadata Store -> BI Tools / Ad Hoc SQL / Notebooks / Programming Languages
2. Datalake engine
3. Open table format

- File formats
- Storage

### Data Mesh

A data mesh is a paradigm shift towards a descentralised architecture
where data is the property of specific domains and are managed by them.

A data mesh is based on four foundational elements:

- Federated data governance with central standards
- Domain teams turn raw data into data products
- Raw data stored locally and owned by domains
- Domain-agnostic self-serve tooling and infrastructure

## Data Engineering

Data engineering is the development, implementation, and maintenance
of processes and systems that receive huge amounts of data and
try to consistently produce high quality information to support
downstream use cases like ML or analysis.

Huge amounts of data are in the OLTP, the operational data, and
we want to migrate that data to the OLAP, the data used for analysis,
in order to do some analysis.

### What is data engineering?

The incoming data can be internal in regards to the company that you're
working with, or external by using APIs.

Steps to migrate operational data to use for analysis:

1. Copy data to the landing area
2. Copy data from landing to the cleanup area and perform cleanup routines.
3. From cleanup, copy to DWH to be used for analysis or to MLs.

The life cycle starts when you obtain data from the source systems and it
ends when you serve the data for analytical or ML use cases.

### The Data Science Necessity Pyramid

1. AI
  Machine Learning, Deep Learning

2. Learn/Optimise
  AIB, experimenting

3. Aggregate/Label
  Analytics, metrics, segments, features

4. Explore/Transform
  Cleanup, anomalies, basic preparation

5. Move/Store
  Reliable data flow; not only collecting data, but
  allowing it to move from one place to another with 100% risk tolerance

6. Collect
  Instrumentation, logs, sensors, content, data extraction

### Data engineering life cycle

#### Data Storage

- Type of Storage

- Data temperature
  - refers to the access frequency of the data

- Storage is separate from computing components in servers in modern times

#### Data Ingestion

- Batch vs. Streaming

- Ingestion patterns
  - Pull (Consumer)
  - Push (Producer)
  - Poll (*) -> always ask if its done and be annoying (legacy sometimes)

- Reliability

#### Data Transformation

- Data Evolution
  - You need to have a mapping of the data or metadata to describe
    where the data came from because people need to know that.

- Where?

- Business

#### Serving

- ETL Pipeline

- ETL Reverse
  - To explain an etl reverse, let's say that you have a certain risk %,
  then you have a table called users with all of your users who have
  more than an 85% chance to not pay their credits or debts, etc.

### Featuring

Featuring is a process that data goes through which is designed for ML.

- Extracts and improves data features that are useful to train models.

- Requires the combination of knowledge of the domain (to identify which
variables are or could be important for a model) with an ample data science
knowledge.

- Once data scientists determine that the necessary logic to transform
data in useful features, data engineers take charge in automating these
data pipeline processes so that they can work efficiently in production
environments.

> [!IMPORTANT]
> Data architect gives the rules for how the data will be managed
> Data engineer moves the data
> Data scientist says what they want

## Artificial Intelligence & Machine Learning

- Fermi's Problem
- AI & ML: Netflix and WWII
- Conclusions & Recommendations

### Fermi Problem

- Estimate unknown quantities using only logic and educated guesses,
without exact information.

- Decompose
  - Break down the problem

- Estimate
  - Use what you know to estimate each part

- Synthesise
  - Combine parts to make a reasonable answer

#### Why is this important in ML?

- Data is never perfect
- Reasoning is more valuable than the exact data
- Educated guesses are very useful
- Fermi thought like this and so did Wald and Netflix

### AI & Machine Learning WWII

- Specific input
  - Where is the best taco restaurant?

- Algorithm Pipeline
  - Various algorithms chained together intelligently

- Prediction / Decision
  - The best restaurant is XXX

#### The 3 powers that enabled AI

- Moore's Law
  - Exponential growth in computing power. Modern machines are much
  faster than older machines.

- Data
  - Practically all human knowledge is digitalised.

- Cloud Computing
  - Converted static prices into variable prices. Cheap and quick
  access to powerful computing solutions.

#### Netflix: from postal office to AI

#### Conditional Probability

- For a machine learning model, personalisation = conditional probability.

```python
P(rain this afternoon | cloudy morning) = 60%
```

- P(): The probability of the event

- |: Given that...

- Left <-: Event that we want to predict

- Right ->: What we know

#### Abraham Wald

The same probability problem even before netflix.

##### Cuantos litros de agua se toma (por persona) en scz por dia

| Datos |
| ------------- |
| 3.12M personas en scz |
| 65kg - 80kg peso promedio |
| 0.035ml consumo de agua minimo por kg |
| => 2.275L - 3.15L |
| => 0.5L - 3.15L de agua se consumen por persona por dia |
