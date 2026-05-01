# what is a requirement

All requirements fallinto one of these categories:

1. How/why someone uses the system = Functional
2. how the system should behave = NonFunctional (stability, usability, performance, etc)
3. The rules that surround the existing business domain (e.g formulas, processes, laws, etc)

The level of the detail needed depends on your goal.

In some situations, the requirement documents may have value to the bussiness. If lives are on the line, you may be need to specify more detail. Fixed price vendor contracts may need more documentation.

However, the reality of the vast majority of product development work today is that more value comes in representing stakeholders needs that in capturing details.

Instead, consider creatins a big to-do-list for the product where the intent is not to capture detail; the intent is to not forget to ask al the right questions, either upfront or somewhere down the road.

Each to-do-list item is nothing more than a reminder to get something done.

The details will be captured along the way, while you strive to better understand the underlying customer need, as aceptance criteria, tests, diagrams, conversation, and so on.

## Product backlog
The prodcuct backlog is a orderer list of everthing that is known to be needed in the product. Is the single source of requirements for any changes made to the product. The product owner is reponsible for the Product Backlog, including its content, availability and ordering.

The Product Backlog is open to all types of work.

- Feature Request: Any request from a stakeholder.
- NonFunctional Requirements: Quality of the system.
- Experiments: Functionality that is release to productions to test the marketplace, also experiments can be "enabling constrains".
- User Story: Placeholders for conversations popular in the agile community.
- Bugs/defects: Problems that have arisen from a previos release.
- Use Cases: List of actions between an actor and a system (not as common these days)
- Capabilities: Different way or channels to access existing funcionality.

## User story
As a "actor", I want "feature", so that "benefit"

How an user story should be:

### INVEST is a useful memonic.

- **Independent**: Independent stories are teh easiest way to work with. That is, we'd like them to not overlap in concept, and we'd like to be able to schedule and implement them in any order.
- **Negociable**: A good story is negotiable. It is not an explicit contract for features; rather, details will be co-created by the customer and programmer during development. A good user story captures the essence, not the details. Overtime, the card may acquire notes, test, ideas, and so on, but we do not need theese to prioritize or schedule stories.
- **Valuable**: A user story needs to be valuable. We do not care about calues to just anybody; it needs to be valuable for the customer. Developers may have (legitimate) concerns, but these should be framed in a way that makes the customer percieve them as important.
- **Estimable**: A good user story can be estimated. We do not need an exact estimate, but just enough to help the customer rank an schedule the story's implementation. Being estimate is partly a function of beaing negotiated as it is hard to estimate a story we do not understand.
- **Small**: Good story tends to be small. Stories typically represents at most a few person-weeks' worth of work. Above this size, it seems to be too hard to know what it is in the story's scope. Saying "it would take me more that a month" often implicity adds, "as i do not understand what-all it would entail". Smaeller stories teng to get more accurate estimates.
- **Testable**: A good story is testable. Writing a story card carries an implicit promise: "I understand what I want well enough that I could write a test for it". Several teams have reported that by requiring customer test before implementing a story, the team is more productive. "Testability" has always been a characteristic of good requirements; actually writing the test early helps us know whether this goals is met.

### DEEP 
- **Detail Enough**: acceptance criteria to get started
- **Emergen**: The product backlog is necer "complemte"; it is refined over time.
- **Estimated Relatively**: size in terms of effort
- **Prioritized Orderer**: by value, risk, cost, dependencies. etc etc

## NonFunctional Requirements

Requirement that fall into any of the following categories are considerer nonfunctional:

- Usability
- Scalability
- Portability
- Maintanability
- Availability
- Accesibility
- Supportability
- Security
- Performance
- Cost
- Legal and compliance
- Cultural

Funtional requirements describe what the systema should do, whereas nonfunctional requirements describe what the system should be.

Capture your nonfuncionatl requirements on one of the following three ways:

#### **As a Product Backlog**:
As nonfunctional requirements do have direct value to the bussiness, it is perfectly acceptable to capture them on the product Backlog, possibily even as an user story.
#### **As acceptance criteria**
Another options for nonfunctional requirements is to capture them as acceptance criteria for the particular Product Backlog item. That way, the nonfunctional requirement is completed as part of a larger functional item and may affect the effort needed to complete it.
#### **As part of the definition of done**
If the same nonfunctional acceptance criteria seem to apply across most of your Product Backlog items then consider anchoring it in the definition of done as the are omnipresence.

## Epics
Stories thar are too large to implement in one Sprint are commonly refered to as epics (long stories). having epics in your product backlog is not necesary a bad thing. In fact, epics are often a crucial building block in a wide-reaching Product Backlog. however, at some point, you need to split the epic into more manageable stories.

## Acceptance Criteria

Acceptance Criteria define what the customer will see to approve the work as being complete. They can be written as test cases or something less detailed. although acceptance criteria are owned by the Product Owner, it is crucial to involve the whole team, when defining them.

### Given, When, Then (gherkin syntax)
Gherkin syntax server two purpose - documentation and automated test. The grammar is readable by anyone, yet it is algo parsable by test automation tools, like Cucumber.

Given: a precondition
When: a user actions ocurrs
Then: an expected result



