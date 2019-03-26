
# pile.rb

#
# actual tasker

class PileTasker

  def initialize(ganger, conf, _)

    @ganger = ganger
    @conf = conf
  end

  def task(message)

    fn = "task__#{message['exid']}__#{message['nid']}.json"

    FileUtils.mkdir_p('tmp/pile/')
    File.open("tmp/pile/#{fn}", 'wb') do |f|
      f.puts(JSON.pretty_generate(message))
    end

    []

    #@ganger.return(message)
  end
end

#
# configuration

{
  class: 'PileTasker'
}

