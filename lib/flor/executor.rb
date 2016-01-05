
#--
# Copyright (c) 2015-2016, John Mettraux, jmettraux+flon@gmail.com
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
#
# Made in Japan.
#++


module Flor

  class Executor

    def initialize(unit, msgs)

      @unit = unit
      @storage = unit.storage
      @msgs = msgs

      @execution = nil
    end

    def execute

      exid = @msgs.first['exid']

      @execution =
        @storage.load_execution(exid) ||
        { 'exid' => exid }

      processed = []

      loop do

        # TODO executor is not threaded, so have to break after
        # a certain number of messages

        msg = @msgs.shift
        break unless msg

        case msg['point']
          when 'execute' then handle_execute(msg)
          when 'receive', 'cancel' then handle_return(msg)
          else handle_event(msg)
        end

        processed.push(msg)
      end

      @storage.flag_as(processed, 'processed')
      @storage.store_back(@msgs)
    end

    protected

    def queue(point, nid, from_nid, h={})

      point = point.to_s
      p = point[0, 1]

      h = h.inject({}) { |hh, (k, v)| hh[k.to_s] = v; hh }
      h['point'] = point
      h['n'] = @execution['msg_counter'] = (@execution['msg_counter'] || 0) + 1
      h['nid'] = nid
      h[point == 'execute' ? 'parent' : 'from'] = from_nid
      h['payload'] = {} if h['payload'].nil? && p == 'e' || p == 'r'

      @msgs << h
    end

    def create_node(msg, nid, parent_nide, tree)
    end

    def handle_execute(msg)

      nid = msg['nid'] || '0'
      tree = msg['tree']
      parent_nid = msg['parent']
      payload = msg['payload']

      node = create_node(msg, nid, parent_nid, tree)

      # TODO rewrite tree

      if parent_nid == nil && nid == '0'
        queue(:launched, nid, nil, payload: Flor.dup(payload))
      end

      k = Flor::Ins.const_get(tree.first.capitalize)
      r = k.new(node, msg).execute

      if r == :over
        queue(
          :receive, nid, nid,
          payload: Flor.dup(payload))
      elsif r == :ok
      else # r == :error
        queue(
          :failed, nid, parent_nid,
          payload: Flor.dup(payload), error: node['errors'][-1])
      end

      log(msg)
    end

    def handle_return(msg)

      # TODO

      puts "=== handle_return"
      p msg
      puts "=== handle_return."
    end

    def handle_event(msg)

      # TODO

      puts "=== handle_event"
      p msg
      puts "=== handle_event."
    end

    def log(msg)

      @unit.logger.log(msg)
    end
  end
end

#static void handle_return(char order, fdja_value *msg)
#{
#  fgaj_i("%c", order);
#
#  char *nid = fdja_lsd(msg, "nid", "0");
#  char *fname = fdja_ls(msg, "fname", NULL);
#  char *parent_nid = NULL;
#
#  fdja_value *node = fdja_l(execution, "nodes.%s", nid);
#
#  if (node == NULL)
#  {
#    flon_move_to_rejected("var/spool/exe/%s", fname, "node not found");
#    goto _over;
#  }
#
#  parent_nid = fdja_ls(msg, "parent", NULL);
#
#  fdja_value *payload = fdja_l(msg, "payload");
#
#  //fgaj_d("%c %s", order, instruction);
#
#  //
#  // perform instruction
#
#  char r = flon_call_instruction(order, node, msg);
#
#  //
#  // v, k, r, handle instruction result
#
#  if (r == 'v') // over
#  {
#    free(parent_nid); parent_nid = flon_parent_nid(nid);
#
#    if (parent_nid)
#    {
#      flon_queue_msg(
#        "receive", parent_nid, nid,
#        fdja_o("payload", fdja_clone(payload), NULL));
#    }
#    else
#    {
#      log_delta(node); // log (debug) the age of the execution
#
#      if (strcmp(nid, "0") == 0)
#      {
#        flon_queue_msg(
#          "terminated", nid, NULL,
#          fdja_o("payload", fdja_clone(payload), NULL));
#      }
#      else
#      {
#        flon_queue_msg(
#          "ceased", nid, NULL,
#          fdja_o("payload", fdja_clone(payload), NULL));
#      }
#    }
#
#    fdja_pset(execution, "nodes.%s", nid, NULL); // remove node
#  }
#  else if (r == 'k') // ok
#  {
#    // nichts
#  }
#  else // error, 'r' or '?'
#  {
#    flon_queue_msg(
#      "failed", nid, parent_nid,
#      fdja_o(
#        "payload", fdja_clone(payload),
#        "error", fdja_lc(node, "errors.-1"),
#        NULL));
#  }
#
#  if (fname) flon_move_to_processed("var/spool/exe/%s", fname);
#
#  do_log(msg);
#
#_over:
#
#  free(nid);
#  free(parent_nid);
#  free(fname);
#}

