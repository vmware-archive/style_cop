require 'spec_helper'

describe StyleCop::AssertStyle do
  subject{ StyleCop::AssertStyle.new(selector, rules, test_context) }
  let(:selector) { '.selector' }
  let(:rules) { double('rules') }
  let(:test_context) { double('test_context') }

  describe "has_correct_structure" do
    before do
      allow(test_context).to receive(:has_css?) { has_selector }
    end

    context "selector present" do
      let(:has_selector) { true }

      let(:rule1) { double('rule1') }
      let(:rule2) { double('rule2') }
      let(:element1) { double('element1') }
      let(:element2) { double('element2') }
      let(:node1) { double('node1') }
      let(:node2) { double('node2') }
      let(:rules) { [rule1, rule2] }

      before do
        test_context.stub_chain(:page, :all) { [element1, element2] }
      end

      it "calls an expectation on elements" do
        expect(test_context).to receive(:expect).with(element1).twice { node1 }
        expect(test_context).to receive(:expect).with(element2).twice { node2 }
        allow(node1).to receive(:to)
        allow(node2).to receive(:to)
        expect(test_context).to receive(:have_selector).with(rule1).twice
        expect(test_context).to receive(:have_selector).with(rule2).twice

        subject.has_correct_structure
      end
    end

    context "selector not present" do
      let(:has_selector) { false }

      it "raises a StandardError" do
        expect { subject.has_correct_structure }.to raise_error { |error|
          expect(error.message).to eq "Selector: .selector is not present."
          error.should be_a(StandardError)
        }
      end
    end
  end
end
