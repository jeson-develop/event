module V1
  class GroupEvents < Grape::API
    helpers do
      def group_event_params
        ActionController::Parameters.new(params).require(:group_event).permit(:name, :description, :start_at, :duration, :end_at, :location, :is_published)
      end
    end

    resources :users do
      desc 'Return group events of a user.'
      params do
        requires :user_id, type: Integer, desc: 'Event id.'
      end
      route_param :user_id do
        resources :group_events do
          desc 'Return list of group events.'
          get do
            # authenticate!
            GroupEvent.where(user_id:params[:user_id])
          end

          desc 'Return a group event.'
          params do
            requires :id, type: Integer, desc: 'Event id.'
          end
          route_param :id do
            get do
              GroupEvent.find(params[:id])
            end
          end

          desc 'Create a group event.'
          params do
            requires :group_event, type: Hash do
              requires :name, type: String
            end
          end
          post do
            # authenticate!
            event = GroupEvent.new(group_event_params)
            event.user_id = params[:user_id]
            event.set_status
            if event.save!
              event
            end
          end

          desc 'Update a a group event.'
          params do
            requires :id, type: String, desc: 'Event ID.'
          end
          put '/:id' do
            # authenticate!
            event = GroupEvent.find(params[:id])
            event.attributes = group_event_params
            event.set_status
            if event.save!
              event
            end
          end

          desc 'Delete a group event.'
          params do
            requires :id, type: String, desc: 'Event ID.'
          end
          delete ':id' do
            # authenticate!
            GroupEvent.find(params[:id]).update({status: GroupEvent::STATUSES[:deleted]})
          end
        end
      end
    end
  end
end