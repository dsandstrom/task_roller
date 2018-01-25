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

  def create_categories
    return if Category.any?

    rand(11).times do
      name = Faker::Commerce.department
      name = Faker::Commerce.department while Category.find_by(name: name)

      Category.create(name: name, visible: random_visible,
                      internal: random_internal)
    end
  end

  def create_projects
    Category.all.each do |category|
      next if category.projects.any?

      rand(11).times do
        name = Faker::App.name
        name = Faker::App.name while category.projects.find_by(name: name)

        category.projects.create(name: name, visible: random_visible,
                                 internal: random_internal)
      end
    end
  end

  private

    def create_user(employee_type)
      User.create(name: Faker::Name.name, email: Faker::Internet.email,
                  employee_type: employee_type)
    end

    def random_visible
      rand(2).zero?
    end

    def random_internal
      rand(4).zero?
    end
end

seeds = Seeds.new
seeds.create_reporters
seeds.create_reviewers
seeds.create_workers
seeds.create_categories
seeds.create_projects
