# frozen_string_literal: true

require 'faker'

class Seeds
  def create_reporters
    return if Reporter.any?

    11.times { create_user('Reporter') }
  end

  def create_reviewers
    return if Reviewer.any?

    3.times { create_user('Reviewer') }
  end

  def create_workers
    return if Worker.any?

    5.times { create_user('Worker') }
  end

  private

    def create_user(employee_type)
      User.create(name: Faker::Name.name, email: Faker::Internet.email,
                  employee_type: employee_type)
    end
end

seeds = Seeds.new
seeds.create_reporters
seeds.create_reviewers
seeds.create_workers
