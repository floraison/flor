
class NatoTasker < Flor::BasicTasker

  def task

    name, dir, fname = determine_name_dir_fname

    FileUtils.mkdir_p(dir)

    pl = @message.delete('payload')
    @message['payload'] = pl
      # place payload at the end

    File.open(File.join(dir, fname), 'w') do |f|
      f.puts(JSON.pretty_generate(@message))
    end

    []
  end

  def cancel

    _, dir, fname = determine_name_dir_fname

    FileUtils.rm_f(File.join(dir, fname))

    reply
  end

  protected

  def determine_name_dir_fname

    name = @message['original_tasker'] || @message['tasker']
    dir = File.join(root, 'var/tasks', name)
    fname = [ 'task', exid, nid ].join('-') + '.json'

    [ name, dir, fname ]
  end

  def root

    dd = File.absolute_path(__FILE__).split('/')
    dd.pop while dd[-2] != 'envs'

    dd.join('/')
  end
end

