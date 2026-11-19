# Notes

**Do:**

- [x] Python Course
- [ ] Hands-On Machine Learning with Scikit-Learn and PyTorch
- [ ] ML Roadmap roadmap.sh/machine-learning

**Then:**

- [ ] AI Engineer roadmap.sh/ai-engineer
- [ ] Then ML course in coursera (andrew ng)

## Want

- Coding principles book
- How to program book
- Machine/Deep Learning book
- AI book

## How to Prompt Claude

**Three Layers:**

### The Spec Layer

**Prompt:**

```md
Interview me to find the real goal of this project. Bias toward small,
compartmentalised specs. Make me verify key decisions explicitly so
nothing is missed.
```

### The Verifier Layer

**Prompt:**

```md
Outline the evaluation criteria you will use to ensure a high-quality
final product. Be precise.
```

**Prompt:**

```md
Before you start, define the precise criteria for a great result, use a past example
as the format to match, and have a second AI check the final output.
```

### The Environment Layer

**Prompt:**

```md
Check my CLAUDE.md, my knowledge base, my skills, and my guardrails.
For each of the top 5 gaps, name the file, the problem, and the exact
fix - and flag which risky actions need a hook so I can't bypass them.
```

## Format an email to our provider

- el problema es que no sabemos si un revpi es suficiente para todo el workload
  y no conocemos cuanto sera el workload, un aproximado seria 100-500 dispositivos

- el workload seria read/writes cada 15s de datos de consumo de energia en el revpi
  - mas enviar los datos a una nube (AWS) para tener acceso a mas procesamiento
  - ademas, si no hay conexion al internet el revpi tendria que usar un SQLite de
  backup + reconciler

- se ha resuelto antes el problema?

- si no se ha resuelto, sera que el proveedor va a proporcionar servidores o una
  solucion parecida?
  - o si nos pudiera dar recomendaciones o best practises?

## AWS Event (Containers in the cloud)

- OCI open container initiative
- runtime specification
- image spec
- distribution spec

### deploying containers in the aws cloud

- aws batch, ecs, eks
- ec2 and availability zones
- region -> vpc -> subnet

### amazon eks

- kubernetes architecture
  - control plane -> worker node/worker node n

- aws architecture
  - aws architecture <- internet -> clients
  - vpc, eks control plane <-> ecr
  - vpc (availability zone A, B, C) -> VPC clients

### Scaling

- hpa controller -> deployment -> scaling pods/reducs pods

```bash
kubectl autoscale deployment php-apache --cpu-load=50
```

- cluster autoscaler

- karpenter (why not kafka?)

- keda
  - kafka, rabbitmq, redis, amazon simple queue service

### observability

- metrics, logs, and traces

- metrics
  - grafana, prometheus
    - prometheus open source monitors alerts, designed for native cloud and microservices

- logs
  - elasticsearch
  - fluentd
  - loki

- traces
  - jaeger
  - opentelemetry

## AWS Event (Certifications)

- hands-on learning
- self diagnostic
- labs
- use AI to help yourself (but the question is how)
- AI practitioner, Data Engineer/Analyst for ML

**Advanced:**

- AWS Foundational AI, associate AI/architect, self-test
- data engineer -> data engineer associate
- pressure makes you stand out
- know how to demonstrate the knowledge you get from the certificate
- general AI professional

## Useful info for AI driven development

- spec driven development
  - speckit and openspec on github

- harness engineering
  - tell ai to use specific models for browsing tasks/documentations,
    then other models for coding
