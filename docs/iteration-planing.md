# Iteration Planning

A Release Plan is an excellent high-level view of how a team intends to deliver the most valuable product they can. However, a release plan provides only the high level view of the productos being built. It does not provide the short-term, more detailed view that temas use to drive the work that ocurrs within an iteration. With an iteration plan, a team takes a more focused, detailed look at what will be necesasary to implemente completely only those user stories selected for the new iteration.

An iteration plan is created in an iteration plan meeting. This meeting should be attended by the product owner, analyst, programmer, tester, database engineer, user interacction designers, and so on. Anyone involved in taking a raw idea and turning it into a funtioning product should be present.

The team may walk out of an iteration planning meeteing and immediately type cards into a software system. If the desire, but they are very real benefit to using crds during the meeting.

One of the most significant advantages to using note cards during iteration planning is that it allows everyone to participate in the process.

## Tasks are not allocated during iteration planning

Before looking the things tat are done during iteration planning, it's important to clarify one thins it not done. While planning an iteration, tasks ar not allocated to specific individuals.

Individuals do not sing up for taskw until iteration begins and generally sing up for ony one or two related tasks at a time. New tasks are not begun until previously selected ones are completed.

## How a Iteration plan and Release plan differ

The Release Plan looks forward through the release of the product, usually to six months out at the start of a new project. In contrast, the iteration plan looks ahead only the lengh of one iteration, usually two to four weeks. The user stories of a release plan are estimated in story points or ideal days, the tas on the iteration plan are estimated in ideal hours.

The primary purpose of iteration planning is to refin suppositions made in more coarse-grained release plan. The Release Plan is usually intentionally vague about the specific order in whicn user sotires will be worked on. Planning the iteration as it begins allows the teams to make use of their recently acquired knowleadge. Agile planning purpose becomes a two-stage process. The first stage is the release plan, with a rough edges and general uncertainties. The second stage is the iteration plan. An iteration plan still has some rough edges and continues to be uncertain. However, becasue it is created concurrent with the start of a new iteration, an inteartion plan is more detailed that a release plan.

## Velocity-Driven Iteration Plan

The team collaboratively adjust priorities. They may have learned something in the preciding iteration that alters their priorities. Next, they identify the target velocity for the comming interation. The team then selects an interation goal, which is a general description of what they wish to accomplish during the comming iteration. After selecting an interation goal, the team selects the top-priority user stories that support that goal. As many stories are selected as necessary for the sum of theis ideal-day or story-point estimates to equel  the target velocity. Finally, each selected story is split into tasks, and each task is estimated.

### Adjust Priorities

One source of changes to priorities is the iteration review meeting, which is held after an iteration is finished. During the iteration review, the new functionality and capabilities that were added during the iteration are demostrated to stakeholders, the extended project community, and anyone else who is interested. Valuable feedback is often received during these iteraction reviews.  The product owner herself shoud generally not come up with new ideas or changes during the iteration review, because she is involved daili throughout the iteration.

In many organizations I`ve found it useful to hold a prioritization meeting a few days before teh start of a new iteration. I do this to fit the iteration review an dthe iteration planning meeting into the same day more easly.

The Product Owner conducts the prioritization meeting and involves anyone she thinks can contribute to a discussion of the project`s priority. After having this meeting, the product owner can usually quickly and on the fly adjust priorities based on anything happens during the iteration review.

### Determine Target Velocity

The next step in velocity-driven iteration planning is to determine the team's targe velocity. 

If a team has not worked together before or is new to their agile process, they will have to forecast velocity.

### Identify an Iteraion Goal

With their priorities and target velocity in mind, the team identifies a goal they would like to achive during the iteration.

The iteration goal is a unifying statement about what will be acommplished during the iteration.

### Selected User Stories

The product owner and team select stories that combine to meet the iteration goal.

In selecting the storires to work on, the product owner and team consider this priority of each story.

### Split user Stories into Tasks

