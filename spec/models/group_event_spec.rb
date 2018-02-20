require 'rails_helper'

RSpec.describe GroupEvent, type: :model do

  let(:draft_group_event) { GroupEvent.new(user_id: 1, name: 'Demo Project Event', start_at: 2.days.from_now, duration: 30.days) }
  let(:published_group_event) { GroupEvent.new(user_id: 1, start_at: 2.days.from_now, duration: 30, location: 'CA', description: 'event scheduled', name: 'Event Name' ) }

  it 'must be valid when status is draft' do
    expect(draft_group_event.status).to eq GroupEvent::STATUSES[:draft]
    expect(draft_group_event.valid?).to eq true
  end

  it 'must be valid when status is published' do
    published_group_event.status = GroupEvent::STATUSES[:published]
    expect(published_group_event.status).to eq GroupEvent::STATUSES[:published]
    expect(published_group_event.valid?).to eq true
  end

  it 'must be invalid when status is published and with limited data' do
    draft_group_event.status = GroupEvent::STATUSES[:published]
    expect(draft_group_event.status).to eq GroupEvent::STATUSES[:published]
    expect(draft_group_event.valid?).to eq false
  end

  it 'should be delete status when event deleted' do
    published_group_event.status = GroupEvent::STATUSES[:published]
    published_group_event.save
    expect(published_group_event.status).to eq GroupEvent::STATUSES[:published]

    published_group_event.status = GroupEvent::STATUSES[:deleted]
    expect(published_group_event.valid?).to eq true
    published_group_event.save

    published_group_event.reload
    expect(published_group_event.status).to eq GroupEvent::STATUSES[:deleted]
  end

  it 'must be valid end_at when start_at and duration passed' do
    published_group_event.start_at = 2.days.from_now
    published_group_event.duration = 4.days
    published_group_event.end_at = nil
    published_group_event.status = GroupEvent::STATUSES[:published]
    published_group_event.save

    expect(published_group_event.end_at).to eq(published_group_event.start_at + published_group_event.duration.days)
  end

  it 'must be valid duration when start_at and end_at passed' do
    published_group_event.start_at = 2.days.from_now
    published_group_event.duration = nil
    published_group_event.end_at = published_group_event.start_at + 4.days
    published_group_event.status = GroupEvent::STATUSES[:published]
    published_group_event.save

    expect(published_group_event.duration).to eq(published_group_event.end_at.mjd - published_group_event.start_at.mjd)
  end

  it 'must be valid start_at when end_at and duration passed' do
    published_group_event.start_at = nil
    published_group_event.duration = 4.days
    published_group_event.end_at = 10.days.from_now
    published_group_event.status = GroupEvent::STATUSES[:published]
    published_group_event.save

    expect(published_group_event.start_at).to eq(published_group_event.end_at - published_group_event.duration.days)
  end
end