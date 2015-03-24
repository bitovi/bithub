require 'rails_helper'

RSpec.describe InviteCode, type: :model do
  let(:code) do
    FactoryGirl.create(
      :invite_code,
      code: 'mamatijetestzainvitecode',
      remaining_uses: 5,
      valid_until: 1.year.from_now
    )
  end

  describe '#use_up_if_useable' do

    it 'decreases the remaining_uses if the attribute is set' do
      expect do
        code.use_up_if_useable
      end.to change(code, :remaining_uses).by(-1)
    end

    describe "#has_remaining_uses" do
      it 'checks if the code has more remaining_uses' do
        expect(code.has_remaining_uses?).to be_truthy
      end
    end
      
    describe "#still_valid?" do
      it 'checks if the code has more remaining_uses' do
        expect(code.still_valid?).to be_truthy
      end
    end
  end

  describe '#either_has_uses_or_validity' do
    it 'check that the invite code has valid_until or remaining_uses' do
      code = InviteCode.create(code: 'mamatijetestzainvitecode')
      expect(code).not_to be_valid
      expect(code.errors.messages.keys.length).to eq 2
    end
  end
end