Once the appropiated set of user stories has been selected, each is decomposed into the set of task necessary to deliver the new functionality.

A common questions around iteration planning is what should be included. All tasks necesarry to go form user story to a functioning, finished products should be identified.

#### Include only work that adds value to this project

The iteration plan should identify only those task that add immediate value to the current project. Analysis, desing, coding, testing, user interface design and so on. Don´t include the hour in the morning when you answer emaails. Yes, some of those emails messages are project-related, but tasks like "answer email", 1 hour should not be included in a iteraction plan.

Suposse you need to meet with the company's director of personel about the new annnual review process. That should not be included in the iteractions plan.

#### Be specific until it's a habbit

new agile teams are often not familiar with or skilled at writing automated unit test. However, this is a skill they work to cultivate during the first few iterations. During that period, I encorauge programmers to identify and estimate unit testing task explicitly.

#### Meeting count (a lot)

You should identify, estimate and include tasks for meetings related to ehe project. When estimating the meeting, be sure to include the time for all participants, as well as any time spent preparing for the meeting. Suposse the team schedules a meeting to discuss feedback from users. All seven teams members plan to attend one-hour meeting, and the analyist plans to spend two hours preparing the meeting. The estiamte for his task i nine hours. I usually enter this into the iteration plan as a single nine-hour task, rather than as seprate task for each team member.

#### Bugs

An agile team has the goal of fixing all bugs in the iteration in which they are discovered. They become able to achive this as they become more proficient in working in short iterations, especially through relying on aytomated testing.

A defect found later is treated the same way as a user story. Fixing the defect will need to be prioritized into a subsequent itearion in the same way that any other user story would be. Outside an iteration, the whole idea of a defect starts to go away. Fixing a bug and adding a feature become two ways of describin the same things.

#### Handling dependencies

Often, developing one user story will depends upon the previuosly implementation of another. In most cases, these dependencies ar not a significant issue. There is usually what I consider a natural order to implementing a user story.

#### Work that is dificult to split

Some features are especially difficult to split into tasks. 

A spike is a task included in a iteration plan that is being undertaken specifically to gain knowleadge or answer question. In this case, the team did not have a good guess at something, so they created two tasks: one a spike and one a placeholder with a guess at the duration. The spike would help the team learn how they'd approach the other task, which would allow them to estimate it.

### Estimate Tasks

The next step in velocity-driven iteration planning is to estimate each task. Task estimates are expresed in ideal time. So if I thing that a task will take me six hours of working time, I give it an estimate of six hours. I do this even if six hours of time on the tas will take me an entire eight-hour day.

Task estimating on an agile project should be a group endeavor. For reasons:

1. Because tasks are not allocated to specific indiviauls during iteration planning, it is imposible to ask the specific person who will do the work.
2. Even though we expect a specific individual will be the one to do a task, and even though he may know the most about that task it does no t mean taht other have nothing to contribute.
3. Hearing how long something is expected to take often helps teams identify misunderstandings about a user story task. Upon hearing an unexpectedly high estimate, a product owner or analyst may discover that the team is heading toward a more detailed soluciont thatn necessary.
4. When the person who will do the work provides the estimate, the person's pride and ego may make him reluctant to admit later that an estimate was incorrect. When an estimate is made collaboratively, this reluctance to admit an estimate is wrong goes aways.

#### some desing is OK

The product owner, analysts, and user interface designers may discuss product design, how much of a feature should be implemented, and how it will appear to users. The developers may discuss options of how they will implemente what is needed. Both types of design discussion are needed and appropiate. The best warning sign of taking the design too far during iteration plan. Save those discussions for outside iteration planning.

#### The righ size for a task

The task you create should be of an approxmate size so that each developer is able to finish an average of one per day. This size works well for allowing work to flow smoothly through your agile team development process. Larger tasks tend to get bottled up with a developer or two, and the rest of the team can be left waiting fo rthem to complete de task.