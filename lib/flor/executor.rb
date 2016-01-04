
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
    end

    def execute

      exe = @storage.load_execution(@msgs.first['exid'])
      processed = []

      loop do

        # TODO executor is not threaded, so have to break after
        # a certain number of messages

        msg = @msgs.shift
        break unless msg

        case msg['point']
          when 'execute' then handle_execute(exe, msg)
          when 'receive', 'cancel' then handle_receive(exe, msg)
          else handle_event(exe, msg)
        end

        processed.push(msg)
      end

      @storage.flag_as(processed, 'processed')
      @storage.store_back(@msgs)
    end

    protected

    def create_node(msg, nid, parent_nide, tree)
    end

    def handle_execute(execution, msg)

      nid = msg['nid'] || '0'
      tree = msg['tree']
      parent_nid = msg['parent']
      node = create_node(msg, nid, parent_nid, tree)

      # TODO rewrite tree

#  if (parent_nid == NULL && strcmp(nid, "0") == 0)
#  {
#    flon_queue_msg(
#      "launched", nid, NULL, fdja_o("payload", fdja_clone(payload), NULL));
#  }

#  char r = flon_call_instruction(order, node, msg);
      k = Flor::Ins.const_get(tree.first.capitalize)
      r = k.new(node, msg).execute

      if r == :over
#    flon_queue_msg(
#      "receive", nid, nid, fdja_o("payload", fdja_clone(payload), NULL));
      elsif r == :ok
      else # r == :error
#    flon_queue_msg(
#      "failed", nid, parent_nid,
#      fdja_o(
#        "payload", fdja_clone(payload),
#        "error", fdja_lc(node, "errors.-1"),
#        NULL));
      end

      log(msg)
    end

    def handle_receive(execution, msg)

      # TODO

      puts "=== receive"
      p msg
      puts "=== receive."
    end

    def log(msg)

      @unit.logger.log(msg)
    end
  end
end

#static void handle_execute(char order, fdja_value *msg)
#{
#  fgaj_i("%c", order);
#
#  char *fname = fdja_ls(msg, "fname", NULL);
#  char *nid = fdja_lsd(msg, "nid", "0");
#
#  fdja_value *tree = fdja_l(msg, "tree");
#
#  if (tree == NULL || tree->type != 'a')
#  {
#    tree = flon_node_tree(nid);
#  }
#  if (tree == NULL)
#  {
#    flon_move_to_rejected("var/spool/exe/%s", fname, "tree not found");
#    free(fname); free(nid);
#    return;
#  }
#
#  char *parent_nid = fdja_ls(msg, "parent", NULL);
#  fdja_value *payload = fdja_l(msg, "payload");
#  fdja_value *node = create_node(msg, nid, parent_nid, tree);
#
#  fdja_set(msg, "tree", fdja_clone(tree));
#
#  /*int rewritten = */flon_rewrite_tree(node, msg);
#
#  if (parent_nid == NULL && strcmp(nid, "0") == 0)
#  {
#    flon_queue_msg(
#      "launched", nid, NULL, fdja_o("payload", fdja_clone(payload), NULL));
#  }
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
#    flon_queue_msg(
#      "receive", nid, nid, fdja_o("payload", fdja_clone(payload), NULL));
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
#  free(fname);
#  free(nid);
#  free(parent_nid);
#}

#static fdja_value *create_node(
#  fdja_value *msg, char *nid, char *parent_nid, fdja_value *tree)
#{
#  fdja_value *node = fdja_object_malloc();
#
#  //fdja_set(
#  //  node, "inst", fdja_lc(tree, "0"));
#    // done at the rewrite step now
#
#  fdja_set(
#    node, "nid", fdja_s(nid));
#  fdja_set(
#    node, "ctime", fdja_sym(flu_tstamp(NULL, 1, 'u')));
#  fdja_set(
#    node, "parent", parent_nid ? fdja_s(parent_nid) : fdja_v("null"));
#
#  if (strcmp(nid, "0") == 0) fdja_set(node, "tree", fdja_clone(tree));
#
#  fdja_value *vars = fdja_l(msg, "vars");
#  if (vars) fdja_set(node, "vars", fdja_clone(vars));
#  else if (strcmp(nid, "0") == 0) fdja_set(node, "vars", fdja_object_malloc());
#
#  fdja_pset(execution, "nodes.%s", nid, node);
#
#  //puts(fdja_todc(execution));
#
#  return node;
#}

