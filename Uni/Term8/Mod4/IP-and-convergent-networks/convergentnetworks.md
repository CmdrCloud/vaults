# Telephone IP and Convergent Networks

## Important terms

- IPSEC

- SIP (and its ports)

- IAX2 (and its ports)

- port

- RTP protocol

- Trunking & Trunks

- PBX
  - private telephone network used within a company to manage
  internal and external voice communications

- DNS (Domain name service)
  - assigns a domain name (example.com) to different hosts (IPs)

- TCP/IP
  - fundamental suite of protocols that allows
  communication through the internet

- Hard duplex
  - communication is only one way (sending, or receiving)

- Full duplex
  - communication flows both ways
  - no wireless network allows full duplex

- Commutation
  - switching in technical contexts

- Multiplexing
  - technique that combines multiple analogue or digital
  signals into a single signal over a shared medium

- TDM

- TDMA

- VLSM

- Gateway
  - The gateway IP is the interface that gives you access
  to the network.
  - IP address is after the network and before the broadcast.

- Network

- Subnet mask

- IP
  - The first three octets never change
  - The last octet can change

- LAN

- WLAN

- DHCP (dynamic host control protocol)

## Base information for formulas

- Erlang (E)
  - 3600s of traffic per hour

- CCS
  - 100s of traffic per hour

- BHCA
  - number of call intents at a peak hour

- AHT (average holding time)

- GOS

- VAD

The payload is useful to calculate the bandwidth

### Examples

one user talking for 60mins is 1 erlang

two users talking 30 mins each is 1 erlang

## Intro

| Deliverables | Grading |
| -------------- | --------------- |
| 1st Exam | 15 pts |
| 2nd Exam | 15 pts |
| Hmwk | 20 pts |
| Project | 50 pts |

| Dates |
| ------------- |
| 15th of May |
| 26th of May |
| Until 26th of May |
| 26th-2nd of June |

| Hardware Requirements |
| ------------- |
| Intel or AMD |
| RAM 16GB and Linux Debian x2 |
| 60GB (per VM) storage space |
| Softphones (linphone-xlite zoiper) |

| Knowledge Requirements |
| ------------- |
| TCP/IP |
| IPv4 |
| LAN Networks |
| Wireless Networks |

| Software Requirements |
| ------------- |
| VMWare (Broadcom) |
| Wireless Network |
| My cellphone |

## Summary of previous knowledge

**Example 192.168.10.0/24:**

- The subnet mask is the last part of the IP address, the slash part
  - It tells you how many bits you are using in each octet of the IP

**Bits:**

- 2^n is the amount of bits that the host has available (the last octet
in an IP address)

- You must save two bits for the broadcast and the network part of the
IP address. The broadcast is the very last part of the IP address.

- This ends up being `2^n - 2 (hosts)`

- The broadcast of the example IP is: `192.168.10.255`

- The gateway is the part that allows your network to go to another
network. If a host within your network wants to know if
another host in your network is active, it goes through the gateway.
This is called a ping (icmp).

- Switches don't need gateways, but routers absolutely do.

- The gateway of the IP is: `192.168.10.254`

- With the above broadcast, network, and gateway IPs, the hosts would
be:

192.168.10.1 <-> 253 (available host IPs for the network)

- Subnet mask: `255.255.255.0`

- DHCP is a protocol that allows you to automatically assign IPs

<- +significant bits 0 0 0 0 0 0 0 0 -significant bits ->

The more significant bits are on the left and the lesser ones are on the
right.

There is an exponent here (2^0, 2^1, 2^2, 2^3, etc.)
128 64 32 16 8 4 2 1

- If the prefix is not 24, and is 25 or 26, the subnet mask would look
like this:

255.255.255.128 (25 prefix)

why?

you have one bit left over after the last octet, and the leftmost
bit is the most important in this: 128 64 32 16, etc..

If you fill the leftmost bit, it is 128. The last octet in the mask
becomes 128.

If the prefix is 26, the next leftmost bit in the sequence is filled.
128 64. Add them together and you get 192. That means your subnet mask's
last octet is 192.

This is why if you want to know the size of the network, you have to look
at the subnet mask.

**Bits IPv4:**

32 bits

/24 - 32 bits => 8bits (host) => 2^8 => 256 hosts

256 hosts - 2 = 254 available host IP addresses.

/25 - 32 bits => 7bits => 2^7 => 128 hosts

128 hosts - 2 = 126 available host IP addresses.

and so on...

$$
/24 = 256\text{hosts}
$$
$$
 /25 = 128\text{hosts}
