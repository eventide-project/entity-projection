require_relative 'interactive_init'
require 'messaging/postgres'

logger = Log.get('Projection Test')

logger.info "Starting", tag: :test

module Events
  class Deposited
    include Messaging::Message

    attribute :amount, Numeric
    attribute :time, String
  end

  class Withdrawn
    include Messaging::Message

    attribute :amount, Numeric
    attribute :time, String
  end
end

class Account
  include Schema::DataStructure

  attribute :balance, Numeric, default: 0
  attribute :time, Time

  def deposit(amount)
    self.balance += amount
  end

  def withdraw(amount)
    self.balance -= amount
  end
end

class Projection
  include EntityProjection
  include Events

  entity_name :account

  apply Deposited do |deposited|
    account.deposit(deposited.amount)
    account.time = Time.parse(deposited.time)
  end

  apply Withdrawn do |withdrawn|
    account.withdraw(withdrawn.amount)
    account.time = Time.parse(withdrawn.time)
  end
end

deposited = Events::Deposited.build({
  amount: 11,
  time: Clock::UTC.iso8601
})

withdrawn = Events::Withdrawn.build({
  amount: 1,
  time: Clock::UTC.iso8601
})


account_id = Identifier::UUID::Random.get
logger.debug "Account ID: #{account_id}", tag: :test

stream_name = Messaging::StreamName.stream_name(account_id, 'account')
logger.debug "Stream Name: #{stream_name}", tag: :test

batch = [deposited, withdrawn]

Messaging::Postgres::Write.(batch, stream_name)
logger.debug "Wrote batch", tag: :test
logger.debug batch.pretty_inspect, tags: [:test, :data]


account = Account.new

EventSource::Postgres::Read.(stream_name) do |event_data|
  logger.debug "Read event data", tag: :test
  logger.debug event_data.pretty_inspect, tags: [:test, :data]

  Projection.(account, event_data)

  logger.info "Projected event data (Type: #{event_data.type}, Amount: #{event_data.data[:amount]})", tags: [:test, :data]
  logger.info account.pretty_inspect, tags: [:test, :data]
end

