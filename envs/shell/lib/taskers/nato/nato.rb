
class NatoTasker < Flor::BasicTasker

  def task

    name = @message['original_tasker'] || @message['tasker']
    fname = [ 'task', exid, nid ].join('-') + '.json'

    dir = File.join(root, 'var/tasks', name)
    FileUtils.mkdir_p(dir)

    pl = @message.delete('payload')
    @message['payload'] = pl
      # place payload at the end

    File.open(File.join(dir, fname), 'w') do |f|
      f.puts(JSON.pretty_generate(@message))
    end

    []
  end

  protected

  def root

    dd = File.absolute_path(__FILE__).split('/')
    dd.pop while dd[-2] != 'envs'

    dd.join('/')
  end
end

