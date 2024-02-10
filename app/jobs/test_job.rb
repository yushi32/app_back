class TestJob < ApplicationJob
  queue_as :default

  def perform
    puts "Hello from Sidekiq!"
  end
end
