# frozen_string_literal: true

def mock_review_task(review)
  task = double(:task)
  allow(review).to receive(:task) { task }
  allow(task).to receive(:marked_for_destruction?)
  allow(task).to receive(:reviews)
  allow(task).to receive(:valid?) { true }
  task
end
