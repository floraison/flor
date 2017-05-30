
class Flor::Pro::Length < Flor::Procedure

  name 'length'

  def receive_last

    r = payload['ret']

    payload['ret'] =
      if r.respond_to?(:length) then r.length
      else -1
      end

    super
  end
end

