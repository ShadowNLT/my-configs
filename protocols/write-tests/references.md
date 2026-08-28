# write-tests — source catalog

Canonical public source: [Google Testing Blog](https://testing.googleblog.com/). TotT was renamed Tech on the Toilet in 2024; older posts still use “Testing on the Toilet.” The live blog has on the order of 400 posts. This protocol is built from all 113 TotT episodes plus the non-TotT posts that teach how to write or choose tests. GTAC logistics, hiring, April Fools, and product-changelog posts are listed under “Recorded, do not use as write-time checks.”

Cite a rule by episode name when reporting a violation. Prefer the URL in this file over memory.

## Properties of a good test

- [What Makes a Good Test?](https://testing.googleblog.com/2014/03/testing-on-toilet-what-makes-good-test.html) — Erik Kuefler. Clarity, completeness, conciseness, resilience.
- [Effective Testing](https://testing.googleblog.com/2014/05/testing-on-toilet-effective-testing.html) — Rich Martin. Fidelity, resilience, precision.
- [Test Failures Should Be Actionable](https://testing.googleblog.com/2024/05/test-failures-should-be-actionable.html) — Titus Winters.
- [Writing Descriptive Test Names](https://testing.googleblog.com/2014/10/testing-on-toilet-writing-descriptive.html)
- [Naming Unit Tests Responsibly](https://testing.googleblog.com/2007/02/tott-naming-unit-tests-responsibly.html)
- [Truth: a fluent assertion framework](https://testing.googleblog.com/2014/12/testing-on-toilet-truth-fluent.html)
- [Truth 1.0](https://testing.googleblog.com/2019/07/truth-10-fluent-assertions-for-java-and.html)

## What to test

- [Test Behaviors, Not Methods](https://testing.googleblog.com/2014/04/testing-on-toilet-test-behaviors-not.html)
- [Test Behavior, Not Implementation](https://testing.googleblog.com/2013/08/testing-on-toilet-test-behavior-not.html)
- [Prefer Testing Public APIs Over Implementation-Detail Classes](https://testing.googleblog.com/2015/01/testing-on-toilet-prefer-testing-public.html)
- [Testing State vs. Testing Interactions](https://testing.googleblog.com/2013/03/testing-on-toilet-testing-state-vs.html)
- [Only Verify State-Changing Method Calls](https://testing.googleblog.com/2017/12/testing-on-toilet-only-verify-state.html)
- [Only Verify Relevant Method Arguments](https://testing.googleblog.com/2018/06/testing-on-toilet-only-verify-relevant.html)
- [Change-Detector Tests Considered Harmful](https://testing.googleblog.com/2015/01/testing-on-toilet-change-detector-tests.html)
- [It is not about writing tests, its about writing stories](https://testing.googleblog.com/2009/09/it-is-not-about-writing-tests-its-about.html)
- [Risk-Driven Testing](https://testing.googleblog.com/2014/05/testing-on-toilet-risk-driven-testing.html)
- [Understanding Your Coverage Data](https://testing.googleblog.com/2008/03/tott-understanding-your-coverage-data.html)
- [The Invisible Branch](https://testing.googleblog.com/2008/05/tott-invisible-branch.html)
- [Too Many Tests](https://testing.googleblog.com/2008/02/in-movie-amadeus-austrian-emperor.html)
- [Cost-Benefit Analysis of a Test](https://testing.googleblog.com/2008/03/cost-benefit-analysis-of-test.html)
- [Code coverage goal: 80% and no less!](https://testing.googleblog.com/2010/07/code-coverage-goal-80-and-no-less.html)
- [Code Coverage Best Practices](https://testing.googleblog.com/2020/08/code-coverage-best-practices.html)
- [Measuring Coverage at Google](https://testing.googleblog.com/2014/07/measuring-coverage-at-google.html)
- [Mutation Testing](https://testing.googleblog.com/2021/04/mutation-testing.html)

## How each test looks

- [Keep Tests Focused](https://testing.googleblog.com/2018/06/testing-on-toilet-keep-tests-focused.html)
- [Tests Too DRY? Make Them DAMP!](https://testing.googleblog.com/2019/12/testing-on-toilet-tests-too-dry-make.html)
- [Include Only Relevant Details In Tests](https://testing.googleblog.com/2023/10/include-only-relevant-details-in-tests.html)
- [Keep Cause and Effect Clear](https://testing.googleblog.com/2017/01/testing-on-toilet-keep-cause-and-effect.html)
- [Cleanly Create Test Data](https://testing.googleblog.com/2018/02/testing-on-toilet-cleanly-create-test.html)
- [Don't Put Logic in Tests](https://testing.googleblog.com/2014/07/testing-on-toilet-dont-put-logic-in.html)
- [Data Driven Traps!](https://testing.googleblog.com/2008/09/tott-data-driven-traps.html)
- [Prefer Narrow Assertions in Unit Tests](https://testing.googleblog.com/2024/04/prefer-narrow-assertions-in-unit-tests.html)
- [How I Learned To Stop Writing Brittle Tests and Love Expressive APIs](https://testing.googleblog.com/2024/04/how-i-learned-to-stop-writing-brittle.html)
- [Choosing Values for Robust Tests](https://testing.googleblog.com/2026/06/choosing-values-for-robust-tests.html)
- [EXPECT vs. ASSERT](https://testing.googleblog.com/2008/07/tott-expect-vs-assert.html)
- [Floating-Point Comparison](https://testing.googleblog.com/2008/10/tott-floating-point-comparison.html)
- [Literate Testing With Matchers](https://testing.googleblog.com/2009/09/tott-literate-testing-with-matchers.html)
- [Making a Perfect Matcher](https://testing.googleblog.com/2009/10/tott-making-perfect-matcher.html)

## Doubles

- [Increase Test Fidelity By Avoiding Mocks](https://testing.googleblog.com/2024/02/increase-test-fidelity-by-avoiding-mocks.html)
- [Know Your Test Doubles](https://testing.googleblog.com/2013/07/testing-on-toilet-know-your-test-doubles.html)
- [Fake Your Way to Better Tests](https://testing.googleblog.com/2013/06/testing-on-toilet-fake-your-way-to.html)
- [Keep Your Fakes Simple](https://testing.googleblog.com/2009/01/tott-keep-your-fakes-simple.html)
- [Don’t Overuse Mocks](https://testing.googleblog.com/2013/05/testing-on-toilet-dont-overuse-mocks.html)
- [Don’t Mock Types You Don’t Own](https://testing.googleblog.com/2020/07/testing-on-toilet-dont-mock-types-you.html)
- [Exercise Service Call Contracts in Tests](https://testing.googleblog.com/2018/11/testing-on-toilet-exercise-service-call.html)
- [Stubs Speed up Your Unit Tests](https://testing.googleblog.com/2007/04/tott-stubs-speed-up-your-unit-tests.html)
- [Interfacing with hard-to-test third-party code](https://testing.googleblog.com/2009/01/interfacing-with-hard-to-test-third.html)
- [When/how to use Mockito Answer](https://testing.googleblog.com/2014/03/whenhow-to-use-mockito-answer.html)

## Suite shape, sizes, E2E, UI

- [Test Sizes](https://testing.googleblog.com/2010/12/test-sizes.html) — Simon Stewart. Small / Medium / Large.
- [SMURF: Beyond the Test Pyramid](https://testing.googleblog.com/2024/10/smurf-beyond-test-pyramid.html) — Adam Bender.
- [Just Say No to More End-to-End Tests](https://testing.googleblog.com/2015/04/just-say-no-to-more-end-to-end-tests.html) — Mike Wacker.
- [Fixing a Test Hourglass](https://testing.googleblog.com/2020/11/fixing-test-hourglass.html) — Alan Myrvold.
- [What Makes a Good End-to-End Test?](https://testing.googleblog.com/2016/09/testing-on-toilet-what-makes-good-end.html)
- [How Much Testing is Enough?](https://testing.googleblog.com/2021/06/how-much-testing-is-enough.html) — George Pirocanac. Critical User Journeys.
- [Hermetic Servers](https://testing.googleblog.com/2012/10/hermetic-servers.html)
- [Testing UI Logic? Follow the User!](https://testing.googleblog.com/2020/10/testing-on-toilet-testing-ui-logic.html)
- [Web Testing Made Easier: Debug IDs](https://testing.googleblog.com/2014/08/testing-on-toilet-web-testing-made.html)
- [Automating tests vs. test-automation](https://testing.googleblog.com/2007/10/automating-tests-vs-test-automation.html)
- [But it works on my machine!](https://testing.googleblog.com/2007/09/but-it-works-on-my-machine.html)
- [Software Testing Categorization](https://testing.googleblog.com/2009/07/software-testing-categorization.html) — Miško Hevery.
- [Be an MVP of GUI Testing](https://testing.googleblog.com/2009/02/with-all-sport-drug-scandals-of-late.html)

## Determinism and flakes

- [Avoiding Flakey Tests](https://testing.googleblog.com/2008/04/tott-avoiding-flakey-tests.html)
- [Sleeping != Synchronization](https://testing.googleblog.com/2008/08/tott-sleeping-synchronization.html)
- [GUI Testing: Don't Sleep Without Synchronization](https://testing.googleblog.com/2008/10/gui-testing-dont-sleep-without.html)
- [Time is Random](https://testing.googleblog.com/2008/04/tott-time-is-random.html)
- [Simulating Time in jsUnit Tests](https://testing.googleblog.com/2008/10/tott-simulating-time-in-jsunit-tests.html)
- [Contain Your Environment](https://testing.googleblog.com/2008/10/tott-contain-your-environment.html)
- [My Selenium Tests Aren't Stable!](https://testing.googleblog.com/2009/06/my-selenium-tests-arent-stable.html)
- [Flaky Tests at Google and How We Mitigate Them](https://testing.googleblog.com/2016/05/flaky-tests-at-google-and-how-we.html) — John Micco.
- [Where do our flaky tests come from?](https://testing.googleblog.com/2017/04/where-do-our-flaky-tests-come-from.html) — Jeff Listfield.
- [Test Flakiness - One of the main challenges of automated testing](https://testing.googleblog.com/2020/12/test-flakiness-one-of-main-challenges.html)
- [Test Flakiness (Part II)](https://testing.googleblog.com/2021/03/test-flakiness-one-of-main-challenges.html)
- [Minimizing Unreproducible Bugs](https://testing.googleblog.com/2014/02/minimizing-unreproducible-bugs.html)

## Production code that makes tests cheap

- [Simplify Your Code: Functional Core, Imperative Shell](https://testing.googleblog.com/2025/10/simplify-your-code-functional-core.html)
- [Construct with Collaborators, Call with Work](https://testing.googleblog.com/2026/05/construct-with-collaborators-call-with.html)
- [Writing Testable Code](https://testing.googleblog.com/2008/08/writing-testable-code.html)
- [Guide to Writing Testable Code](https://testing.googleblog.com/2008/11/guide-to-writing-testable-code.html)
- [How to Write 3v1L, Untestable Code](https://testing.googleblog.com/2008/07/how-to-write-3v1l-untestable-code.html)
- [How to Think About the "new" Operator with Respect to Unit Testing](https://testing.googleblog.com/2008/07/how-to-think-about-new-operator-with.html)
- [To "new" or not to "new"](https://testing.googleblog.com/2008/10/to-new-or-not-to-new.html)
- [Where Have all the "new" Operators Gone?](https://testing.googleblog.com/2008/09/where-have-all-new-operators-gone.html)
- [Static Methods are Death to Testability](https://testing.googleblog.com/2008/12/static-methods-are-death-to-testability.html)
- [Singletons are Pathological Liars](https://testing.googleblog.com/2008/08/singletons-are-pathological-liars.html)
- [Where Have All the Singletons Gone?](https://testing.googleblog.com/2008/08/where-have-all-singletons-gone.html)
- [Root Cause of Singletons](https://testing.googleblog.com/2008/08/root-cause-of-singletons.html)
- [Using Dependancy Injection to Avoid Singletons](https://testing.googleblog.com/2008/05/tott-using-dependancy-injection-to.html)
- [Defeat "Static Cling"](https://testing.googleblog.com/2008/06/defeat-static-cling.html)
- [When to use Dependency Injection](https://testing.googleblog.com/2009/01/when-to-use-dependency-injection.html)
- [Constructor Injection vs. Setter Injection](https://testing.googleblog.com/2009/02/constructor-injection-vs-setter.html)
- [Breaking the Law of Demeter is Like Looking for a Needle in the Haystack](https://testing.googleblog.com/2008/07/breaking-law-of-demeter-is-like-looking.html)
- [To Assert or Not To Assert](https://testing.googleblog.com/2009/02/to-assert-or-not-to-assert.html)
- [Extracting Methods to Simplify Testing](https://testing.googleblog.com/2007/06/tott-extracting-methods-to-simplify.html)
- [Testing Against Interfaces](https://testing.googleblog.com/2008/07/tott-testing-against-interfaces.html)
- [The Way of TDD](https://testing.googleblog.com/2026/03/the-way-of-tdd.html)
- [How to get Started with TDD](https://testing.googleblog.com/2009/11/how-to-get-started-with-tdd.html)
- [Refactoring Tests in the Red](https://testing.googleblog.com/2007/04/tott-refactoring-tests-in-the-red.html)
- [Test first is fun!](https://testing.googleblog.com/2008/09/test-first-is-fun.html)
- [Test Driven Code Review](https://testing.googleblog.com/2010/08/test-driven-code-review.html)
- [Test Driven Integration](https://testing.googleblog.com/2010/06/test-driven-integration.html)
- [The Advantages of Unit Testing Early](https://testing.googleblog.com/2009/07/advantages-of-unit-testing-early.html)
- [Prefactoring: Clear the Way for Your New Feature](https://testing.googleblog.com/2026/07/prefactoring-clear-way-for-your-new.html)
- [Separation of Concerns? That's a Wrap!](https://testing.googleblog.com/2020/12/testing-on-toilet-separation-of.html)
- [Write Change-Resilient Code With Domain Objects](https://testing.googleblog.com/2024/09/write-change-resilient-code-with-domain.html)
- [Cost of Testing](https://testing.googleblog.com/2009/10/cost-of-testing.html)

## Planning (use when the question is strategy, not a single test)

- [How Much Testing is Enough?](https://testing.googleblog.com/2021/06/how-much-testing-is-enough.html)
- [The Inquiry Method for Test Planning](https://testing.googleblog.com/2016/06/the-inquiry-method-for-test-planning.html)
- [The 10 Minute Test Plan](https://testing.googleblog.com/2011/09/10-minute-test-plan.html)
- [A Tale of Two Features](https://testing.googleblog.com/2022/02/a-tale-of-two-features.html)

## Recorded, do not use as write-time checks

Keep these out of violation lists. They are org, conference, hiring, or general code health, not test construction.

- How Google Tests Software parts 1–7 (James Whittaker): SWE / SET / TE roles, ACC.
- GTAC call-for-papers, agendas, wrap-ups, scholarships.
- Jobs / Test Engineer career posts.
- April Fools.
- Code Health TotT that is not about tests: comments, nesting, boolean names, else-nuances, keep-sorted, small PRs, review etiquette, flag safe-defaults.
- Tool changelogs (Espresso, Protractor, EarlGrey, OSS-Fuzz announcements) except where they encode a rule already listed above.
- [Tech on the Toilet: Driving Software Excellence](https://testing.googleblog.com/2024/12/tech-on-toilet-driving-software.html) — history of TotT, not a test rule.
- [Sensenmann: Code Deletion at Scale](https://testing.googleblog.com/2023/04/sensenmann-code-deletion-at-scale.html) — dead code, not tests.