$$
$$
 /26 = 64\text{h}
$$

VLSM is dividing a network into smaller networks

## Telephony History

**Analogue Telephony (19th Century - End of 20th Century):**

- 1876: Alexander Graham Bell patents the telephone
- End of the 19th century: manual telephone calls
- 20th Century: telephone calls are automated
- 80s: tone (beeps) telephones are popularised

**Digital Telephone (80s - present-day):**

- Digital communication appears
- Multiplexing by time division allows the transmission of
various calls through the same channel
- digital integrated network services (RDSI) improve
quality and speed
- mobile telephony: 1G (analogue) and 2G (digital) are developed

**Telephony over IP (90s - present-day):**

- 90s: VoIP (voice over IP) allows transmission of voice through
data networks
- 2000s-today: services like Skype are popularised
- Telephony is developed based on softphones and IP-PBX servers,
such as FreePBX

### Telephony Definition

Traditional telephony, sometimes called "conventional telephony
service" allows conversations between distant people through
a public commute telephony network (RTPC).

In other words:

Telephony is what allows conversations between distant people
through a telephony network.

## Elements of a traditional telephony network

- Telephone terminal
- Access network
- Telephone centre
- Connection trunks
- Signal engineering
- Transmission mediums

**Telephone terminal:**

A device that works connected to a telephone centre and is wired.
This receives tones through a copper wire connection and the signal
that they receive is analogue.

**Connection trunks:**

These allow connections between the provider and the subscribers,
generally to PBXs.

**Signal Engineering:**

Signal engineering is the set of transmitted and received signals
in a communication network.

The objective of signal engineering is to exchange information
that guarantees aspects such as the correct configuration of the network
and the appropriate data flow.

**Transmission mediums:**

Transmission mediums for analogue telephones are copper wires,
twisted pair cables, and coaxial cables.

These are used to transmit audio signals which are then converted into
electronic pulses.

At the other end of the transmission, these pulses are translated again
into audio signals.

These mediums suffer from distance attenuation and noise.

**Commute networks in telephony:**

These are made up of interconnected nodes that exchange information.
RTB and RDSI.

**Foreign exchange subscriber:**

The external subscriber interface is the port that forwards the
analogue line to the subscriber.

The wall connection sends a call tone and a power source for the
battery.

**Foreign exchange office:**

The central external interface is the port that receives the analogue line.
This is a telephone plug, fax machine, or a central analogue telephone plug.

**PBX connection with FXS:**

FXO and FXS are always pairs, which is, they are similar to male-female plugs.

Without a PBX, the telephone is connected directly to an FXS port that the
telephone company provider...provides.

## Circuit Commutation

Circuit commutation is when a dedicated end-to-end circuit is established
before a connection occurs.

All of the resources on the way are reserved for the duration of the session.

This was used in the old times.

Think of the big phones that are in the streets, whenever you want to call through
one of those big phones, someone in the telephone service provider company
manually connects you to a line (they literally connect a line through with some
sort of cable) and then you can call someone through those big phones.

Today, data commutation is used, but this is the basis of everything.

### How does it work?

1. Establishment: a dedicated circuit is created between the sender and receiver
2. Transmission: data constantly flows through the circuit
3. Liberating: once finished, the circuit is freed for others to use it

### Characteristics

- Reserved bandwidth for the duration of the session
- Constant and predictable latency
- Inefficient if there is no data being transmitted (selfish resources)
- Examples: traditional telephony, TDM networks (time division multiplexing)

- Dedicated physical circuit
- Reserved bandwidth
- Reliable connection
- Traditional

## Packet Commutation

Data is divided into packets in a process called data segmentation and these
packets are sent independently of each other.

Each packet can take different routes and the resources are shared between
many users.

This is more modern.

### How it works

1. Division: data is segmented into packets
2. Routing: packets travel through a network through different routes
3. Rebuilding: at the receiving end, the packets are rebuilt

Rebuilding packets essentially rebuilds the original message.

### Key characteristics

- No reserving resources: bandwidth is shared between many users
- There may be losses
- Variable latency (depending on network saturation, etc.)
- More efficient and scalable
- Examples: Internet (IP), data networks, ethernet

## Differences between commutation types

| Aspect | Circuit Commutation | Packet Commutation |
| --------------- | --------------- | --------------- |
| Establishment | Requires establishing a circuit | Not required |
| Transmission | Reserved | Shared by all users |
| Route | Continuous data flow | Data segmentation into packets |
| Delivery | Unique and static flow | May vary for each packet's route |
| Latency | Constant and predictable | Unpredictable and variable |
| Efficiency | Inefficient if there are periods of inactivity | More efficient |

