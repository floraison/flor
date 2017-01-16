
# charly.rb

class CharlyTasker

  def initialize(tasker, conf)

    @tasker = tasker
    @conf = conf
  end

  def task(message)

    c = {}

    c['payload'] = Flor.dup(message['payload'])
    c['tconf'] = Flor.dup(message['tconf'])
    c['vars'] = Flor.dup(message['vars'])

    c['tasker'] = message['tasker']
    c['taskname'] = message['taskname']

    message['payload']['charly'] = c

    @tasker.reply(message)
  end
end

