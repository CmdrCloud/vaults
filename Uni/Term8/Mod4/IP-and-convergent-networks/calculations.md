- Erlang (E)

- CCS

- BHCA

- AHT

- GOS

- VAD

$$
	1e = \frac{3600s}{100s} \implies 35ccs
$$
$$
	E = \frac{N*T}{3600}
$$
Where:

- E 
	- Erlangs

- N
	- Number of calls at a peak hour

- T
	- Average duration in seconds

## Erlang B Formula
$$
	m = E * B
$$

Where:

- E is traffic in erlangs
- m is the number of channels
- B is the probability of getting blocked (%GoS)

### Erlang C Formula

$$
	N = \frac{E}{P}
$$

Where:

- E is Erlangs
- N is the number of agents
- P is the % occupied (queued calls)

## Calculating concurrent calls

Let's say:

Users = 1000
Number of calls per user per month = 150
Average call duration = 180s
Simultaneous calls = 15%

$$
	\text{Total monthly calls} = \text{users} * \text{calls}
$$
$$
	\text{Average calls per hour} = \frac{\text{total monthly calls}}{\text{operation hours}}
$$

$$
	\text{Calls at peak hours} = \text{Average calls per hour} * \text{simultaneous calls}
$$

$$
	\text{Erlang traffic} = \text{Calls per peak hour} * \frac{\text{average call duration}}{3600}
$$

## Codecs

$$
	\text{Payload (bytes)} = \frac{\text{codec bitrate} * \text{segmentation time}}{8}
$$

Let's say:

- Segmentation time = 20ms


$$
\text{Packets per second} = \frac{1000ms}{20ms} \implies 50pps
$$


## Calculating bandwidth

- why is this multiplicative?
$$
	\text{Total BW} = \text{payload} * \text{headers} * \text{packets per second} * 8 bits
$$

