
class Flor::Pro::Return < Flor::Procedure

  name 'return'

  def receive_last

    si = Flor.sub_nid(nid)
    n = @node

    target =
      loop do
        pn = parent_node(n)
        break nil unless pn
        psi = Flor.sub_nid(pn['nid'])
        break n['nid'] if psi != si
        n = pn
      end

    fail Flor::FlorError.new('"return" outside of function', self) \
      unless target

    wrap_cancel('nid' => target, 'flavour' => 'return')
  end
end

