
class Flor::Pro::Case < Flor::Procedure
  #
  # The classical case form.
  #
  # Takes a 'key' and then look at arrays until it finds one that contains
  # the key. When found, it executes the child immediately following the
  # winning array.
  #
  # ```
  # case level
  #   [ 0 1 2 ];; 'low'
  #   [ 3 4 5 ];; 'medium'
  #   else;; 'high'
  # ```
  # which is a ";;"ed version of
  # ```
  # case level
  #   [ 0 1 2 ]
  #   'low'
  #   [ 3 4 5 ]
  #   'medium'
  #   else
  #   'high'
  # ```
  #
  # ## else
  #
  # As seen in the example above, an "else" in lieu of an array acts as
  # a catchall and the child immediately following it is executed.
  #
  # If there is no else and no matching array, the case terminates and
  # doesn't set the field "ret".

  name 'case'

  def pre_execute

    unatt_unkeyed_children
#    flatten
  end

  def receive_non_att

    return wrap_reply if @node['found']

    return receive_array if @node.has_key?('key')

    @node['key'] = payload['ret']
    super
  end

  protected

  def receive_array

    a = payload['ret']
    a = a.nil? ? [ a ] : Array(a)

    payload['ret'] = node_payload_ret

    if a.include?(@node['key'])

      @node['found'] = true
      execute_child(@fcid + 1)

    else

      t = tree[1][@fcid + 2]

      if t && t[0, 2] == [ 'else', [] ]
        @node['found'] = true
        execute_child(@fcid + 3)
      else
        execute_child(@fcid + 2)
      end
    end
  end

#  def flatten
#
#    ot = tree; return if ot[1].size < 2
#    t = Flor.dup(ot)
#
#    nchildren = []
#    mode = :array
#
#    #t[1][1..-1].each do |ct|
#    non_att_children.each do |ct|
#
#      if nchildren.empty? || mode == :clause
#        nchildren << ct
#        mode = :array
#        next
#      end
#
#      ct0, ct1, ct2 = ct
#
#      if (Flor.is_tree?(ct0) || ct0 == 'else') && ct1.any?
#        nchildren << (ct0 == 'else' ? [ 'else', [], ct2 ] : ct0)
#        if ct1.size == 1
#          nchildren << ct1.first
#        else # ct1.size > 1
#          sequence = [ 'sequence', ct1, ct1.first[2] ]
#          nchildren << sequence
#        end
#      #elsif ct0.is_a?(String) && ct1.is_a?(Array) && ct1.any?
#      #  p ct
#      #  dct0 = deref(ct0)
#      #  hct0 = reheap(ct, dct0)
#      #  p dct0
#      #  p hct0
#      else
#        nchildren << ct
#        mode = :clause
#      end
#    end
#
#    t[1] = nchildren
#pp nchildren
#
#    @node['tree'] = t if t != ot
#  end
end

