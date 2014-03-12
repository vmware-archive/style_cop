# style_cop
Style Cop helps you enforce markup structure for front-end patterns via Rspec and Capybara. You spent all that time making your CSS play nicely. If all developers use the markup correctly, then it will render beautifully! 

## Hypothesis

1. We believe developers / designers have a problem sticiking w established DOM patterns, rather than page-overriding to tweak style.
2. We can fix it by creating momentum to "use or improve" front-end CSS patterns by breaking the build if a pattern is used incorrectly
3. We know we are right if a team thinks this is a good idea and uses it on a project, and they tweet a link to the repo.

## MVP

What's the least amount of work we can do to in/vadidate this hypothesis?

* A gem that targets Rails projects that use Hologram
* It automagically "enforces" DOM and style as defined in the Hologram live style guide

## Installation

Note: StyleCop depends on CapybaraWebkit so you will need to make sure that installs first: https://github.com/thoughtbot/capybara-webkit

Put into your gemfile

    gem style_cop
    
Bundle

    $ bundle
    
## Getting Started

To test a selector on your page matches the same selector on your styleguide
you will need to do two things:

1. Add the class 'style-cop-pattern' to the selector in your styleguide

2. Add code like this somewhere in an integration test:

```
    context "some context", style_cop: true do
      it "tests something" do
        visit "/some/path"
        selector = page.find(".your-selector")
        expect(selector).to match_styleguide(styleguide_page("/your/styleguide/path"))
      end
    end
```
