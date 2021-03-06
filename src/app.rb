require 'require_all'
require 'logger'
require_all File.expand_path('.', File.dirname(__FILE__))

class App
  def initialize(stop = false)
    @stop = stop
  end

  def start
    client_pool = ClientPool.new
    users_relationships_manager = UserFollowersManager.new

    actors = actors_mapping client_pool, users_relationships_manager
    command_executor = EventCommandExecutor.new actors
    command_builder = EventCommandBuilder.new valid_commands

    events_dispatcher = EventsDispatcher.new command_builder, command_executor
    events_handler = EventsSocketHandler.new events_dispatcher
    clients_handler = UserClientSocketHandler.new client_pool

    event_source_thread =  SocketListener.new(AppConfig.events_port, events_handler).start!
    user_clients_thread =  SocketListener.new(AppConfig.clients_port, clients_handler).start!

    [event_source_thread, user_clients_thread].each(&:join)
  end

  def stop
    @stop = true
  end

  def self.log
    @@logger ||= Logger.new(STDOUT)
    @@logger
  end

  private
  def actors_mapping client_pool, user_relationship_manager
    {
      BroadcastEventCommand => BroadcastActor.new(client_pool),
      FollowEventCommand => FollowActor.new(user_relationship_manager, client_pool),
      PrivateMessageEventCommand => PrivateMessageActor.new(client_pool),
      StatusUpdateEventCommand => StatusUpdateActor.new(user_relationship_manager, client_pool),
      UnfollowEventCommand => UnfollowActor.new(user_relationship_manager)
    }
  end

  def valid_commands
    [BroadcastEventCommand, FollowEventCommand, PrivateMessageEventCommand, StatusUpdateEventCommand, UnfollowEventCommand]
  end
end

if __FILE__ == $0
  App.new.start
end
