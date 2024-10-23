# frozen_string_literal: true

require 'rails_helper'

describe ServiceBase do
  let(:service) { described_class.new }

  describe '.success?' do
    let(:result) { service.success? }

    context 'with errors' do
      before do
        service.send(:add_errors, 'error')
      end

      it 'returns false' do
        expect(result).to be false
        expect(service.errors).to eq(['error'])
      end
    end

    context 'without errors' do
      it 'returns true' do
        expect(result).to be true
      end
    end
  end

  describe '#error_messages' do
    let(:standard_error_msg) { 'Standard Errors' }
    let(:active_model_error_msg) { 'acitve model error' }
    let(:error_string_msg) { 'error string' }

    before do
      service.send :add_errors, StandardError.new(standard_error_msg)

      errors = ActiveModel::Errors.new(User)
      errors.add(:base, active_model_error_msg)
      service.send :add_errors, errors

      service.send :add_errors, error_string_msg
    end

    it 'returns error messages' do
      expect(service.error_messages).to match_array([standard_error_msg, active_model_error_msg, error_string_msg])
    end
  end

  describe '#has_error_class?' do
    let(:standard_error_msg) { 'Standard Errors' }

    before do
      service.send :add_errors, StandardError.new(standard_error_msg)
    end

    context 'when with error class' do
      it 'returns true if found' do
        expect(service.has_error_class?(StandardError)).to eq(true)
      end

      it 'returns false if not found' do
        expect(service.has_error_class?(ArgumentError)).to eq(false)
      end
    end
  end
end
