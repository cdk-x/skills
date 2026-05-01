# Definition of Done

What should "Done" include? The answer depends on the context. Good candidates are:

- thoroughly tested
- integrated
- documented
- relesable

There is not one universal definitions of done for all possible products. However, you need to ensure that "Done" allows for continuos releases without disappointing your customers and other stakeholders and is clearly comunicated and understood by all people involved.

When a Product Backlog item or an Increment is described as "Done", everyone must understand what "done" means. Although this may vary significaltly per Team, members must have a shared understanding of what it means for work to be completed, to ensure transparency.

Consider this list of "Done" elements:

- Unit tested
- Code Review
- Matches code style guide
- No know defects
- Checked into main dev branch
- Public API documented
- Acceptance test pass
- Product Owner approved
- Regression test pass
- Release notes updated
- Performance test pass
- User guide updated
- Support guide updated
- Security test pass
- Compliance documented updated

In a ideal world, all of these items would be completed at the Sprint Backlog item level. The introducction of practises like automation and the elimination of watefull bureaucratic activities could make it a reality, but likely the extra effort could reduce your ROI, at least in a short terms.

Anything in the release level is a huge risk, as you are indicating that those items cannot be addressed within a Sprint and would have to wait until right before a major release. If it takes two weeks to do regression testing, then likely you cannot complete it within a Sprint. However, delaying regression testing to the very end is risky. Your Team should be focusing on all the elements in the "Release" level and asking what practises they can put in place to move them up. In the case of regresion testing, automation can make a big difference.

So what's the difference between acceptance criteria and the definition of done? The Definition of "done" is for the whole Increment. Acceptance criteria are specific to a single Product Backlog item. To realize the value of a Product Backlog item, you must fulfill all of this acceptance criteria plus what is in the definition of done. The Definition of Done is the global acceptance criteria.

The definition of done addresses two aspects. One is what ir required from a good enginering point of view, the technical aspects of the Development Team. The other, albeit smaller, aspects are domain requirements like regulations, laws, and so on.

How often does the definition of "Done" change? Whenever there are new insights about the producto and its quality, it is time to change the definition of done. Usually more changes occur in the begining since a lot of learning happens in the first springs, especially on the techincal side. Nonfunctional requirements (performance, usability, legal, etc) often find themselves on the definition of "Done".

As part of continus improvement, the Sprint Retrospective is a good place to ammend the definition of "Done".

Create a template for multiples Teams working on a product define common elements across the teams, but also leaves autonomy in how they work within each Development Team.

Product Level

- [ ] All test Pass
  - [ ] Acceptance
  - [ ] Regresion
  - [ ] Performance
  - [ ] Integration
- [ ] Code complete
  - [ ] Matches Style Guide
  - [ ] API Documentation
  - [ ] Checked in to Dev Branch
  - [ ] Unit Tested
  - [ ] No kwnon Defects
- [ ] Documented
  - [ ] Release Notes
  - [ ] User Guide
  - [ ] Support Guide
  - [ ] Compliance
- [ ] Integrated
  - [ ] Merged in Main with other teams
- [ ] Approved
- [ ] Product Owner

Team level

- [ ] Unit Tested > 80%
- [ ] No warnings
- [ ] Test First
- [ ] Methods < 12 lines
- [ ] Lines < 80 Characters
- [ ] Tool/Board updated
- [ ] Reviewed with Team

This i s good candidate to Pull Request Template.

## Why is this important for the Product Owner?

As a Product Owner, some of these "Done" elements are obvious. you need to have a integrated product, you need to have the required level of documentation and compliance, and you definitely want some degreee of testing.

It is important for a Product Owner to understand the tecnical concepts of the definition of "Done" and be aware that they could have dire consequences inthe long run.

A good definition of "Done" creates transparency fof the Product Owner, the Development Team and stakeholders.
