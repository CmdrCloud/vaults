# Development Integration Projects

## Project Preliminaries

- tuesday due date

- develop a project with some tables, build it with tables and some attributes,
  include what prof taught us, bd in word doc

- Develop in a .word format the following:
  - detailed description of the company or the project's study area
  - the following parts of a UML class diagram:
    - all basic classes
    - all generalisations of specifications
      - generalisation is another name for inheritance

---

### example of generalisation/inheritance

| Client | Employee | Provider |
| --------------- | --------------- | --------------- |
| IDClient | IDEmployee | IDProvider |
| name | name | name |
| address | address | address |
| clientType | antiguity | phoneNumber |

- Let's propose a singular table to get rid of the above redundancy

| Person |
| ---- |
| IDPerson |
| name |
| address |

---

#### Link to Persons <-> Clients table through inheritance

| Person |
| --- |
| IDClient: 5 |
| Juan Perez |
| Calle 1 este |
| 78541234 |

| Client |
| --- |
| IDClient: 5 |
| vip |