## Network Architectures

### Star network

This type of architecture has various devices connected to a central node
called a star, known as a hub or switch.

- Easy to manage and configure
- If a device fails, the rest are not affected

- If the central node fails, the entire network falls
- Requires lots of cabling

> [!NOTE]
> The central node could be anything, a switch, firewall, PBX, etc.

### Ring network

All devices are connected in a closed circle, and data travels through the network
in a single direction. Each device sends and receives data until the data reaches
its destination.

- Efficient if the number of devices is small
- If there is a dual ring, this allows for redundancy

- If a link fails, the whole network can be affected
- May be less flexible than other architectures

> [!NOTE]
> This is used in a very specific environment.

Another note:

> [!NOTE]
> Stacking

### Bus network

All devices are connected to a single central cable (the bus) which transports data
between devices.

- Cheap and easy to implement
- Requires less cabling than other architectures

- Performance is reduced as the number of devices is increased
- If the central cable fails, the whole network is affected

## Network architecture attributes

**Scalability:**

- The potential of a network to grow and adapt to more devices and traffic
without losing performance.

**Reliability:**

- The potential of a network to function correctly even if some of its components
fail.

**Cost:**

- The necessary budget to implement a network. This varies according to the
type of architecture, the amount of devices, and the cables that are needed.

**Security:**

- How the data and devices are protected within the network in order to prevent
unauthorised access.

## SIP Characteristics

- Network independent
  - SIP works on a variety of IP networks such as corporate networks, internet

- Scalability
  - Can be used for small scale services

- Interoperability

### Basic operations

SIP uses a client-server focus for signal engineering.
Communication is done through the exchange of SIP messages.

- User Agents (UAs)
  - End programs or devices that interact with users such as VoIP telephones,
  computers, or applications.

- SIP servers
  - Intermediary servers that manage UA requests, such as registry servers,
  proxies, and redirection servers.

### SIP components

**URL SIP:**

A SIP URL identifies a user within a network: sip:user@domain.com

**SIP Messages:**

These are requests and responses that are exchanged between SIP entities.

1001:user@192.168.40.2:5060

- 1001:omar@ (user)
- IP address (server)
- :5006 (port)

- SIP Requests: starts an INVITE action to start a call, and a REGISTER to register
a device

- SIP Response: responses to requests, indicating the result of the requested action

### SIP Session Life Cycle

- Establishment: a user requests to establish a session using an INVITE request.

- Modification: during the session, the communication params may be modified,
such as changing the audio codec.

- Termination: to end the session, a BYE request is sent.

### SIP Server Types

- Register server: registers the locations of UAs in a network

- Proxy server: forwards SIP requests between the client and other SIP servers
Also does routing

- Redirect server: redirects clients to a new destination for a SIP request

- Gateway: facilitates the connection between SIP networks and other networks
such as PSTN (red telefonica public conmutada)

### SIP call sequence route chart

### SIP Advantages

- Scalability

- Interoperability

- Flexiblity

### SIP Applications

- VoIP telephony: SIP is used a lot in VoIP systems, such as calling and
videocalling

- Videoconferences: SIP may manage videoconference sessions between users

- Instantaneous messaging: SIP may also be used for this

## IAX2

Inter-Asterisk Exchange 2

A protocol for signal engineering and transport developed by asterisk.
Open-source platform. Popular for VoIP.

Developed to solve traditional VoIP protocol problems like SIP.

### Objective for IAX2 use

IAX2 is used mostly to establish and manage voice and video comms in real time between
two or more devices.

The objective is to provide an efficient, optimised, and robust solution for
voice, video, and messages through IP networks.

### Key Characteristics of IAX2

- Traffic multiplexing

- Low bandwidth use

- Easy to go through firewalls and NATs

- Support for multiple codecs

### IAX2 Functionality

- Session establishment

- Signal engineering and transport through mediums

- Voice and video traffic management

> [!NOTE]
> difference between this and SIP is that SIP needs another channel purely for signaling
> IAX2 can put everything in a single channel

### IAX2 Messages

- Register
- Call
- Accept
- Reject
- Hangup
- Data

### IAX2 Components

- IAX2 Trunks
  - this is used to establish connections between two asterisk servers in
  different locations called trunks. These trunks allow the passage of calls
  through servers, optimising
  bandwidth and resource management.

- User Agents (UAs)

