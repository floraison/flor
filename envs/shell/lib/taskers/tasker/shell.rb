
class ShellTasker < Flor::BasicTasker

  NATO = %w[ alpha bravo charly delta echo fox foxtrott golf echo hotel ]

  def task

    case @message['tasker']
    when *NATO then route 'nato'
    else route true
    end
  end

  alias cancel task
end

