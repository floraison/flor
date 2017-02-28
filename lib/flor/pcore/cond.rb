
class Flor::Pro::Cond < Flor::Procedure
  #
  # Evaluates all its condition children until one evaluates to true
  # (or it's an else), then executes the corresponding clause child.
  #
  # ```
  # set a 4
  # cond
  #   a < 4              # condition 0
  #   "less than four"   # clause 0
  #   a < 7              # condition 1
  #   "less than seven"  # ...
  #   a < 10
  #   "less than ten"
  # ```
  # will yield "less than seven".
  #
  # ```
  # set a 11
  # cond
  #   a < 4 ;; "less than four"
  #   a < 7 ;; "less than seven"
  #   else ;; "ten or bigger"
  # ```
  # will yield "ten or bigger".

  name 'cond'

  def receive_non_att

    return execute_child(0) if @message['point'] == 'execute'
    return reply if @node['found']

    tf2 = tree[1][@fcid + 2]

    if Flor.true?(payload['ret'])
      @node['found'] = true
      execute_child(@fcid + 1)
    elsif tf2 && tf2[0, 2] == [ 'else', [] ]
      @node['found'] = true
      execute_child(@fcid + 3)
    else
      execute_child(@fcid + 2)
    end
  end

  protected

  def execute_child(i)

    payload['ret'] = node_payload_ret unless tree[1][i]

    super(i)
  end
end