### Common uses

- VoIP telephony systems

- Trunking

- Private and corporate networks

### Disadvantages of IAX2

- Limited compatibility (not as much as a con in modern-day though)

- Integration problems (same thing, not as much of a con today)

### Recommended uses

- corporate telephony systems / unified communication systems

- heterogeneous environments

- remote and mobile users

- contact centres

- integration with apps and APIs!!!

```python
### Trunk

# [SERVERA]

context = incoming-iax
host = 192....102
qualify = yes
requirecalltoken = auto
secret = asdkfjvadi
trunk = yes
type = friend
username = SERVERA


# [SERVERB]
context = incoming-iax
host = 192....101
qualify = yes
requirecalltoken = auto
secret = asdkfjvadi
trunk = yes
type = friend
username = SERVERB
```

## G.729

**Type:** low bit compression rate
**Bitrate:** 8kbps
**Compression:** High LPC
**Quality:** Good voice quality, but slightly less than G.711
**Use:** Common in limited networks

## G.723.1

- type
  - ultra low bit rate compression

- bitrate
  - 6.3kbps or 5.3kbps

- compression is high

- quality
  - good for voice calls but inferior to g.729

- use
  - primarily used in VoIP applications in low-speed networks

- excellent bandwidth efficiency

- low voice quality

## G.726

- type
  - voice compression

- bitrate
  - 16kbps, 24, 32, 40

- compression
  - moderate ADPCM

- quality
  - high, but not as good as g.711

- use
  - common in links such as PBX

- pros
  - reasonable relationship between quality and bandwidth use

- cons
  - not as efficient as g.729 for low bandwidth calls

## Low bitrate codecs

### SPEEX

- open codec and low bitrate

- 2.15kbps to 44kbps

- compression is high

- quality is variable but can be low quality in low bitrates

- use in VoIP applications with low bitrates

- very efficient in bandwidth use

- voice quality may not be ideal in very low bitrates

### OPUS

- general purpose codec

- 6kbps to 510

- high compression

- excellent quality for voice and for music, even with low bitrate

- use in VoIP in real time such as videoconferences and voice calls

- high quality audio even with low bitrates and very efficient in latency

- may be more pricey in terms of processing

## Videoconference Codecs

### H.264

- codec for standard video

- depending on quality and resolution, between 500kbps and various mbps

- high compression

- use in videoconferences and video calls

- high efficiency in compression, and good image quality

- requires more bandwidth use and more processing power

### HEVC or H.265

- from 4k to 8k

### Factors for codec selection

- voice quality

- use of bandwidth

- latency

- compression

## Studying 14.05.2026

### Voice signaling Protocols

#### SIP

Session initialisation protocol is a signaling protocol used in
multimedia communications, such as VOIP, videoconferences,
instant messaging, and other real-time services.

SIP allows you to establish, modify, and terminate sessions between
two or more participants.

That's what the powerpoint presentation says.

What I understand is that it is a protocol for real-time communications.

##### SIP Use Objectives

SIP is used primarily to establish, manage, and terminate comms sessions.

It is a signaling protocol, not a transport protocol. This means that its
primary task is to negotiate communication characteristics such as
which audio or video codecs to use. Data processed by this is not transported
by the same protocol, that is handled by another protocol such as RTP or RTC.

Again, that's what the presentation says.

In my eyes, after reading this a bit, this is more like an internal processing
algorithm. Like training a model. In this case, the transport protocol would be
how to show the data the model has processed, which would be matplotlib.

##### SIP Characteristics (Study)

- Network independency
  - SIP works on a variety of IP networks such as corporate, private, and internet
  ones.

- Scalable

- Interoperability
  - SIP is compatible with other protocols and technologies.

##### SIP Basic Operations

SIP uses a client-server focus for signaling. Communication is done through
the exchange of SIP messages.

- UAs
  - End devices that interact with users.

- SIP Servers
  - Intermediary servers that manage UA requests, such as proxies.

##### SIP Components (Study)

**SIP URL:** a url that identifies a user within a network.

`sip:user@domain.com`

Think of when you had to set up the horrible linphone thing.

**SIP Messages:** requests and replies that are exchanged between SIP entities.

- Requests
  - these start an INVITE action to start a call
  - or a REGISTER action to register a device

- Responses
  - these are responses to the requests
  - they indicate the result of the request

So this functionality is basically just like a server with all of its codes

> [!NOTE]
> Quick side note about latency:
> The higher your ping, the more packets you put into your transmission
> but that also means that your latency goes up and it stutters
