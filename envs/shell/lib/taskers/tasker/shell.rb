
class ShellTasker < Flor::BasicTasker

  NATO = %w[ alpha bravo charly delta fox foxtrott golf echo hotel ]
    # there is no "echo" here, since there is an "echo" procedure

  def task

    case @message['tasker']
    when *NATO then route 'nato'
    else route true
    end
  end

  alias cancel task
end

