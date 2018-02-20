require 'spec_helper'

describe V1::GroupEvents do
  include RSpec::Matchers  
  def input_params
    {
        group_event: {
            start_at: 1.week.from_now,
            duration: 30,
            location: 'New York',
            description: 'description goes here',
            name: 'Demo Project Event',
            is_published: true
        }
    }
  end

  it 'Get List of Group Events' do
    params = input_params.clone

    1.upto(5).each do |i|
      params[:group_event][:start_at] = i.days.from_now
      post '/api/v1/users/1/group_events',params.to_json, 'Content-Type' => 'application/json'
    end

    group_events = GroupEvent.all
    get '/api/v1/users/1/group_events',params.to_json, 'Content-Type' => 'application/json'
    json_response = JSON.parse(response.body)

    expect(response.status).to eq 200
    expect(json_response.size).to eq(group_events.size)

    ge_ids = json_response.collect{|jr| jr['id']}
    expect(ge_ids).to eq(group_events.map(&:id))
  end

  it 'Get Group Event' do
    params = input_params.clone
    post '/api/v1/users/1/group_events',params.to_json, 'Content-Type' => 'application/json'
    json_response = JSON.parse(response.body)

    group_event = GroupEvent.last
    get "/api/v1/users/1/group_events/#{json_response['id']}", 'Content-Type' => 'application/json'
    json_response = JSON.parse(response.body)

    expect(response.status).to eq 200
    expect(json_response['id']).to eq(group_event.id)
  end

  it 'Group Event Journey' do
    params = input_params.clone
    params[:group_event].delete(:is_published)

    post '/api/v1/users/1/group_events',params.to_json, 'Content-Type' => 'application/json'
    json_response = JSON.parse(response.body)
    ge = GroupEvent.last

    expect(response.status).to eq 201
    expect(json_response['id']).to eq(ge[:id])
    expect(json_response['status']).to eq(GroupEvent::STATUSES[:draft])

    params[:group_event].merge!({duration: 60,is_published: true})

    put "/api/v1/users/1/group_events/#{json_response['id']}",params.to_json, 'Content-Type' => 'application/json'

    json_response = JSON.parse(response.body)
    ge.reload

    expect(response.status).to eq 200
    expect(json_response['id']).to eq(ge[:id])
    expect(json_response['duration']).to eq(ge[:duration])
    expect(json_response['status']).to eq(GroupEvent::STATUSES[:published])

    delete "/api/v1/users/1/group_events/#{json_response['id']}"

    ge.reload
    expect(response.status).to eq 200
    expect(ge[:status]).to eq(GroupEvent::STATUSES[:deleted])
  end

  it 'Return error when event published with limited data' do
    params = input_params.clone
    params[:group_event].delete(:duration)
    post '/api/v1/users/1/group_events',params.to_json, 'Content-Type' => 'application/json'
    json_response = JSON.parse(response.body)

    expect(response.status).to eq 500
    expect(json_response['response_type']).to eq('error')
  end

  it 'Return error when event updated with published with limited data' do
    params = input_params.clone
    params[:group_event].delete(:location)
    params[:group_event].delete(:is_published)

    post '/api/v1/users/1/group_events',params.to_json, 'Content-Type' => 'application/json'
    json_response = JSON.parse(response.body)
    ge = GroupEvent.last

    expect(response.status).to eq 201
    expect(json_response['id']).to eq(ge[:id])
    expect(json_response['status']).to eq(GroupEvent::STATUSES[:draft])

    params[:group_event].delete(:duration)
    params[:group_event].merge!({is_published: true})

    put "/api/v1/users/1/group_events/#{json_response['id']}",params.to_json, 'Content-Type' => 'application/json'

    json_response = JSON.parse(response.body)
    ge.reload

    expect(response.status).to eq 500
    expect(json_response['response_type']).to eq('error')
  end

  it 'Create Group Event with published' do
    params = input_params.clone

    post '/api/v1/users/1/group_events',params.to_json, 'Content-Type' => 'application/json'
    json_response = JSON.parse(response.body)

    ge = GroupEvent.last
    expect(response.status).to eq 201
    expect(json_response['id']).to eq(ge[:id])
    expect(json_response['status']).to eq(GroupEvent::STATUSES[:published])
  end

  it 'Group Event response has end_at key' do
    params = input_params.clone

    post '/api/v1/users/1/group_events',params.to_json, 'Content-Type' => 'application/json'
    json_response = JSON.parse(response.body)

    ge = GroupEvent.last

    expect(response.status).to eq 201
    json_response.should have_key('end_at')
    expect(json_response['end_at']).to eq(ge.end_at.to_s(:db))
  end
end