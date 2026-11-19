# Mobile Technologies (ELEC III)

> [!IMPORTANT]
> Important Terms

- throughput: speed in a connection going both ways
- block risk: parametre that determines if a service will be available
  depending on how high its limit is
- time used:
- average time used:
- traffic intensity: erlangs, the average amount of busy lines that exist simultaneously
  a single in-use line equals one erlang
- telephone traffic: defined as the intensity of telephone traffic to the
  amount of simultaneous busy lines in a group during a given period of time
- queue theory
- loss, probability and its formula
- RBS, BTS, BSC, SIM
- IMEI, VLR, HLR, AuC
- difference between coaxial cables and fibre optic cables

---

## Traffic & Capacity

### Traffic Engineering

1. Requirements (Traffic = Erlangs | Throughput = bps)
2. Restrictions (Block Risk | Waiting Risk)
3. Resources (Circuits | Connection Speed | Buffer)

- how many antennas will i need to reliably provide connections for a city/area?

### Basic Concepts

A commutation network has links between input and output channels.

Input and output channels may be of type: "abonado," channel links,
or commutation devices.

Input groups -> commutation network -> output lines/channels (Line A, B, C...)

---

Input groups are made up of input lines that drive the demand for communications
(internet traffic) to a commutation network.

Output groups are made up of one or more output lines.

Traffic within an output group is made up of the usage within its many output lines.

- time used: time a line is used without interruptions
- average time used
- traffic intensity: a magnitude without dimension represented by the Erlang
  unit (Erl)

- ocupacion realizada: la utilizacion efectiva de una linea de salida
- ocupacion ofrecida: la solicitud de establecer una comunicacion que requiere la
  ocupacion...

> [!NOTE]
> finish the above definitions from the powerpoint

- load: the intensity of the traffic used
- offer: intensity of the offered traffic
- the difference between the two is the intensity [complete]

---

### Probability functions

- discrete mathematical functions: Poisson, discrete uniform, binomial
- continuous probability functions: exponential, continuous uniformity

#### Poisson process

- super-positions (you can combine things)
- decomposition (you can separate things from a single thing)

### Measuring Resource Usage

- packet networks
  - session generation rate (gamma)
  - sequence diagram for exchanging packets
  - bit length for each packet

- voice networks
  - call rate (gamma)

- busy hour
  - hour with the most amount of requests during a given period
    (selected by the provider BHCA or busy hour call attempts)

---

### Queue Theory

- gamma = average received rate
- mu = average attention rate

gamma and mu depend on the system's availability and resources, etc.

## Quality of Service ITU-T and Grade of Service

QoS is the collective effect of service performance which
determines the degree of satisfaction of a user of a service.

GoS is the percentage of requests that couldn't be received
because the system was busy. Below 5% is acceptable.

### Quality Parametres

- block probability
  - access
  - transport

- latency
  - average value
  - variation (jitter)
  - control
    - establishment
    - liberation
  - transit

- "caudal"
  - maximum
  - average

- error
  - erroneous bits
  - erroneous packets
  - packets lost
  - non-functional packets

- availability

- traffic block probability
  - in radio: 1-2%
  - in a fixed network: 0.01-0.1%

## End to End Blockage

- a circuit is a concatenation of links
  - access
  - interconnection
  - transport

- lee method
  - assumes usage independence in the links

## Cluster Problems

**Given:**

- there are 4 complete clusters
- you can add 4 additional cells to the cluster

**Find:**

- area of a regular hexagon cell
- traffic intensity per cell
- block probability
- CIR
- reassignment factor (number of cells in a cluster)

```latex
A = (3sqrt_{3})/2 * r^2
```

```latex
K = [BW_{total}/Channels]/NumberOfCellsInCluster
```

```latex
PB = EB(K, TO)

=> PB = EB(13, 7.4)

=> 2% block probability
```

```latex
CIR = 1/5(sqrt_{3N})^gamma

=> CIR = 3^4/5

=> CIR = 10log_{()}

=> CIR = 12.1dB
```

---

**Reassignment:**

- trying with N = 4 (N: number of cells)
- at cell A there are 3 antennas, so CIR would be:

```latex
CIR = 1/3(sqrt_{3N})^gamma

=> CIR = [12^2/3] * 10log_{()}

=> CIR = 16.8dB
```

- in this case, it would be more correct to evaluate CIR with another,
  more restrictive cell

```latex
CIR = 1/4(sqrt_{3N})^gamma

=> CIR = (12^2/4) * 10log_{()}

=> CIR = 15.6dB
```

---

**Exercises:**

`Given a cellular network made of hexagonal cells, each one with a
coverage radius of: 1.5km`

- Find the coverage area of a single hexagonal cell.

```latex
A = (3sqrt_{3})/2 * 1.5km^2

=> A = ...
```

---

`
Given a city with a total area of 350km^2 that needs a uniform cellphone
network with hexagonal cells.
`

- How many hexagonal cells are necessary to completely cover the city?
- Use the area from the previous question

---
`
Given a cellphone network that has a reassignment factor frequency of
K = 7, and each cell in the network uses 3 different channel frequencies
`

- how many different frequency groups are there in the entire network?
- how many unique frequencies does the operator need to cover the entire area
  if they do not want any interference between adjacent cells?

---

## Parts of a mobile network

A mobile network is made up of three things:

- a user terminal
  - (SIM cards, contains personal identification)

- an access network via radio
  - provides secure and robust access

- a network nucleus or core
  - responsible for end to end sessions

---

## History of the Gs

### 1G

- 1G started around the 80s
  - based on radio technology around 450MHz
  - analogue circuits and surface division by "celdas"

