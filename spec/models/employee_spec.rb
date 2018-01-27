# frozen_string_literal: true

require "rails_helper"

RSpec.describe Employee, type: :model do
  before { @employee = Employee.new(type: "Reviewer") }

  subject { @employee }

  it { is_expected.to respond_to(:type) }

  it { is_expected.to have_one(:user) }

  it { is_expected.to be_valid }

  it { is_expected.to validate_presence_of(:type) }

  describe "#user" do
    describe "destroying employee" do
      it "nullifys employee" do
        employee = Fabricate(:reviewer)
        user = Fabricate(:user, employee: employee)

        expect do
          employee.destroy
          user.reload
        end.to change(user, :employee_id).to(nil)
      end
    end
  end
end
