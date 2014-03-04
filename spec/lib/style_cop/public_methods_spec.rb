require 'spec_helper'

describe StyleCop::PublicMethods do
  include StyleCop::PublicMethods
  let(:selector) {'.foo'}

  describe 'has_child' do

    it 'calls add_rule on RegisterStyle' do
      expect(StyleCop::RegisterStyle).to receive(:add_rule).with('> .foo')
      has_child selector
    end
  end

  describe 'has_nested_children' do
    let(:selector1) {'.foo'}
    let(:selector2) {'.bar'}

    it 'calls add_rule on RegisterStyle' do
      expect(StyleCop::RegisterStyle).to receive(:add_rule).with('> .foo > .bar')
      has_nested_children(selector1, selector2)
    end
  end

  describe 'register_style_structure_for' do
    let(:block) { lambda{} }

    context 'block is given' do
      it 'calls a new RegisterStyle' do
        expect(StyleCop::RegisterStyle).to receive(:new).with(selector, &block)
        register_style_structure_for(selector, &block)
      end
    end

    context 'no block is given' do
      it 'raises a no block error' do
        expect { register_style_structure_for(selector) }.to raise_error { |error|
          expect(error.message).to eq "No block given."
          error.should be_a(StandardError)
        }
      end
    end
  end

  describe 'assert_style_structure_for' do
    let(:rules) { double(:rules) }
    let(:assert_style_class) { double(:assert_style_class) }

    before do
      allow(StyleCop::RegisterStyle).to receive(:rules) { rules }
    end

    it "creates an AssertStyle object and calls has_correct_structure on it" do
      expect(StyleCop::AssertStyle).to receive(:new).with(selector, rules, self) { assert_style_class }
      expect(assert_style_class).to receive(:has_correct_structure)

      assert_style_structure_for(selector)
    end
  end
end
