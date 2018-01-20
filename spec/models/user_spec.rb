# frozen_string_literal: true

require "rails_helper"

RSpec.describe User, type: :model do
  let(:reviewer) { Fabricate(:reviewer) }

  before do
    @user = User.new(name: "User Name", email: "test@example.com",
                     employee_id: reviewer.id)
  end

  subject { @user }

  it { is_expected.to respond_to(:name) }
  it { is_expected.to respond_to(:email) }
  it { is_expected.to respond_to(:employee_id) }

  it { is_expected.to belong_to(:employee) }

  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_presence_of(:email) }
  it { is_expected.to validate_uniqueness_of(:email).case_insensitive }
  it { is_expected.to validate_presence_of(:employee_id) }

  describe "#employee" do
    describe "destroying user" do
      it "destroys employee" do
        employee = Fabricate(:reviewer)
        user = Fabricate(:user, employee: employee)

        expect do
          user.destroy
        end.to change(Employee, :count).by(-1)
      end
    end
  end
end