- NMT was the first international communication system, introduced in
  northern countries 1981

- roaming and "itinerancia" were the first concepts that arose

- during the 80s, an opportunity to develop a second generation of digital
  communication arose

### 2G

- CEPT started jobs in 1989 in order to develop a European mobile telephone
  system: GSM

- 2G had less coverage but increased comms quality and security levels

- FTSI was evaluating multiplexing techniques, ultimately decided on TDMA

- in the US, TIA developed a standard based on TDMA: US-TDMA

- Japan developed PDC

- GSM was based on circuits that blocked "celda" resources with a speed of
  9.6Kbps

- GSM evolved into GPRS, and allowed transmission speeds of 144Kbps
  - this was known as 2.5G

- uses a faster and less robust codex

- the next evolution was into Enhanced Data Rates for GSM Evolution (EDGE)

- in combination with GPRS, it is possible to add various radio channels to
  increase bandwidth and cover peak consumption-busy hours

#### GSM Network

- GSM networks define functional entities and interfaces that connect them

- user terminals are identified with a SIM card (Subscriber Identification Module)

- the network provides its service dividing territories into cells
  - each of these cells has an antenna (BTS or RBS)

- these RBSs or BTSs are connected to a BSC which is in charge of managing
  the radio network

- the AuC stores information to verify users when they connect

- the VLR is a database that stores users' local data within an MSC environment

- VLRs query user HLRs to verify the type of service they have

- the EIR is a repo based on IMEI that stores information that blocks
  unauthorised use of illegal protocols

---

##### GSM Recap

- a GSM network is made up of three environments:
  - BSS: Base Station Subsystem, the part of the radio network that groups antennas
    and BSCs

  - NSS: Network Switching Subsystem, which is made up of elements that provide
    connectivity and routing, which are MSCs, HLRs, AuCs, and EIRs

  - OSS: Operations Support Subsystem, manages network operations

- this network architecture defines and establishes the basic concepts of a
  mobile network

---

### 3G

- 3G was created thanks to the work done by 3GPP

- R99:
  - CS and PS
  - R99 Radios
  - MMS
  - localised services

- R4:
  - TD-SCDMA
  - independent CS "portadora"
  - UMT improvements

- R5:
  - RAN improvement
  - HSDPA
  - IMS

- R6:
  - uplink improvements
  - MBMS
  - WLAN-UMTS

---

- UMTS was the result of research during the 90s under the EU

- UMTS has two different work modes:
  - Frequency Division Duplex (FDD)
    - uses wideband CDMA, W-CDMA
  - Time Division Duplex (TDD)
    - uses time division CDMA, TD-CDMA

- bandwidth used is around 5MHz per porter and operators normally
  have three porters with a band of around 2100MHz

- UE is made up of a mobile terminal and a USIM which is compatible with GSM

- access via radio is provided by the UMTS Radio Access Network (UTRAN)
  and the Core Network provides transport, commutation, and signaling services

---

- TDMA, GSM, PDC -> GPRS -> EDGE -> UMTS, HSPDA -> HSPUA, HSPA+ -> LTE

---

### HSPA (3.5G)

- improves on UMTS because it takes advantage of the spectrum in a more
  efficient manner

- implements the standards:
  high speed downlink packet access, HSDPA, and HSUPA

- these standards were defined in releases 5 and 6 of the 3GPP
  - with maximum peak speeds of 14Mbps downloading and 5Mbps uploading

- HSDPA is also known as 3.5G

- HSDPA is also known as 3.75G or 3.5G+

- HSDPA gives services to IP Multimedia Subsystems, IMS, and is also
  capable of offering UMTS voice services

- this is used to connect laptops for a satisfactory user experience

---

### HSPA+

- introduced the use of multiple antennas, MIMO, which provides a
  greater robustness

---

### 4G and LTE

- improves data transmission speeds, spectrum use optimisation,
  increase coverage, reduce latency, and optimise packet transmissions

- the first commercial LTE networks were deployed by Telia Sonera in
  Norway and Sweden in 2009 with Huawei and Ericsson as providers

- network infrastructure is based on IP protocols

- EUTRAN is the access network
  - EPC is the Core Network

- LTE defines two working modes:
  - FDD and TDD

- FDD uses a spectrum with sufficient frequency separation
  in order to allow a full duplex mode

- TDD can transmit and receive in the same band

> [!IMPORTANT]
> FDD works better for symmetrical applications like voice transmission
> TDD works better for asymmetrical traffic like data transmission via internet

---

#### EUTRA Protocols

##### OFDM Orthogonal Frequency Division Multiplexing

- OFDM uses a high number of subporters separated by 15KHz

- bandwidth in the channels may be:
  - 1.4, 3, 5, 10, 15, and 20MHz

- modulations that are used are QPSK, 16QAM, and 64QAM

- QPSK is a displacement modulation by phase type that uses
  the download channel from the first releases of 3G

- QAM is 90 degrees, 16QAM has 16 alternative signals, 4bits per signal

---

### Network Structure EPC & SAE

- EPC is described by SAE - it is the nucleus of an LTE network

- IP addresses is the final convergence point of all networks

### Self Organise Network SON

- most autonomy possible

- response to errors or incidents is supposed to be as automated as possible

- implementing a new network node is a huge cost

---

## Signals and Waves

### FDMA

- frequency division multiple access

- symbol time is long in comparison with the channel's engorgement

### TDMA

- time division multiple access

- multiple user access through TDMA
  - assigns time slots
  - no order

### CDMA

- code division multiple access

### OFDM

- orthogonal frequency-division multiplexing

- used in 3G to 4G transition

## 5G

## second exam questions
