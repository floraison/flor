
class Flor::Pro::Keys < Flor::Procedure

  name 'keys'

  def pre_execute

    unatt_unkeyed_children
  end

  def receive

    determine_fcid_and_ncid

    if ! from_att? && ((r = payload['ret']).respond_to?(:length))

      @node['result'] =
        case r
        when Hash then r.keys
        when Array then (0..r.length - 1).to_a
        else r.class
        end
    end

    if last_receive?

      r = @node['result']

      fail Flor::FlorError.new(
        "No argument given", self
      ) if r.nil?
      fail Flor::FlorError.new(
        "Received argument of class #{r}, no keys", self
      ) unless r.is_a?(Array)

      payload['ret'] = r
    end

    super
  end
end

