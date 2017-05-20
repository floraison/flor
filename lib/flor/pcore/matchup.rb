
class Flor::Pro::MatchUp < Flor::Procedure

  name 'matchup'

  # TODO bind "_or" and "_guard"

  def receive_non_att

    @node['val'] = payload_ret
  end

  protected
end

