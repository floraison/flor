
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

    return reply if @node['found']

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
#    nchildren = [ t[1].first ]
#    mode = :array
#
#    t[1][1..-1].each do |ct|
#
#      if mode == :array
#
#        if ct[0].is_a?(String)
#          puts "---"
#          dct0 = deref(ct[0])
#          hct0 = toheap(ct, dct0)
#          p dct0
#          p hct0
#          puts "/---"
#        end
#
#        if (Flor.is_tree?(ct[0]) || ct[0] == 'else') && ct[1].any?
#          nchildren << (ct[0] == 'else' ? [ 'else', [], ct[2] ] : ct[0])
#          if ct[1].size == 1
#            nchildren << ct[1].first
#          else # ct[1].size > 1
#            sequence = [ 'sequence', ct[1], ct[1].first[2] ]
#            nchildren << sequence
#          end
#        else
#          nchildren << ct
#          mode = :clause
#        end
#
#      else # mode == :clause
#
#        nchildren << ct
#        mode = :array
#      end
#    end
#
#    t[1] = nchildren
#pp nchildren
#
#    @node['tree'] = t if t != ot
#  end
end

