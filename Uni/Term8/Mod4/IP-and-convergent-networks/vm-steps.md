# VM Steps

- There is a channel between your two PBXs

- You have to connect to your mobile data network

- Your PBXA will connect to a softphone such as Zoipher or Linphone

- Your other PBX will connect to a different softphone

- The only difference between the above two is that one of your
PBXs will connect to a different NAT network

- Between both of these PBXs and apart from the trunk channel, there
is an AP.

- Your softphone connected to a different NAT network will have a
SIP client connected to its respective PBX.
  - Both of these, actually (5060 port with UDP protocol)

- These are two completely different networks. These two networks
are there to connect your VMs to your machine.

- Extensions are the dialup numbers for your VMs.
  - One vm could have the 1001 number and the other could be 2001
  - the above is because the range of these dialups for each PBX
  is like so: `1000-1999, 2000-2999, etc.`

- When you finish connecting your VM to a PBX, you will need to connect
that PBX to the AP.
  - To do that, you need to have an outgoing route and an inbound route.
  The inbound route is to receive calls and the outbound route is to send
  calls.

- In your softphone:
  - 1001@IP:5060
  - ISSABEL password (andreas, pass: gbn5)

Where the IP is the PBX IP address.

## Prerequisites

- Have a clone of your ISSABEL VM ready after its complete installation.

- Get another NAT network adapter for each VM
  - this is to have two different networks
